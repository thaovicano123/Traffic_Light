module tb_timer;
    reg clk;
    reg rst_n;
    reg en;
    reg [1:0] current_state;
    wire [31:0] timer;
    wire [31:0] timer_seconds; // Intermediate wire for timer in seconds
    
    // Định nghĩa các trạng thái
    localparam GREEN = 2'b00;
    localparam YELLOW = 2'b01;
    localparam RED = 2'b10;
    
    // Định nghĩa thời gian cho mô phỏng (giống với timer.v)
    localparam SIM_ONE_SECOND = 1;   // 1 chu kỳ clock = 1 giây (không nhân thêm)
    localparam SIM_GREEN_TIME = 15;   // 15 giây đèn xanh
    localparam SIM_YELLOW_TIME = 3;   // 3 giây đèn vàng
    localparam SIM_RED_TIME = 18;     // 18 giây đèn đỏ

    // Tính toán số giây từ timer
    assign timer_seconds = timer / SIM_ONE_SECOND;

    // Instantiate the timer module với giá trị thời gian đã được thay thế
    timer #(
        .ONE_SECOND(SIM_ONE_SECOND),
        .GREEN_TIME(SIM_GREEN_TIME),
        .YELLOW_TIME(SIM_YELLOW_TIME),
        .RED_TIME(SIM_RED_TIME)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .load(en), // Đúng với tên cổng mới
        .current_state(current_state),
        .timer(timer)
    );

    // Clock generation - 10MHz (chu kỳ 100ns)
    initial begin
        clk = 0;
        forever #50 clk = ~clk;  // Mỗi chu kỳ clock là 100ns, tương đương 10MHz
    end

    // Testbench logic
    initial begin
        // Khởi tạo
        rst_n = 0;
        en = 0;
        current_state = GREEN;
        
        // Reset và khởi tạo
        #100 rst_n = 1;
        
        // Bắt đầu với đèn xanh
        #100 current_state = GREEN;
        en = 1;  // Enable để load giá trị
        #100;    // Đợi để đảm bảo giá trị được load
        $display("Đèn XANH bắt đầu với timer = %d giây", timer_seconds);
        en = 0;  // Disable để bắt đầu đếm ngược
        
        // Đợi cho đến khi timer về 0
        wait(timer == 0);
        $display("Đèn XANH đã hết thời gian, chuyển sang đèn VÀNG");
        
        // Chuyển sang đèn vàng
        #100 current_state = YELLOW;
        en = 1;  // Enable để load giá trị
        #100;    // Đợi để đảm bảo giá trị được load
        $display("Đèn VÀNG bắt đầu với timer = %d giây", timer_seconds);
        en = 0;  // Disable để bắt đầu đếm ngược
        
        // Đợi cho đến khi timer về 0
        wait(timer == 0);
        $display("Đèn VÀNG đã hết thời gian, chuyển sang đèn ĐỎ");
        
        // Chuyển sang đèn đỏ
        #100 current_state = RED;
        en = 1;  // Enable để load giá trị
        #100;    // Đợi để đảm bảo giá trị được load
        $display("Đèn ĐỎ bắt đầu với timer = %d giây", timer_seconds);
        en = 0;  // Disable để bắt đầu đếm ngược
        
        // Đợi cho đến khi timer về 0
        wait(timer == 0);
        $display("Đèn ĐỎ đã hết thời gian, chuyển sang đèn XANH");
        
        // Quay lại đèn xanh để hoàn thành chu kỳ
        #100 current_state = GREEN;
        en = 1;  // Enable để load giá trị
        #100;    // Đợi để đảm bảo giá trị được load
        $display("Đèn XANH bắt đầu với timer = %d giây", timer_seconds);
        en = 0;  // Disable để bắt đầu đếm ngược
        
        // Đợi một khoảng thời gian ngắn để xem kết quả
        #500;
        
        // Kết thúc
        $finish;
    end

    // Monitor và hiển thị giá trị
    initial begin
        $monitor("Time=%t: state=%b, en=%b, rst_n=%b, timer=%d giây", 
                 $time, current_state, en, rst_n, timer_seconds);
    end
    
    // Tạo file VCD để xem trên GTKWave
    initial begin
        $dumpfile("timer.vcd");
        $dumpvars(0, tb_timer);
    end
endmodule
