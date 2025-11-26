`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 02:40:45 PM
// Design Name: 
// Module Name: random
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

module random #(
    parameter SEED = 8'b10100101  // XOR of your kerberos IDs' 8 LSBs
)(
    input wire clk,
    input wire BTNC,
    output reg [7:0] rnd
);
    wire feedback = rnd[7] ^ rnd[5] ^ rnd[4] ^ rnd[3];
    wire r_clean; 
    debouncer db_r   (.clk(clk), .btn(BTNC), .btn_clean(r_clean));
    always @(posedge clk) begin
        if (r_clean)
            rnd <= SEED;
        else
            rnd <= {rnd[6:0], feedback};
    end
endmodule
