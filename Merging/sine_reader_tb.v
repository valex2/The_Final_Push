module sine_reader_tb();

    reg clk, reset, generate_next;
    reg [19:0] step_size;
    wire sample_ready;
    wire [15:0] sample;
    
    // Internal signals for debugging
    wire [21:0] current_address_debug;
    wire [15:0] new_sample_debug;

    sine_reader reader(
        .clk(clk),
        .reset(reset),
        .step_size(step_size),
        .generate_next(generate_next),
        .sample_ready(sample_ready),
        .sample(sample)
    );

    // Tapping into internal signals for debugging
    assign current_address_debug = reader.current_address;
    assign current_sample_debug = reader.current_sample;

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (20) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // Debug function to display values
    task debug_display();
        $display("Step Size: %d | Current Address: %b | Sample: %b", step_size, current_address_debug, sample);
    endtask

    // Tests
    initial begin
        // Start testing with a step size
        step_size = 20'b0010000000000000000;

        // Generate the full sine wave
        // If ROM has 1024 samples and step size is 10, we need to pulse 102 times to go through the full wave
        repeat(8008) begin
            #55 generate_next = 1;
            #10 generate_next = 0;
        end
    end

endmodule
