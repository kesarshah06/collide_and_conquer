`timescale 1ns / 1ps
module car_fsm #(
    parameter OFFSET_BG_X = 200,
    parameter OFFSET_BG_Y = 150,
    parameter CAR_WIDTH   = 14,
    parameter CAR_HEIGHT  = 16,
    parameter INIT_CAR_X  = 275,
    parameter INIT_CAR_Y  = 300,
    parameter MOVE_STEP   = 1,
    parameter MOVE_DIV    = 1_000_000   // adjust for movement rate (~0.25 s per step at 100 MHz)
)(
    input  wire clk,             // 100 MHz clock
    input  wire reset,           // active-high reset
    input  wire collide_with_rival, // one more variable added for collision with rival car
    input  wire frame_end,       // not used for rate control anymore
    input  wire BTNL, BTNR, BTNC,// pushbuttons from Basys3
    output reg  [9:0] car_x,     // top-left x of car
    output reg  [8:0] car_y,     // top-left y of car
    output reg bg_sp_y,
    output reg bg_sp_x
);

    // FSM states
    localparam START     = 3'd0; // when doing nothing
    localparam IDLE      = 3'd1; // doing nothing
    localparam MOVE_LEFT = 3'd2; // continuously moving left
    localparam MOVE_RIGHT= 3'd3; // continuously moving right
    localparam COLLIDE   = 3'd4; // collide with the boundary

    reg [2:0] state, next_state; // current and next state


    localparam LEFT_BOUND  = OFFSET_BG_X + 44; // left boundary of the road
    localparam RIGHT_BOUND = OFFSET_BG_X + 118; // right boundary of the road


    wire left_clean, right_clean, cent_clean; // clean outputs after debouncer for btnl btnc btnr

    // initiating debouncer
    debouncer db_left   (.clk(clk), .btn(BTNL), .btn_clean(left_clean));
    debouncer db_right  (.clk(clk), .btn(BTNR), .btn_clean(right_clean));
    debouncer db_center (.clk(clk), .btn(BTNC), .btn_clean(cent_clean));

    
    reg [31:0] move_cnt = 0;
    reg move_enable = 0; // only enable move when collide is zero
    reg collide = 0; // collide for the collide event flag variable

    // keeping this otherwise car will move for every single clock cycle 1 pixel so speed will be high
    always @(posedge clk) begin
        if (cent_clean) begin
            move_cnt <= 0;
            move_enable <= 0;
        end else if (move_cnt >= MOVE_DIV - 1) begin
            move_cnt <= 0;
            move_enable <= 1;   
        end else begin
            move_cnt <= move_cnt + 1;
            move_enable <= 0;
        end
    end

    // FSM
    always @(*) begin
        next_state = state;
        case (state)
            START:     next_state = IDLE; // idle state doing nothing
            IDLE: begin
                if (left_clean && (collide == 0))       next_state = MOVE_LEFT; // move left when btnl is on for move_cnt range and collide == 0
                else if (right_clean && (collide == 0)) next_state = MOVE_RIGHT; // move right when btnr is on for move_cnt range and collide == 0
                if (car_x < LEFT_BOUND || car_x + CAR_WIDTH > RIGHT_BOUND || collide_with_rival == 1)
                    next_state = COLLIDE; // state is collide when boundary is reached
            end
            MOVE_LEFT: begin
                if (!left_clean) next_state = IDLE; // if no movement go to idle state
                if (car_x < LEFT_BOUND) next_state = COLLIDE; // collide when x is less than left boundary
            end
            MOVE_RIGHT: begin
                if (!right_clean) next_state = IDLE; // if no movement go to idle state
                if (car_x + CAR_WIDTH > RIGHT_BOUND) next_state = COLLIDE; // collide when x is more than right boundary
            end
            COLLIDE: begin
                if (cent_clean) next_state = START; // restart
            end
        endcase
    end


    always @(posedge clk) begin
        if (cent_clean) begin // reset make the coordinates of car as initial coordinates and the speed of background is again maintained
            state   <= START;
            car_x   <= INIT_CAR_X;
            car_y   <= INIT_CAR_Y;
            bg_sp_x <= 0;
            bg_sp_y <= 1;
            collide <= 0;
        end else begin
            state <= next_state;


            if (move_enable) begin
                case (state) // reset make the coordinates of car as initial coordinates and the speed of background is again maintained
                    START: begin
                        car_x <= INIT_CAR_X;
                        car_y <= INIT_CAR_Y;
                        bg_sp_y <= 1;
                        bg_sp_x <= 0;
                        collide <= 0;
                    end
                    MOVE_LEFT: begin
                        if (car_x > LEFT_BOUND + MOVE_STEP) // moving left if we can
                            car_x <= car_x - MOVE_STEP;
                        else
                            state <= COLLIDE; // otherwise collide
                    end
                    MOVE_RIGHT: begin
                        if (car_x + CAR_WIDTH + MOVE_STEP < RIGHT_BOUND) // moving right if we can
                            car_x <= car_x + MOVE_STEP;
                        else
                            state <= COLLIDE; // otherwise collide
                    end 
                    COLLIDE: begin
                        collide <= 1; bg_sp_y <= 0; bg_sp_x <= 0; end // speed of back ground is zero if collide
                endcase
            end
        end
    end
endmodule


