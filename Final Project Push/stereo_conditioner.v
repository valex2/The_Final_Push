// copied from DragonScroll Dev FinalProject Dec. 11th 3:37 PM

//////////////////////////////////////////////////////////////////////////////////
// Company: Furious 101
// Engineer: Caleb Matthews
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
    
    output wire [15:0] sample_l,
    output wire [15:0] sample_r
    );
    
    reg signed [15:0] aLeft,bLeft,cLeft,aRight,bRight,cRight; // 16 bit muxes
    
    always @(*) begin
        case(stereo_a) // for data a
            2'b01 : begin  // 0 = right
                aLeft = 16'd0; 
                aRight = note_data_a; 
            end
            2'b10 : begin  // 1 = left
                aLeft = note_data_a;
                aRight = 16'd0; 
            end
            2'b11 : begin  // 1 = left
                aLeft = note_data_a;
                aRight = note_data_a; 
            end
            default : begin // default do nothing
                aLeft = 16'd0; 
                aRight = 16'd0;
            end
        endcase
        case(stereo_b) // for data a
            2'b01 : begin  // 0 = right
                aLeft = 16'd0; 
                aRight = note_data_b; 
            end
            2'b10 : begin  // 1 = left
                aLeft = note_data_b;
                aRight = 16'd0; 
            end
            2'b11 : begin  // 1 = left
                aLeft = note_data_b;
                aRight = note_data_b; 
            end
            default : begin // default do nothing
                aLeft = 16'd0; 
                aRight = 16'd0;
            end
         endcase
         case(stereo_c) // for data a
            2'b01 : begin  // 0 = right
                aLeft = 16'd0; 
                aRight = note_data_c; 
            end
            2'b10 : begin  // 1 = left
                aLeft = note_data_c;
                aRight = 16'd0; 
            end
            2'b11 : begin  // 1 = left
                aLeft = note_data_c;
                aRight = note_data_c; 
            end
            default : begin // default do nothing
                aLeft = 16'd0; 
                aRight = 16'd0;
            end
        endcase
    end
    
    sample_sum sum_left(
        .toneOneSample(aLeft),
        .toneTwoSample(bLeft),
        .toneThreeSample(cLeft),
        .toneFourSample(16'b0), // only need 3 channels
        .summed_output(sample_l)
    );
    
    sample_sum sum_right(
    .toneOneSample(aRight),
    .toneTwoSample(bRight),
    .toneThreeSample(cRight),
    .toneFourSample(16'b0), // only need 3 channels
    .summed_output(sample_r)
    );
endmodule
