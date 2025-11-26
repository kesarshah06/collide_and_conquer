`timescale 1ns / 1ps

module rival_car_tb;
    reg clk;
    reg frame_end;
    reg reset;
    reg SCROLL_SPEED_Y;
    reg collide_with_rival;
    wire [7:0] rnd;
    wire [9:0] rival_x;
    wire [9:0] rival_y;

    random rnd_gen(
        .clk(clk),
        .BTNC(reset),
        .rnd(rnd)
    );

    rival_car dut(
        .clk(clk),
        .frame_end(frame_end),
        .reset(reset),
        .rnd(rnd),
        .collide_with_rival(collide_with_rival),
        .SCROLL_SPEED_Y(SCROLL_SPEED_Y),
        .rival_x(rival_x),
        .rival_y(rival_y)
    );

    initial begin
        clk = 0;
        frame_end = 0;
        reset = 0;
        SCROLL_SPEED_Y = 1;
        collide_with_rival = 0;
    end

    initial begin
        forever #5 clk = ~clk;
    end


    initial begin
        forever begin
            #1000 frame_end = 1;
            #10 frame_end = 0;
        end
    end

    initial begin
        $dumpfile("rival_car_tb.vcd");
        $dumpvars(0, rival_car_tb);

        #100;

        reset = 1;
        #100;
        reset = 0;
        #2000;

        wait(rival_y > 372);
        #5000;


        wait(rival_y > 372);
        #5000;

        wait(rival_y > 372);
        #5000;

        $finish;
    end

endmodule