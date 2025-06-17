`timescale 1ns/1ps

module tb_traffic_light;
    reg clk;
    reg rst_n;
    wire red_light, yellow_light, green_light;
    wire [15:0] display_led;

    // Define additional signals for timer and timer_load
    wire timer_load;
    wire [31:0] timer;

    traffic_light uut (
        .clk(clk),
        .rst_n(rst_n),
        .red_light(red_light),
        .yellow_light(yellow_light),
        .green_light(green_light),
        .display_led(display_led),
        .timer_load(timer_load),
        .timer(timer)
    );

    // Clock generation: 100ns period => 10MHz
    initial clk = 0;
    always #50 clk = ~clk;

    // Reset sequence
    initial begin
        rst_n = 0;
        #150;
        rst_n = 1;
    end

    // Convert 7-segment output to digit
    function [7:0] decode_seg;
        input [7:0] seg;
        begin
            case(seg)
                8'b11000000: decode_seg = 0;
                8'b11111001: decode_seg = 1;
                8'b10100100: decode_seg = 2;
                8'b10110000: decode_seg = 3;
                8'b10011001: decode_seg = 4;
                8'b10010010: decode_seg = 5;
                8'b10000010: decode_seg = 6;
                8'b11111000: decode_seg = 7;
                8'b10000000: decode_seg = 8;
                8'b10010000: decode_seg = 9;
                default: decode_seg = 8'hFF;
            endcase
        end
    endfunction

    // Print status
    always @(posedge clk) begin
        if (rst_n) begin
            $display("Time=%8t | RED=%b YELLOW=%b GREEN=%b | Display=%02d", $time, red_light, yellow_light, green_light, 
                decode_seg(display_led[15:8])*10 + decode_seg(display_led[7:0]));
        end
    end

    // Add monitoring for timer_load and timer signals
    initial begin
        $monitor("Time=%t | Timer_Load=%b | Timer=%d", $time, timer_load, timer);
    end

    // Stop simulation after a while
    initial begin
        // Enough time for 2 complete cycles: (15+3+18)*2*100ns = 7,200,000 ns
        #7200000;
        $display("\nSimulation finished after 2 complete cycles.");
        $finish;
    end

    // Dump waveform
    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, tb_traffic_light);
    end
endmodule
