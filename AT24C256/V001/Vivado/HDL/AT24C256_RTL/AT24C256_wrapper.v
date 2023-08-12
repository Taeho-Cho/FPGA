`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/09 17:20:45
// Design Name: 
// Module Name: AT24C256_wrapper
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


module AT24C256_wrapper #(
    parameter
    BW=8,
    AW=16
    ) (
    // Global signals
    input clk, rstn
    // AXI slave interface
    ,  input [AW-1:0] EEPROM_addr
    ,  input [BW-1:0] EEPROM_wdata
    , output [BW-1:0] EEPROM_rdata
    ,  input          EEPROM_wcmd
    ,  input          EEPROM_rcmd
    , output          EEPROM_done
    
    // I2C interface pins
    , inout SCL
    , inout SDA
    );
    
    wire SCL_out,  SDA_out;
    wire SCL_in,   SDA_in;
//    wire SCL_en,   SDA_en;
    
    AT24C256_I2C #(.DEV_ADDR(8'hA0)) AT24C256_I2C_inst(
    .clk(clk), .rst_n(rstn),
    .mem_addr1_i(EEPROM_addr[15:8]), // 8 bits
    .mem_addr2_i(EEPROM_addr[ 7:0]), // 8 bits
    .wdata_i(EEPROM_wdata), // 8 bits
    .rdata_o(EEPROM_rdata), // 8 bits
    .wcmd_i(EEPROM_wcmd),
    .rcmd_i(EEPROM_rcmd),
    .done_o(EEPROM_done),
    // I2C interface
    .SCL_out(SCL_out), 
    .SDA_out(SDA_out),
    .SCL_in(SCL_in),
    .SDA_in(SDA_in)
    );
    
//    assign SCL    = (SCL_out) ? 1'bz : 1'b0;
//    assign SCL_in =  SCL;
//    assign SDA    = (SDA_out) ? 1'bz : 1'b0;
//    assign SDA_in =  SDA;
    
    IOBUF iobuf_SCL(
    .O(SCL_in),
    .IO(SCL),
    .I(1'b0),
    .T(SCL_out)
    );
    
    IOBUF iobuf_SDA(
    .O(SDA_in),
    .IO(SDA),
    .I(1'b0),
    .T(SDA_out)
    );
    
endmodule
