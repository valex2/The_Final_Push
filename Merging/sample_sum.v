//////////////////////////////////////////////////////////////////////////////////
// Company: Furious 101
// Engineer: DJ MC Squared
// Create Date: 12/03/2023 03:19:53 PM
// Design Name: Summin' Wrong
// Module Name: sample_sum
// Project Name: Lord Shen
// Target Devices: Ur mom
// Description: Quid Pro Quo (Summin' for Summin')
// Dependencies: For tax purposes only.
// Revision: Uno
//////////////////////////////////////////////////////////////////////////////////


module sample_sum(
    input wire signed [15:0] toneOneSample, 
    input wire signed [15:0] toneTwoSample, 
    input wire signed [15:0] toneThreeSample, 
    input wire signed [15:0] toneFourSample, 
    output wire [15:0] summed_output
    );

wire [15:0] s1;
wire [15:0] s2;
wire [15:0] s3;
wire [15:0] s4;

assign s1 = toneOneSample>>>2; 
assign s2 = toneTwoSample>>>2; 
assign s3 = toneThreeSample>>>2;
assign s4 = toneFourSample>>>2; 

assign summed_output = s1 + s2 + s3 + s4;
    
endmodule
