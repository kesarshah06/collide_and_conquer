`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 02:45:51 PM
// Design Name: 
// Module Name: rival_car_fsm
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

module rival_car #(
    parameter OFFSET_BG_X = 200,
    parameter OFFSET_BG_Y = 150,
    parameter CAR_WIDTH   = 14,
    parameter CAR_HEIGHT  = 16,
    parameter BG_LEFT     = 44,
    parameter BG_RIGHT    = 104,
    parameter FRAME_MAX   = 5 // frames moved before going down
)(
    input  clk,
    input  frame_end,
    input  reset,
    input  [7:0] rnd, // output of random generator to get the x location of car
    input  wire collide_with_rival,  // if a collision has happende already with the car itself then 1
    input SCROLL_SPEED_Y, // if a collision with boundary has happened
    output reg [9:0] rival_x, // x coordinate of rival car
    output reg [9:0] rival_y // y coordinate of rival car
);
    reg [4:0] frame_cnt = 0; // variable for frame counter

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rival_x <= OFFSET_BG_X + (rnd % (BG_RIGHT - BG_LEFT)) + BG_LEFT; // if reset spawn the car from the top and such that the x coordinate is random
            rival_y <= OFFSET_BG_Y;
            frame_cnt <= 0; // assign frame count to be 0
        end
        else if (frame_end) begin // when a frame has ended in vga change the y coordinate if frame count is at its max
            if (frame_cnt >= FRAME_MAX && collide_with_rival == 0 && SCROLL_SPEED_Y == 1) begin // if no type of collide even has happened and frame count reached its max
                rival_y <= rival_y + 5; // go 3 steps downwards
                frame_cnt <= 0;
            end
            else if(collide_with_rival == 0 && SCROLL_SPEED_Y == 1) // if no type of collide even has happened
                frame_cnt <= frame_cnt + 1;
 
            if (rival_y > 372) begin // if car reached the bottom of frame to to top and do random generation
                rival_x <= OFFSET_BG_X + (rnd % (BG_RIGHT - BG_LEFT)) + BG_LEFT;
                rival_y <= OFFSET_BG_Y;
            end
        end
    end
endmodule
