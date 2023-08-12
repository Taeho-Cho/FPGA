`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/01 14:04:40
// Design Name: 
// Module Name: AT24C256_I2C
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AT24C256_I2C #(parameter DEV_ADDR=8'hA0, BW=8)(
       input clk, rst_n
       
    // AT24C256 signals
    ,  input       [BW-1:0]     mem_addr1_i, mem_addr2_i
    ,  input       [BW-1:0]     wdata_i
    , output logic [BW-1:0]     rdata_o
    ,  input                    wcmd_i, rcmd_i
    , output logic              done_o
    
    // I2C interface pins
//    , inout tri SCL
//    , inout tri SDA
    // I2C interface
    , output logic SCL_out,  SDA_out
    ,  input       SCL_in,   SDA_in
    );
    
    localparam  NUM_OF_PHASES   =   4,
                NUM_OF_BITS     =   BW+1; // number of bits per transfer, 1 more bit for ACK

    enum {
        S_AT24C256_IDLE  =   0,
        S_AT24C256_WRITE =   1,
        S_AT24C256_READ1 =   2, // write mem addr
        S_AT24C256_READ2 =   3, // read data
        S_AT24C256_DONE  =   4
    } AT24C256_curr_state=S_AT24C256_IDLE, AT24C256_next_state;
    
    enum {
        S_IDLE      =   0,
        S_START     =   1,
        S_DEV_ADDR  =   2,
        S_MEM_ADDR1 =   3,
        S_MEM_ADDR2 =   4,
//        S_WDATA     =   5,
//        S_RDATA     =   6,
        S_RWDATA    =   6,
        S_ACK       =   7,
        S_STOP      =   8
    } curr_state=S_IDLE, next_state, prev_state=S_IDLE, prev_state_next;


//    logic SCL_out,  SDA_out;
    logic SCL_next, SDA_next;
//    logic SCL_in,   SDA_in;
//    assign SCL    = (SCL_out == 1'b1) ? 1'bz : 1'b0;
//    assign SCL_in =  SCL;
//    assign SDA    = (SDA_out == 1'b1) ? 1'bz : 1'b0;
//    assign SDA_in =  SDA;


    // 1-bit transfer is divided into 4 phases
    logic [1:0] phase_cnt, phase_cnt_next;
    // 9 bits per transfer (8-bit data + 1-bit ack)
    logic [$clog2(NUM_OF_BITS)-1:0] bit_cnt, bit_cnt_next;
    logic [BW-1:0] dev_address;
    
    logic [NUM_OF_BITS-1:0] I2C_dev_addr, I2C_mem_addr1, I2C_mem_addr2, I2C_wdata, I2C_rdata, I2C_rdata_next;
    logic ack_rcv, dev_rw;
    logic AT24C256_read_ready;
//    assign I2C_dev_addr  = {DEV_ADDR, dev_rw, 1'b1};
    assign I2C_dev_addr  = {dev_address, 1'b1};
    assign I2C_mem_addr1 = {mem_addr1_i, 1'b1};
    assign I2C_mem_addr2 = {mem_addr2_i, 1'b1};
    assign I2C_wdata     = {wdata_i,  ack_rcv};
    assign rdata_o       = I2C_rdata[NUM_OF_BITS-1:1];
    assign ack_rcv       = 1'b1; // (curr_state == S_RDATA) ?
    assign dev_rw        = (AT24C256_curr_state == S_AT24C256_READ2) ? 1'b1 : 1'b0;
    assign dev_address = DEV_ADDR + dev_rw;
    
    wire sub_clk;
    
    prescaler #(.BW(8)) prescaler_inst(
        .clk(clk),
        .rst_n(rst_n),
        .prescaler_value(8'd50), // synthesis
//        .prescaler_value(8'd10), // debugging
        .prescaler_out(sub_clk)
    );
    
    
    I2C_ila ila_inst (
    .clk(clk),
    .probe0(AT24C256_curr_state), // 3 bits
    .probe1(curr_state), // 4 bits
    .probe2(phase_cnt), // 2 bits
    .probe3(bit_cnt), // 4 bits
    .probe4(wcmd_i), // 1 bit
    .probe5(rcmd_i), // 1 bit
    .probe6(SCL_in), // 1 bit
    .probe7(SDA_in), // 1 bit
    .probe8(SCL_out), // 1 bit
    .probe9(SDA_out) // 1 bit    
    );
    
    
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin 
            AT24C256_curr_state <= S_AT24C256_IDLE;
            curr_state  <=  S_IDLE;
            prev_state  <=  S_IDLE;
            
            phase_cnt   <= '0;
              bit_cnt   <= '0;
              
            I2C_rdata   <= '0;
              SCL_out   <=  1'b1;
              SDA_out   <=  1'b1;
        end else begin
            AT24C256_curr_state <= AT24C256_next_state;
            curr_state  <=  next_state;
            prev_state  <=  prev_state_next;
            
            phase_cnt   <=  phase_cnt_next;
              bit_cnt   <=    bit_cnt_next;
            
            I2C_rdata   <=  I2C_rdata_next;
              SCL_out   <=  SCL_next;
              SDA_out   <=  SDA_next;
        end //if
    end // always_ff
    
    
    always_comb begin
        // default values
        AT24C256_next_state     =  AT24C256_curr_state;
        done_o                  =  1'b0;
        
        case(AT24C256_curr_state)
        S_AT24C256_IDLE: begin
            if(wcmd_i || rcmd_i) begin 
                if(wcmd_i)  AT24C256_next_state = S_AT24C256_WRITE;
                else        AT24C256_next_state = S_AT24C256_READ1;
            end
        end
        S_AT24C256_WRITE: ;// if(curr_state == S_STOP)  AT24C256_next_state = S_AT24C256_DONE;
        S_AT24C256_READ1: if(AT24C256_read_ready)   AT24C256_next_state = S_AT24C256_READ2;
        S_AT24C256_READ2: ;// if(curr_state == S_STOP)  AT24C256_next_state = S_AT24C256_DONE;
        S_AT24C256_DONE: begin 
            done_o = 1'b1; 
            AT24C256_next_state = S_AT24C256_IDLE;
        end
//        default: ;
        endcase
        
        if(curr_state == S_STOP)  AT24C256_next_state = S_AT24C256_DONE;
        
    end
    

    always_comb begin
    // default values
    next_state      = curr_state;
    prev_state_next = prev_state;
    //
    bit_cnt_next    = bit_cnt;
    phase_cnt_next  = phase_cnt;
    //
    AT24C256_read_ready = 1'b0;
    //
    I2C_rdata_next = I2C_rdata;
    //
    SCL_next = SCL_out;
    SDA_next = SDA_out;
    
    case(curr_state)
    S_IDLE: begin 
        if(wcmd_i || rcmd_i) begin
            next_state = S_START;
            phase_cnt_next = '0;
        end // if(wcmd_i || rcmd_i)
    end // S_IDLE
    S_START: begin
        if(sub_clk) begin
            case(phase_cnt)
            0: begin
                phase_cnt_next++;
            end
            1: begin
                SCL_next = 1'b1;
                SDA_next = 1'b1;
                phase_cnt_next++;
            end
            2: begin 
                SCL_next = 1'b1;
                SDA_next = 1'b0;
                phase_cnt_next++;
            end
            3: begin 
                SCL_next = 1'b0;
                SDA_next = 1'b0;
                phase_cnt_next  = '0;
                bit_cnt_next    =  8;
                next_state      =  S_DEV_ADDR;
            end
            endcase
        end // if(sub_clk)
    end // S_START
    S_DEV_ADDR: begin
        if(sub_clk) begin
            case(phase_cnt)
            0: begin
                SCL_next = 1'b0;
                SDA_next = I2C_dev_addr[bit_cnt];
                phase_cnt_next++;
            end
            1: begin 
                SCL_next = 1'b1;
                phase_cnt_next++;
            end
            2: begin
//                if(SCL_in) begin // clock stretching
                    I2C_rdata_next[bit_cnt] = SDA_in;
                    phase_cnt_next++;
//                end
            end
            3: begin 
                SCL_next = 1'b0;
                phase_cnt_next  = '0;

                if(bit_cnt == '0) begin
                    next_state      = S_ACK;
                    prev_state_next = S_DEV_ADDR;
                end else begin 
                    bit_cnt_next--;
                end // if(bit_cnt)                
            end // 3:
            endcase
        end // if(sub_clk)
    end // S_DEV_ADDR
    S_MEM_ADDR1: begin 
        if(sub_clk) begin
            case(phase_cnt)
            0: begin
                SCL_next = 1'b0;
                SDA_next = I2C_mem_addr1[bit_cnt];
                phase_cnt_next++;
            end
            1: begin 
                SCL_next = 1'b1;
                phase_cnt_next++;
            end
            2: begin
//                if(SCL_in) begin // clock stretching
                    I2C_rdata_next[bit_cnt] = SDA_in;
                    phase_cnt_next++;
//                end 
            end
            3: begin 
                SCL_next = 1'b0;
                phase_cnt_next  = '0;

                if(bit_cnt == '0) begin
                    next_state      = S_ACK;
                    prev_state_next = S_MEM_ADDR1;
                end else begin 
                    bit_cnt_next--;
                end // if(bit_cnt)
            end // 3:
            endcase
        end // if(sub_clk) 
    end
    S_MEM_ADDR2: begin 
        if(sub_clk) begin
            case(phase_cnt)
            0: begin
                SCL_next = 1'b0;
                SDA_next = I2C_mem_addr2[bit_cnt];
                phase_cnt_next++;
            end
            1: begin 
                SCL_next = 1'b1;
                phase_cnt_next++;
            end
            2: begin
//                if(SCL_in) begin // clock stretching
                    I2C_rdata_next[bit_cnt] = SDA_in;
                    phase_cnt_next++;
//                end 
            end
            3: begin 
                SCL_next = 1'b0;
                phase_cnt_next  = '0;
                
                if(bit_cnt == '0) begin
                    next_state      = S_ACK;
                    prev_state_next = S_MEM_ADDR2;
                end else begin 
                    bit_cnt_next--;
                end // if(bit_cnt)                
            end // 3:
            endcase            
        end // if(sub_clk)
    end
    S_RWDATA: begin 
        if(sub_clk) begin
            case(phase_cnt)
            0: begin
                SCL_next = 1'b0;
                SDA_next = I2C_wdata[bit_cnt];
                phase_cnt_next++;
            end
            1: begin 
                SCL_next = 1'b1;
                phase_cnt_next++;
            end
            2: begin
//                if(SCL_in) begin // clock stretching
                    I2C_rdata_next[bit_cnt] = SDA_in;
                    phase_cnt_next++;
//                end 
            end
            3: begin 
                SCL_next = 1'b0;
                phase_cnt_next  = '0;

                if(bit_cnt == '0) begin
                    next_state      = S_ACK;
                    prev_state_next = S_RWDATA;
                end else begin 
                    bit_cnt_next--;
                end // if(bit_cnt)
            end // 3:
            endcase            
        end // if(sub_clk)    
    end
//    S_WDATA: begin end
//    S_RDATA: begin end
    S_ACK: begin
         if(I2C_rdata[0] == 1'b0) begin
            bit_cnt_next = 8;
//            unique case(prev_state)
            case(prev_state)
            S_DEV_ADDR: begin 
                if(AT24C256_curr_state == S_AT24C256_READ2) next_state = S_RWDATA;
                else                                        next_state = S_MEM_ADDR1;
            end
            S_MEM_ADDR1: begin 
                next_state = S_MEM_ADDR2;
            end
            S_MEM_ADDR2: begin 
                if(AT24C256_curr_state == S_AT24C256_READ1) begin 
                    next_state = S_START; 
                    AT24C256_read_ready = 1'b1;
//                    bit_cnt_next = '0;
//                end else if(AT24C256_curr_state == S_AT24C256_READ2) begin 
//                    next_state = S_RDATA;
//                end else begin 
//                    next_state = S_WDATA;
                end else begin 
                    next_state = S_RWDATA; 
                end // if(AT24C256_curr_state)
            end
//            S_RDATA: next_state = S_STOP;
//            S_WDATA: next_state = S_STOP;
            S_RWDATA: next_state = S_STOP;
//            default: ;
            endcase
         end else begin 
            next_state = S_STOP; 
         end // if(I2C_rdata[0])
    end // S_ACK
    S_STOP: begin 
        if(sub_clk) begin
            case(phase_cnt)
            0: begin
                SCL_next = 1'b0;
                SDA_next = 1'b0;
                phase_cnt_next++;
            end
            1: begin 
                SCL_next = 1'b1;
                phase_cnt_next++;
            end
            2: begin 
                SDA_next = 1'b1;
                phase_cnt_next++;
            end
            3: begin
                bit_cnt_next    = '0;
                next_state      =  S_IDLE;
            end
            endcase
        end // if(sub_clk)
    end
//    default: ;
    endcase
    end
    
    
    
    /*
    always_comb begin
        // default values
        I2C_next_state = I2C_curr_state;
        done_o = 1'b0;
        
        unique case(I2C_curr_state)
        S_I2C_IDLE: begin
            if(wcmd_i || rcmd_i) begin 
                if(wcmd_i)  I2C_next_state = S_I2C_WRITE;
                else        I2C_next_state = S_I2C_READ1;
            end
        end
        S_I2C_WRITE: if(curr_state == S_STOP) I2C_next_state = S_I2C_DONE;
        S_I2C_READ1: begin end
        S_I2C_READ2: begin end
        S_I2C_DONE: begin 
                    done_o = 1'b1; 
            I2C_next_state = S_I2C_IDLE; 
        end
        endcase
    end
    

    always_comb begin
    // default values
    next_state = curr_state;
    bit_cnt_next = bit_cnt;
    phase_cnt_next = phase_cnt;
    
    unique case(curr_state)
    S_IDLE: begin 
//        SCL_out = 1'b1;
//        SDA_out = 1'b1;
        if(wcmd_i || rcmd_i) begin 
            next_state = S_START;
//            phase_cnt = '0;
        end // if(wcmd_i || rcmd_i)
    end // S_IDLE
    S_START: begin
        if(sub_clk) begin
            case(phase_cnt)
            0: begin
                SCL_out = 1'b1;
                SDA_out = 1'b1;
                phase_cnt_next++;
            end
            1: begin 
                SCL_out = 1'b1;
                SDA_out = 1'b0;
                phase_cnt_next++;
            end
            2: begin 
                SCL_out = 1'b0;
                SDA_out = 1'b0;
                phase_cnt_next++;
            end
            3: begin
                next_state = S_DEV_ADDR;
            end
            endcase
        end // if(sub_clk)
    end // S_START
    S_DEV_ADDR: begin
        
    end // S_DEV_ADDR
    S_MEM_ADDR1: begin end
    S_MEM_ADDR2: begin end
    S_WDATA: begin end
    S_RDATA: begin end
    S_ACK: begin end
    S_STOP: begin end
    endcase
    end
    */
    
endmodule
