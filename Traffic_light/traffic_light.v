module traffic_light(
    input clk,             // 10MHz clock
    input rst_n,           // Active low asynchronous reset
    output reg red_light,  // Enable red light
    output reg yellow_light, // Enable yellow light
    output reg green_light,  // Enable green light
    output [15:0] display_led, // 7 segment display, 2 digits
    output timer_load,     // Timer load signal
    output [31:0] timer    // Timer value
);

    // Định nghĩa các trạng thái
    localparam GREEN = 2'b00;
    localparam YELLOW = 2'b01;
    localparam RED = 2'b10;

    // Khai báo các tín hiệu nội bộ
    wire [1:0] current_state;  // Trạng thái hiện tại từ FSM
    wire timer_zero;           // Tín hiệu báo timer đã đếm về 0    // Tín hiệu báo timer đã đếm về 0 (sử dụng timer == 1 để detect trước 1 clock)
    assign timer_zero = (timer == 1);

    // Khởi tạo module FSM
    traffic_light_fsm fsm_inst(
        .clk(clk),
        .rst_n(rst_n),
        .timer_zero(timer_zero),
        .current_state(current_state),
        .timer_load(timer_load)
    );

    // Khởi tạo module timer
    timer timer_inst(
        .clk(clk),
        .rst_n(rst_n),
        .load(timer_load),
        .current_state(current_state),
        .timer(timer)
    );

    // Module hiển thị LED 7 đoạn - sử dụng combinational logic
    seg7_display display_inst(
        .clk(clk),
        .rst_n(rst_n),
        .value(timer[7:0] > 0 ? timer[7:0] : 8'd00), // Hiển thị timer hiện tại, min = 00
        .display(display_led)
    );

    // Logic điều khiển đèn
    always @(*) begin
        // Mặc định tắt tất cả đèn
        green_light = 1'b0;
        yellow_light = 1'b0;
        red_light = 1'b0;
        
        case (current_state)
            GREEN: begin
                green_light = 1'b1;
            end
            YELLOW: begin
                yellow_light = 1'b1;
            end
            RED: begin
                red_light = 1'b1;
            end
            default: begin
                // Giữ tất cả đèn tắt trong trường hợp không xác định
            end
        endcase
    end

    // Add monitoring for timer, value, and display signals
    initial begin
        $monitor("Time=%t | Timer=%d | Value=%d | Display=%h", $time, timer, display_inst.value, display_led);
    end
endmodule

// Module hiển thị LED 7 đoạn
module seg7_display(
    input clk,
    input rst_n,
    input [7:0] value, // Giá trị cần hiển thị (0-99)
    output [15:0] display // 16 bit cho 2 chữ số LED 7 đoạn
);
    // Chữ số hàng đơn vị và hàng chục
    wire [3:0] ones, tens;
    
    // Tách chữ số
    assign ones = value % 10;
    assign tens = (value / 10) % 10;
    
    // Chuyển đổi từ số thành mã LED 7 đoạn
    function [7:0] to_seg7;
        input [3:0] num;
        begin
            case (num)
                4'h0: to_seg7 = 8'b11000000; // 0
                4'h1: to_seg7 = 8'b11111001; // 1
                4'h2: to_seg7 = 8'b10100100; // 2
                4'h3: to_seg7 = 8'b10110000; // 3
                4'h4: to_seg7 = 8'b10011001; // 4
                4'h5: to_seg7 = 8'b10010010; // 5
                4'h6: to_seg7 = 8'b10000010; // 6
                4'h7: to_seg7 = 8'b11111000; // 7
                4'h8: to_seg7 = 8'b10000000; // 8
                4'h9: to_seg7 = 8'b10010000; // 9
                default: to_seg7 = 8'b11111111; // Tắt
            endcase
        end
    endfunction
    
    // Cập nhật hiển thị - sử dụng combinational logic để không có delay
    assign display = (!rst_n) ? 16'hFFFF : {to_seg7(tens), to_seg7(ones)};
endmodule