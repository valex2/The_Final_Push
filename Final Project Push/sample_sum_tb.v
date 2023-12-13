module sample_sum_tb();
reg [15:0] sample1, sample2, sample3, sample4;
wire [15:0] sample_out;

sample_sum sum_sim(
    .toneOneSample(sample1),
    .toneTwoSample(sample2),
    .toneThreeSample(sample3),
    .toneFourSample(sample4),
    .summed_output(sample_out)
);

    // Tests
    initial begin
        // Test 1: Averaging all zeroes
        sample1 = 16'd0;
        sample2 = 16'd0;
        sample3 = 16'd0;
        sample4 = 16'd0;
        #20  

        // Test 2: check all ones
        sample1 = 16'b1111111111111111;
        sample2 = 16'b1111111111111111;
        sample3 = 16'b1111111111111111;
        sample4 = 16'b1111111111111111;
        #20 
        
        // Test 3: some arbitrary values
        sample1 = 16'd10000;
        sample2 = 16'd0;
        sample3 = 16'd500;
        sample4 = 16'd10;
        #20
        
        // Test 4: rearranged values should get same output
        sample1 = 16'd10;
        sample2 = 16'd10000;
        sample3 = 16'd0;
        sample4 = 16'd500;

    end
    
endmodule