`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/01 14:33:02
// Design Name: 
// Module Name: prescaler
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


module prescaler #(parameter BW=8) (
    input clk, rst_n
    ,  input [BW-1:0]   prescaler_value
    , output logic      prescaler_out
    );
    
    logic [BW-1:0] cnt_value;
    
    // prescaler
    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n)                              cnt_value=0;
        else if(cnt_value == prescaler_value)   cnt_value=0;
        else                                    cnt_value++;
    end
    
    assign prescaler_out = (cnt_value == 0) ? 1'b1 : 1'b0;
    
endmodule
