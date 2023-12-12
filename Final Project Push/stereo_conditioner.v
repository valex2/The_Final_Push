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
    input wire [16:0] note_data_a,
    input wire [16:0] note_data_b,
    input wire [16:0] note_data_c,
    output reg [15:0] sample_l,
    output reg [15:0] sample_r,
    input wire stereo_on
    );
    
    reg [15:0] aLeft,bLeft,cLeft,aRight,bRight,cRight; // 16 bit muxes
    wire [15:0] normal_out, left_out, right_out;
    
    always @(*) begin
        case(note_data_a[0]) // for data a
            1'b0 : begin  // 0 = right
                aLeft = 16'd0; 
                aRight = note_data_a[16:1]; 
            end
            1'b1 : begin  // 1 = left
                aRight = 16'd0; 
                aLeft = note_data_a[16:1];
            end
            default : begin // default do nothing
                aLeft = 16'd0; 
                aRight = 16'd0;
                end
        endcase
        case(note_data_b[0]) // for data b
            1'b0 : begin  // 0 = right
                bLeft = 16'd0; 
                bRight = note_data_b[16:1]; 
            end
            1'b1 : begin  // 1 = left
                bRight = 16'd0; 
                bLeft = note_data_b[16:1];
            end
            default : begin // default do nothing
                bLeft = 16'd0; 
                bRight = 16'd0;
                end
        endcase
        case(note_data_a[0]) // for data c
            1'b0 : begin  // 0 = right
                cLeft = 16'd0; 
                cRight = note_data_c[16:1]; 
            end
            1'b1 : begin  // 1 = left
                cRight = 16'd0; 
                cLeft = note_data_c[16:1];
            end
            default : begin // default do nothing
                cLeft = 16'd0; 
                cRight = 16'd0;
                end
        endcase
    end
    
    sample_sum unbothered_king( 
        .toneOneSample(note_data_a[16:1]),
        .toneTwoSample(note_data_b[16:1]),
        .toneThreeSample(note_data_c[16:1]),
        .toneFourSample(16'b0),
        .summed_output(normal_out)
    );
    
    sample_sum sum_left(
        .toneOneSample(aLeft>>>2),
        .toneTwoSample(bLeft>>>2),
        .toneThreeSample(cLeft>>>2),
        .toneFourSample(16'b0), // only need 3 channels
        .summed_output(left_out)
    );
    
    sample_sum sum_right(
    .toneOneSample(aRight>>>2),
    .toneTwoSample(bRight>>>2),
    .toneThreeSample(cRight>>>2),
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
