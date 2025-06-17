module traffic_light_fsm(
    input clk,
    input rst_n,
    input timer_zero,  // Tín hiệu báo timer đã đếm về 0
    output reg [1:0] current_state,  // Trạng thái hiện tại
    output reg timer_load  // Tín hiệu để load giá trị mới vào timer
);

    // Định nghĩa các trạng thái
    localparam GREEN = 2'b00;
    localparam YELLOW = 2'b01;
    localparam RED = 2'b10;

    reg [1:0] next_state;
    reg pending_state_change; // Cờ delay chuyển trạng thái

    // Xác định trạng thái tiếp theo
    always @(*) begin
        case (current_state)
            GREEN:  next_state = YELLOW;
            YELLOW: next_state = RED;
            RED:    next_state = GREEN;
            default: next_state = GREEN;
        endcase
    end    // Luật chuyển trạng thái và phát xung nạp timer
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= GREEN;
            timer_load <= 1'b1;
            pending_state_change <= 1'b0;
        end else begin
            if (timer_zero && !pending_state_change) begin
                // Khi timer == 1, chuẩn bị chuyển trạng thái
                current_state <= next_state;
                timer_load <= 1'b1; 
                pending_state_change <= 1'b1;
            end else if (pending_state_change) begin 
                // Clock tiếp theo: tắt load signal
                timer_load <= 1'b0;
                pending_state_change <= 1'b0;
            end else begin
                timer_load <= 1'b0;
            end
        end
    end
endmodule