`timescale 1ns / 1ps

module Display_sprite_tb;
    reg clk;
    reg BTNC, BTNL, BTNR;
    wire HS, VS;
    wire [11:0] vgaRGB;

    // Instantiate DUT
    Display_sprite dut (
        .clk(clk),
        .BTNC(BTNC),
        .BTNL(BTNL),
        .BTNR(BTNR),
        .HS(HS),
        .VS(VS),
        .vgaRGB(vgaRGB)
    );

    // Initialize signals
    initial begin
        clk = 0;
        BTNC = 0;
        BTNL = 0;
        BTNR = 0;
    end

    // Clock generation
    initial begin
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        $dumpfile("display_sprite_tb.vcd");
        $dumpvars(0, Display_sprite_tb);

        #100;

        // Reset
        BTNC = 1;
        #2000;
        BTNC = 0;
        #5000;


        // Move car left
        BTNL = 1;
        #20000;
        BTNL = 0;
        #10000;

        // Move car right
        BTNR = 1;
        #20000;
        BTNR = 0;
        #10000;

        // Force collision - align rival car with player car
        force dut.rival_inst.rival_x = dut.carfsm.car_x;
        force dut.rival_inst.rival_y = dut.carfsm.car_y + 10;
        #100;
        release dut.rival_inst.rival_x;
        release dut.rival_inst.rival_y;

        #50000;

        // Reset after collision
        BTNC = 1;
        #2000;
        BTNC = 0;
        #10000;

        $finish;
    end

endmodule