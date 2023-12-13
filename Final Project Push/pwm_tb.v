//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Vassilis Alexopoulos
// 
// Create Date: 12/13/2023 02:20:24 AM
// Design Name: 
// Module Name: pwm_tb
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
module pwm_tb();
    reg clk, reset;
    reg [3:0] duty;
    wire pwm_signal;
    
    pwm pwmer (
        .clk(clk),
        .reset(reset),
        .duty(duty),
        .pwm_signal(pwm_signal)
    );

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        duty = 4'b1000; 
        #400000000
        duty = 4'b0001;
    end

endmodule
