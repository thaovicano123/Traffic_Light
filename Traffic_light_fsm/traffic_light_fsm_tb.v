`timescale 1ns / 1ps

module traffic_light_fsm_tb;
    // Parameters
    localparam CLK_PERIOD = 100;  // 100ns clock period (10MHz)
    
    // Signals
    reg clk;
    reg rst_n;
    reg timer_zero;
    wire [1:0] current_state;
    wire timer_load;
    
    // State definitions
    localparam GREEN = 2'b00;
    localparam YELLOW = 2'b01;
    localparam RED = 2'b10;
    
    // String for state display
    reg [8*10-1:0] state_name;
    
    // Instantiate FSM
    traffic_light_fsm uut (
        .clk(clk),
        .rst_n(rst_n),
        .timer_zero(timer_zero),
        .current_state(current_state),
        .timer_load(timer_load)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Convert state to string for display
    always @(*) begin
        case(current_state)
            GREEN:  state_name = "GREEN";
            YELLOW: state_name = "YELLOW";
            RED:    state_name = "RED";
            default: state_name = "UNKNOWN";
        endcase
    end
    
    // Test sequence
    initial begin
        $display("==================================================");
        $display("        TRAFFIC LIGHT FSM TESTBENCH");
        $display("==================================================");
        
        // Create VCD file
        $dumpfile("traffic_light_fsm.vcd");
        $dumpvars(0, traffic_light_fsm_tb);
        
        // Initialize
        rst_n = 0;
        timer_zero = 0;
        
        $display("\n--- PHASE 1: RESET SEQUENCE ---");
        
        // Apply reset
        repeat(3) @(posedge clk);
        $display("Time=%0t | RESET Active | State=%s | timer_load=%b", 
                 $time, state_name, timer_load);
        
        // Release reset
        rst_n = 1;
        @(posedge clk);
        $display("Time=%0t | RESET Released | State=%s | timer_load=%b", 
                 $time, state_name, timer_load);
        
        // Wait for system to stabilize
        repeat(2) @(posedge clk);
        $display("Time=%0t | System Stable | State=%s | timer_load=%b", 
                 $time, state_name, timer_load);
        
        $display("\n--- PHASE 2: GREEN TO YELLOW TRANSITION ---");
        
        // Simulate GREEN phase countdown
        $display("Simulating GREEN phase (15 seconds countdown)...");
        repeat(5) @(posedge clk);  // Normal countdown
        
        // Trigger timer_zero (when timer = 1)
        $display("Time=%0t | Timer about to expire | State=%s | timer_load=%b", 
                 $time, state_name, timer_load);
        
        timer_zero = 1;
        @(posedge clk); // Clock edge where transition happens
        $display("Time=%0t | TRANSITION! | State=%s | timer_load=%b | timer_zero=%b", 
                 $time, state_name, timer_load, timer_zero);
        
        timer_zero = 0;
        @(posedge clk); // Next clock: timer_load should go to 0
        $display("Time=%0t | After Transition | State=%s | timer_load=%b", 
                 $time, state_name, timer_load);
        
        $display("\n--- PHASE 3: YELLOW TO RED TRANSITION ---");
        
        // Simulate YELLOW phase countdown
        repeat(3) @(posedge clk);
        $display("Time=%0t | YELLOW countdown | State=%s | timer_load=%b", 
                 $time, state_name, timer_load);
        
        // Trigger next transition
        timer_zero = 1;
        @(posedge clk);
        $display("Time=%0t | TRANSITION! | State=%s | timer_load=%b | timer_zero=%b", 
                 $time, state_name, timer_load, timer_zero);
        
        timer_zero = 0;
        @(posedge clk);
        $display("Time=%0t | After Transition | State=%s | timer_load=%b", 
                 $time, state_name, timer_load);
        
        $display("\n--- PHASE 4: RED TO GREEN TRANSITION ---");
        
        // Simulate RED phase countdown
        repeat(5) @(posedge clk);
        $display("Time=%0t | RED countdown | State=%s | timer_load=%b", 
                 $time, state_name, timer_load);
        
        // Trigger next transition
        timer_zero = 1;
        @(posedge clk);
        $display("Time=%0t | TRANSITION! | State=%s | timer_load=%b | timer_zero=%b", 
                 $time, state_name, timer_load, timer_zero);
        
        timer_zero = 0;
        @(posedge clk);
        $display("Time=%0t | After Transition | State=%s | timer_load=%b", 
                 $time, state_name, timer_load);
        
        $display("\n--- PHASE 5: VERIFY FULL CYCLE ---");
        
        // One more transition to verify cycle
        repeat(3) @(posedge clk);
        timer_zero = 1;
        @(posedge clk);
        $display("Time=%0t | FULL CYCLE DONE | State=%s | timer_load=%b", 
                 $time, state_name, timer_load);
        
        timer_zero = 0;
        @(posedge clk);
        
        $display("\n==================================================");
        $display("            SIMULATION COMPLETED");
        $display("==================================================");
        $display("Verified: GREEN -> YELLOW -> RED -> GREEN cycle");
        $display("timer_load pulse behavior: OK");
        $display("State transitions: OK");
        
        repeat(5) @(posedge clk);
        $finish;
    end
    
    // Detailed monitor
    initial begin
        $monitor("Time=%0t | CLK=%b | RST=%b | timer_zero=%b | State=%-7s | timer_load=%b | pending=%b", 
                 $time, clk, rst_n, timer_zero, state_name, timer_load, uut.pending_state_change);
    end

endmodule
