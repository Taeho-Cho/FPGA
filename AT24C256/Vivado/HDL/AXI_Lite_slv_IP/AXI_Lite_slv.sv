`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/31 15:37:50
// Design Name: 
// Module Name: AXI_Lite_slv
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

/*
AXI VALID/READY handshake
@ the source      generates the VALID signal to indicate that the information is available
@ the destination generates the READY signal to indicate that it can accept the information  
*/

module AXI_Lite_slv #(
    parameter
    BW=32,
    AW=32
    ) (
    // Global signals
    input clk, rst_n
    
    // Write address channel
    ,  input                   AWVALID_i
    , output logic             AWREADY_o
    ,  input [AW-1:0]          AWADDR_i
    // Write data channel
    ,  input                   WVALID_i
    , output logic             WREADY_o
    ,  input [BW-1:0]          WDATA_i
    // Write response channel
    , output logic             BVALID_o
    ,  input                   BREADY_i
    , output logic [1:0]       BRESP_o
    // Read address channel  
    ,  input                   ARVALID_i
    , output logic             ARREADY_o
    ,  input [AW-1:0]          ARADDR_i
    // Read data channel
    , output logic             RVALID_o
    ,  input                   RREADY_i
    , output logic [BW-1:0]    RDATA_o
    , output logic [   1:0]    RRESP_o
    // AXI slave interface
    , output logic [AW-1:0] EEPROM_addr
    , output logic [BW-1:0] EEPROM_wdata
    ,  input       [BW-1:0] EEPROM_rdata
    , output logic          EEPROM_wcmd, EEPROM_rcmd
    ,  input                EEPROM_done
    );
    
    
    typedef enum {
        CH_IDLE     =   0,
        CH_VAILD    =   1,
        CH_READY    =   2,
        CH_DONE     =   3
    }   CH_STATE;
    
    CH_STATE
        aw_curr_state=CH_IDLE, aw_next_state,
         w_curr_state=CH_IDLE,  w_next_state,
         b_curr_state=CH_IDLE,  b_next_state,
        ar_curr_state=CH_IDLE, ar_next_state,
         r_curr_state=CH_IDLE,  r_next_state;
    
         
//    logic [AW-1:0] valid_aw_addr, valid_ar_addr;
    logic [AW-1:0] curr_aw_addr, curr_ar_addr, next_aw_addr, next_ar_addr;
//    logic [AW-1:0] EEPROM_addr;
//    logic [BW-1:0] EEPROM_wdata, EEPROM_rdata;
//    logic EEPROM_wcmd, EEPROM_rcmd, EEPROM_done;
    logic [BW-1:0] EEPROM_wdata_next;
    
//    AT24C256_I2C #(.DEV_ADDR(8'hA0)) AT24C256_I2C_inst(
//    .clk(clk), .rst_n(rst_n),
//    .mem_addr1_i(EEPROM_addr[15:8]), // 8 bits
//    .mem_addr2_i(EEPROM_addr[ 7:0]), // 8 bits
//    .wdata_i(EEPROM_wdata), // 8 bits
//    .rdata_o(EEPROM_rdata), // 8 bits
//    .wcmd_i(EEPROM_wcmd),
//    .rcmd_i(EEPROM_rcmd),
//    .done_o(EEPROM_done)
//    );


    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n)  begin
            aw_curr_state <= CH_IDLE;
             w_curr_state <= CH_IDLE;
             b_curr_state <= CH_IDLE;
            ar_curr_state <= CH_IDLE;
             r_curr_state <= CH_IDLE;
             
             curr_aw_addr <= '0;
             curr_ar_addr <= '0;
             EEPROM_wdata <= '1;
        end else begin
            aw_curr_state <= aw_next_state;
             w_curr_state <=  w_next_state;
             b_curr_state <=  b_next_state;
            ar_curr_state <= ar_next_state;
             r_curr_state <=  r_next_state;
             
             curr_aw_addr <= next_aw_addr;
             curr_ar_addr <= next_ar_addr;
             EEPROM_wdata <= EEPROM_wdata_next; 
        end
    end
    
    always_comb begin
    // default values
    aw_next_state = aw_curr_state;
    next_aw_addr = curr_aw_addr;
    AWREADY_o = 1'b0;
    
    case(aw_curr_state)
    CH_IDLE: if(AWVALID_i) begin 
                aw_next_state = CH_READY;
                next_aw_addr = AWADDR_i; 
             end
    CH_READY: begin 
            AWREADY_o = 1'b1; 
            aw_next_state = CH_DONE; 
    end
    CH_DONE: if(BREADY_i) aw_next_state = CH_IDLE;
    default: ;
    endcase
    end // always
    
    
    always_comb begin
    // default values
    w_next_state = w_curr_state;
    EEPROM_wdata_next = EEPROM_wdata;
    WREADY_o = 1'b0;
    
    case(w_curr_state)
    CH_IDLE: if(WVALID_i) begin 
                w_next_state = CH_READY;
                EEPROM_wdata_next = WDATA_i;
             end
    CH_READY: begin 
            WREADY_o = 1'b1;
            w_next_state = CH_DONE;
    end
    CH_DONE: if(BREADY_i) w_next_state = CH_IDLE;
    default: ;
    endcase
    end // always


    always_comb begin
    // default values
    b_next_state = b_curr_state;
    BVALID_o = 1'b0;
    EEPROM_wcmd = 1'b0;
    
    case(b_curr_state)
    CH_IDLE: if((aw_curr_state != CH_IDLE) && (w_curr_state != CH_IDLE)) begin 
                b_next_state = CH_READY;
                EEPROM_wcmd = 1'b1;
             end
    CH_READY: if(EEPROM_done) b_next_state = CH_VAILD;  
    CH_VAILD: begin 
            BVALID_o = 1'b1;
            if(BREADY_i) b_next_state = CH_IDLE;
    end
    default: ;
    endcase
    end // always
    
    
    always_comb begin
    // default values
    ar_next_state = ar_curr_state;
    next_ar_addr = curr_ar_addr;
    ARREADY_o = 1'b0;
    
    case(ar_curr_state)
    CH_IDLE: if(ARVALID_i) begin 
                ar_next_state = CH_READY;
                next_ar_addr = ARADDR_i; 
             end
    CH_READY: begin 
            ARREADY_o = 1'b1; 
            ar_next_state = CH_DONE; 
    end
    CH_DONE: if(RREADY_i) ar_next_state = CH_IDLE;
    default: ;
    endcase
    end // always
    
    
    always_comb begin
    // default values
    r_next_state = r_curr_state;
    RVALID_o = 1'b0;
    EEPROM_rcmd = 1'b0;
    
    case(r_curr_state)
    CH_IDLE: if((ar_curr_state != CH_IDLE)) begin 
                r_next_state = CH_READY;
                EEPROM_rcmd = 1'b1;
             end
    CH_READY: if(EEPROM_done) r_next_state = CH_VAILD;
    CH_VAILD: begin 
            RVALID_o = 1'b1;
            if(RREADY_i) r_next_state = CH_IDLE;
    end
    default: ;
    endcase
    end // always
    
    assign EEPROM_addr  = (aw_curr_state != CH_IDLE) ? curr_aw_addr : curr_ar_addr;
    assign RDATA_o = EEPROM_rdata;
    
    assign BRESP_o = '0;
    assign RRESP_o = '0;

endmodule
