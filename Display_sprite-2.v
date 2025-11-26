`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IIT Delhi
// Engineer: Naman Jain
//
// Create Date: 09/24/2025 07:45:32 PM
// Design Name:
// Module Name: Display_sprite
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


module Display_sprite #(
    parameter pixel_counter_width = 10,
    parameter OFFSET_BG_X = 200,
    parameter OFFSET_BG_Y = 150
)(
    input clk,
    input BTNC,
    input BTNL,
    input BTNR,
    output HS, VS,
    output [11:0] vgaRGB
);
    // parameters for the size of background
    localparam bg1_width = 160;
    localparam bg1_height = 240;
    localparam main_car_width = 14;
    localparam main_car_height = 16;
    localparam PINK_COLOR = 12'b101000001010;

    wire pixel_clock;
    wire [3:0] vgaRed, vgaGreen, vgaBlue;
    wire [pixel_counter_width-1:0] hor_pix, ver_pix;
    reg [11:0] output_color, next_color;
    wire frame_end = (hor_pix == 639 && ver_pix == 479);

    // car position
    wire [9:0] car_x, car_y;
    wire [9:0] dynamic_offset_x, dynamic_offset_y;
    wire bg_sp_y, bg_sp_x;
    reg car_on;
    reg [7:0] car_rom_addr;
    wire [11:0] car_color;

    reg bg_on;
    reg [15:0] bg_rom_addr;
    wire [11:0] bg_color;

    // rival car position
    wire [7:0] rnd;
    wire [9:0] rival_x, rival_y;
    reg rival_on;
    wire [11:0] rival_color;
    reg [7:0] rival_addr;

    // VGA driver initiated
    VGA_driver #(.WIDTH(pixel_counter_width)) display_driver (
        .clk(clk),
        .vgaRed(vgaRed), .vgaGreen(vgaGreen), .vgaBlue(vgaBlue),
        .HS(HS), .VS(VS), .vgaRGB(vgaRGB),
        .pixel_clock(pixel_clock),
        .hor_pix(hor_pix),
        .ver_pix(ver_pix)
    );

    // rom initiated
    bg_rom bg1_rom (.clka(clk), .addra(bg_rom_addr), .douta(bg_color));
    main_car_rom car1_rom (.clka(clk), .addra(car_rom_addr), .douta(car_color));
    rival_car_rom rival_rom (.clka(clk), .addra(rival_addr), .douta(rival_color));

    // random car initiated
    random rnd_gen(.clk(clk), .BTNC(BTNC), .rnd(rnd));

    wire collide_with_rival;
    assign collide_with_rival =
        (car_x < rival_x + 14) && (car_x + 14 > rival_x) &&
        (car_y < rival_y + 16) && (car_y + 16 > rival_y);

    rival_car rival_inst(
        .clk(clk),
        .frame_end(frame_end),
        .reset(BTNC),
        .rnd(rnd),
        .collide_with_rival(collide_with_rival),
        .SCROLL_SPEED_Y(bg_sp_y),
        .rival_x(rival_x),
        .rival_y(rival_y)
    );

    bg_motion #(.BG_WIDTH(bg1_width), .BG_HEIGHT(bg1_height)) background_motion (
        .clk(pixel_clock),
        .frame_end(frame_end),
        .reset(BTNC),
        .SCROLL_SPEED_Y(bg_sp_y),
        .SCROLL_SPEED_X(bg_sp_x),
        .offset_x(dynamic_offset_x),
        .offset_y(dynamic_offset_y)
    );

    car_fsm carfsm(
        .clk(clk),
        .reset(0),
        .frame_end(frame_end),
        .BTNL(BTNL),
        .BTNR(BTNR),
        .BTNC(BTNC),
        .collide_with_rival(collide_with_rival),
        .car_x(car_x),
        .car_y(car_y),
        .bg_sp_y(bg_sp_y),
        .bg_sp_x(bg_sp_x)
    );

    always @(posedge clk) begin : CAR_LOCATION
        if (hor_pix >= car_x && hor_pix < (car_x + main_car_width) &&
            ver_pix >= car_y && ver_pix < (car_y + main_car_height)) begin
            car_rom_addr <= (hor_pix - car_x) + (ver_pix - car_y) * main_car_width;
            car_on <= 1;
        end else begin
            car_on <= 0;
        end
    end
    integer x_wrapped, y_wrapped;

    always @(posedge clk) begin : RIVAL_LOCATION
        if (hor_pix >= rival_x && hor_pix < (rival_x + 14) &&
            ver_pix >= rival_y && ver_pix < (rival_y + 16)) begin
            rival_addr <= (hor_pix - rival_x) + (ver_pix - rival_y) * 14;
            rival_on <= 1;
        end else begin
            rival_on <= 0;
        end
    end


    
    always @(posedge pixel_clock) begin : BG_LOCATION
        if (hor_pix >= OFFSET_BG_X && hor_pix < (OFFSET_BG_X + bg1_width) &&
            ver_pix >= OFFSET_BG_Y && ver_pix < (OFFSET_BG_Y + bg1_height)) begin
            x_wrapped = (hor_pix - OFFSET_BG_X + dynamic_offset_x) % bg1_width;
            y_wrapped = (ver_pix - OFFSET_BG_Y + dynamic_offset_y) % bg1_height;
            bg_rom_addr <= x_wrapped + y_wrapped * bg1_width;
            bg_on <= 1;
        end else begin
            bg_on <= 0;
        end
    end


    always @(posedge clk) begin : MUX_VGA_OUTPUT
        if (car_on && (car_color != PINK_COLOR))
            next_color <= car_color;
        else if (rival_on && (rival_color != PINK_COLOR))
            next_color <= rival_color;
        else if (bg_on)
            next_color <= bg_color;
        else
            next_color <= 0;
    end


    always @(posedge pixel_clock) begin
        output_color <= next_color;
    end

    assign vgaRed   = output_color[11:8];
    assign vgaGreen = output_color[7:4];
    assign vgaBlue  = output_color[3:0];

endmodule