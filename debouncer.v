`timescale 1ns / 1ps

module debouncer(
    input clk,
    input btn,
    output reg btn_clean
);

    reg [19:0] cnt; //[3:0] for test bench otherwise [19:0]
    reg btn_sync;
    
     
    always @(posedge clk) begin
        btn_sync <= btn;
        if (btn_sync == btn_clean)
            cnt <= 0;
        else begin
            cnt <= cnt + 1;
            if (cnt == 20'hFFFFFF) begin // 4'hF for test bench otherwise 20'hFFFFFF
                btn_clean <= btn_sync;
                cnt <= 0;
            end
        end
    end
endmodule

