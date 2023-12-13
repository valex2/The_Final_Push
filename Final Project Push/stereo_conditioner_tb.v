//////////////////////////////////////////////////////////////////////////////////
// Company: Furious 101
// Engineer: Iykyk
// 
// Create Date: 12/03/2023 04:28:46 PM
// Design Name: Silky Smooth
// Module Name: stereo_conditioner_tb
// Project Name: Lord Shen
// Target Devices: Hair
// Tool Versions: Hypo-Allergenic, No-tears
// Description: Bc stereo_shampoo was already taken
// Dependencies: Decent hygiene
//////////////////////////////////////////////////////////////////////////////////
module stereo_conditioner_tb();

reg [16:0] note_data_a,note_data_b, note_data_c; // 17 bits
reg stereo_on;
wire [15:0] sample_l, sample_r; // 16 bits

stereo_conditioner thors_beard(
    .note_data_a(note_data_a),
    .note_data_b(note_data_b),
    .note_data_c(note_data_c),
    .stereo_on(stereo_on),
    .sample_l(sample_l),
    .sample_r(sample_r)
);


    // Tests
    initial begin
        stereo_on = 1'b0;
        // Test 1: All odd
        note_data_a = 17'd13;
        note_data_b = 17'd277;
        note_data_c = 17'd145;
        #20  

        // Test 2: check all even
        note_data_a = 17'd14;
        note_data_b = 17'd278;
        note_data_c = 17'd146;
        #20 
        
        // Test 3: multi-channel output
        note_data_a = 17'd14;
        note_data_b = 17'd277;
        note_data_c = 17'd144;
        #20
        
        // Test 4: check expected behavior for all 0's
        note_data_a = 17'd0;
        note_data_b = 17'd0;
        note_data_c = 17'd0;

        //check toggleability
        stereo_on = 1'b1;
        // Test 1: All odd
        note_data_a = 17'd13;
        note_data_b = 17'd277;
        note_data_c = 17'd145;
        #20  

        // Test 2: check all even
        note_data_a = 17'd14;
        note_data_b = 17'd278;
        note_data_c = 17'd146;
        #20 
        
        // Test 3: multi-channel output
        note_data_a = 17'd14;
        note_data_b = 17'd277;
        note_data_c = 17'd144;
        #20
        
        // Test 4: check expected behavior for all 0's
        note_data_a = 17'd0;
        note_data_b = 17'd0;
        note_data_c = 17'd0;
    end
endmodule