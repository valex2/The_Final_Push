`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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


module pwm #(
    parameter WIDTH = 8 // Number of bits for PWM resolution
)(
    input wire clk,               // Clock input
    input wire reset,             // Asynchronous reset
    input wire [WIDTH-1:0] duty,  // Duty cycle input
    output wire pwm_signal        // PWM output signal
);

    reg [WIDTH-1:0] counter_next;
    wire [WIDTH-1:0] counter;
    wire counter_reset;

    // Define the next counter value and the reset 
    always @* begin
        counter_next = counter + 1'b1;
    end
    assign counter_reset = (counter_next == 0); // Counter rolls over to 0

    dffr #(WIDTH) counter_ff (
        .clk(clk),
        .r(reset | counter_reset), // Reset counter on global reset or when it rolls over
        .d(counter_next),
        .q(counter)
    );

    // PWM comparator logic
    // The pwm_signal is high when the counter is less than the duty value
    assign pwm_signal = (counter < duty);

endmodule
