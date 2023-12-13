// copied from DragonScroll Dev FinalProject Dec. 11th 3:37 PM

//////////////////////////////////////////////////////////////////////////////////
// Company: Furious 101
// Engineer: Caleb Matthews and Vassilis Alexopoulos
// 
// Create Date: 12/01/2023 11:37:10 AM
// Design Name: 
// Module Name: stereo_conditioner
// Project Name: Operation ScatterSound
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////
module stereo_conditioner(
    input wire signed [15:0] note_data_a,
    input wire [1:0] stereo_a,
    
    input wire signed [15:0] note_data_b,
    input wire [1:0] stereo_b,
    
    input wire signed [15:0] note_data_c,
    input wire [1:0] stereo_c,
    
    output reg [15:0] sample_l,
    output reg [15:0] sample_r,
    
    input wire stereo_on,
    input wire clk
    );
    
    reg signed [15:0] aLeft,bLeft,cLeft,aRight,bRight,cRight; // 16 bit muxes
    wire [15:0] normal_out, left_out, right_out;
    
    wire signed [15:0] latched_a, latched_b, latched_c;
    dff #(48) timing_fixer( // adds slack to the system to avoid timing violations
        .clk(clk),
        .d({note_data_a, note_data_b, note_data_c}),
        .q({latched_a, latched_b, latched_c})
    );
    
    always @(*) begin
        case(stereo_a) // for data a
            2'b01 : begin  // 0 = right
                aLeft = 16'd0; 
                aRight = latched_a; 
            end
            2'b10 : begin  // 1 = left
                aLeft = latched_a;
                aRight = 16'd0; 
            end
            2'b11 : begin  // 1 = left
                aLeft = latched_a;
                aRight = latched_a; 
            end
            default : begin // default do nothing
                aLeft = 16'd0; 
                aRight = 16'd0;
            end
        endcase
        case(stereo_b) // for data a
            2'b01 : begin  
                bLeft = 16'd0; 
                bRight = latched_b; 
            end
            2'b10 : begin 
                bLeft = latched_b;
                bRight = 16'd0; 
            end
            2'b11 : begin  
                bLeft = latched_b;
                bRight = latched_b; 
            end
            default : begin // default do nothing
                bLeft = 16'd0; 
                bRight = 16'd0;
            end
         endcase
         case(stereo_c) 
            2'b01 : begin  
                cLeft = 16'd0; 
                cRight = latched_c; 
            end
            2'b10 : begin 
                cLeft = latched_c;
                cRight = 16'd0; 
            end
            2'b11 : begin  
                cLeft = latched_c;
                cRight = latched_c; 
            end
            default : begin // default do nothing
                cLeft = 16'd0; 
                cRight = 16'd0;
            end
        endcase
    end
    
   sample_sum unbothered_king( 
        .toneOneSample(latched_a),
        .toneTwoSample(latched_b),
        .toneThreeSample(latched_c),
        .toneFourSample(16'b0),
        .summed_output(normal_out)
    );
    
    sample_sum sum_left(
        .toneOneSample(aLeft), // used to have volue control
        .toneTwoSample(bLeft),
        .toneThreeSample(cLeft),
        .toneFourSample(16'b0), // only need 3 channels
        .summed_output(left_out)
    );
    
    sample_sum sum_right(
        .toneOneSample(aRight),
        .toneTwoSample(bRight),
        .toneThreeSample(cRight),
        .toneFourSample(16'b0), // only need 3 channels
        .summed_output(right_out)
    );
    
    always @(*) begin
        case(stereo_on)
            1'b1 : begin
                sample_l = left_out;
                sample_r = right_out;
                end
            1'b0 : begin
                sample_l = normal_out;
                sample_r = normal_out;
                end
            default : begin
                sample_l = normal_out;
                sample_r = normal_out;
                end
        endcase
    end
endmodule
