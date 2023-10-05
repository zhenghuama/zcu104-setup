`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2023 04:29:58 PM
// Design Name: 
// Module Name: irq_pl
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


module irq_pl(
    input clk,
    input [0:0] irq_in,
    output reg [0:0] irq_out
    );
    reg [5:0] counter;
    always @(negedge clk) begin
        if (irq_out == 1) begin
            counter <= counter + 1;
        end else begin
            counter <= 0;
        end
    end
    always @(posedge clk) begin
        if (counter == 0) begin
            irq_out <= irq_in;
        end
    end       
    
endmodule
