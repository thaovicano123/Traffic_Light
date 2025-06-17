module timer(
    input clk,
    input rst_n,
    input load,
    input [1:0] current_state,
    output reg [31:0] timer,
    output reg zero
);

    // Định nghĩa các trạng thái
    localparam GREEN  = 2'b00;
    localparam YELLOW = 2'b01;
    localparam RED    = 2'b10;

    // Tham số thời gian
    parameter ONE_SECOND  = 1;   // clock cycle = 1 giây (đơn giản hóa mô phỏng)
    parameter GREEN_TIME  = 15;
    parameter YELLOW_TIME = 3;
    parameter RED_TIME    = 18;

    // Giá trị nạp vào timer
    reg [31:0] load_value;

    // Xác định giá trị nạp
    always @(*) begin
        case (current_state)
            GREEN:  load_value = GREEN_TIME  * ONE_SECOND;
            YELLOW: load_value = YELLOW_TIME * ONE_SECOND;
            RED:    load_value = RED_TIME    * ONE_SECOND;
            default: load_value = GREEN_TIME * ONE_SECOND;
        endcase
    end    // Logic đếm ngược
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer <= GREEN_TIME * ONE_SECOND; // Khởi tạo với GREEN_TIME khi reset
        end else if (load) begin
            timer <= load_value; // Nạp giá trị khi load = 1
        end else if (timer > 0) begin
            timer <= timer - 1;
        end
    end

    // Cờ zero
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            zero <= 1'b0;
        else
            zero <= (timer == 0);
    end
endmodule
