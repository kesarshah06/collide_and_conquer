`timescale 1ns / 1ps

module bg_motion #(
    parameter BG_WIDTH = 160, // parameters for background
    parameter BG_HEIGHT = 240
)(
    input clk,
    input frame_end,        // signal that pulses once per frame
    input reset,  // reset
    input SCROLL_SPEED_Y, // speed of movement of background
    input SCROLL_SPEED_X, // speed of horizontal shift (always zero)
    output reg [9:0] offset_x,
    output reg [9:0] offset_y
);

    wire clean;

    debouncer db(.clk(clk), .btn(reset), .btn_clean(clean));

    always @(posedge clk) begin
        if (clean) begin
            offset_x <= 0;
            offset_y <= 0;
        end
        else if (frame_end && SCROLL_SPEED_Y == 1) begin
            // Move background vertically downward each frame
            offset_y <= (offset_y + BG_HEIGHT - 2 * SCROLL_SPEED_Y) % BG_HEIGHT;
            offset_x <= (offset_x + BG_WIDTH - SCROLL_SPEED_X) % BG_WIDTH;
        end
    end

endmodule

