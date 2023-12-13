//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Alaska
// 
// Create Date: 12/12/2023 12:51:26 AM
// Design Name: 
// Module Name: pwm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module pwm (
    input wire clk,               // Clock input
    input wire reset,             // Asynchronous reset
    input wire [3:0] duty,  // Duty cycle input
    output wire pwm_signal        // PWM output signal
);

    // latch onto the duty cycle
    wire [3:0] duty_latched;
    dff #(4) duty_reg(
        .clk(clk),
        .d(duty),
        .q(duty_latched)
    );

    reg [27:0] counter_next;
    wire [27:0] counter;
    dff #(28) counter_reg(
        .clk(clk),
        .d(counter_next),
        .q(counter)
    );
    
    reg pwm_signal_next;
    dff #(1) pwm_signal_reg (
        .clk(clk),
        .d(pwm_signal_next),
        .q(pwm_signal)
    );

    always @(*) begin
        pwm_signal_next = reset ? 1'b0 : pwm_signal;
        counter_next = reset ? 28'd0 : (counter + 28'd1);
    
        if (counter_next > (duty_latched << 24)) begin
            counter_next = 28'd0;
            pwm_signal_next = ~pwm_signal;
        end
            
    end
    



//    wire [WIDTH + BITS - 1:0] period = (duty << BITS); // the modulation period
//    reg [WIDTH + BITS - 1:0] counter_next;
//    wire [WIDTH + BITS - 1:0] counter;
//    wire counter_reset;

//    // Define the next counter value and then reset 
//    always @* begin
//        counter_next = (counter_next == period) ? 7'd0 : counter + 7'd1;
        
//        if (counter_next == period) begin
//            pwm_signal = ~pwm_signal;
//        end
//    end

//    dffr #(WIDTH + BITS) counter_ff (
//        .clk(clk),
//        .r(reset), // Reset counter on global reset or when it rolls over
//        .d(counter_next),
//        .q(counter)
//    );
endmodule