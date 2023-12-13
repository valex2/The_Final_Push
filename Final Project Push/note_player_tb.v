//module note_player_tb();

//    reg clk, reset, play_enable, generate_next_sample;
//    reg [5:0] note_to_load;
//    reg [6:0] duration_to_load;
//    reg load_new_note;
//    reg harmonics_on;
//    reg [3:0] overtones;
//    wire done_with_note, new_sample_ready, beat;
//    wire [16:0] sample_out; // LSB is stereo left/right

//    note_player np(
//        .clk(clk),
//        .reset(reset),
//        .play_enable(play_enable),
//        .note_to_load(note_to_load),
//        //.input_duration(duration_to_load),
//        .load_new_note(load_new_note),
//        //.harmonics_on(harmonics_on),
//        //.overtones(overtones),
//        .done_with_note(done_with_note),
//        .beat(beat),
//        .generate_next_sample(generate_next_sample),
//        .sample_out(sample_out),
//        .new_sample_ready(new_sample_ready)
//    );

//    beat_generator #(.WIDTH(4), .STOP(10)) beat_generator(
//        .clk(clk),
//        .reset(reset),
//        .en(1'b1),
//        .beat(beat)
//    );

//    // Clock and reset
//    initial begin
//        clk = 1'b0;
//        reset = 1'b1;
//        repeat (4) #5 clk = ~clk;
//        reset = 1'b0;
//        forever #5 clk = ~clk;
//    end

//    // Tests
//    initial begin
//        // Initialize control signals
//        play_enable = 1'b0;
//        load_new_note = 1'b0;
//        generate_next_sample = 1'b0;
//        overtones = 4'b1111;
//        harmonics_on = 1'b1;

//        // Test 1a: Loading a note and playing it - harmonics on, all 1s - expect equal values for the first three outputs
//        note_to_load = 7'd10;        // Arbitrary
//        duration_to_load = 6'd2;     // Play for 2 beats
//        load_new_note = 1;
//        #30 load_new_note = 0;       

//        play_enable = 1;

//        // Waiting for the note to finish playing
//        wait(done_with_note == 1);
//        $display("1. note 1a done playing!");

//        harmonics_on = 1'b0;
//        // Test B: Loading a note and playing it - harmonics off all 1s
//        note_to_load = 7'd10;        // Arbitrary
//        duration_to_load = 6'd2;     // Play for 2 beats
//        load_new_note = 1;
//        #30 load_new_note = 0;       

//        play_enable = 1;

//        // Waiting for the note to finish playing - harmonics on all 0s
//        wait(done_with_note == 1);
//        $display("1. note 1b done playing!");
//        harmonics_on = 1'b0;
//        overtones = 4'b0000;
//        // Test 1: Loading a note and playing it    
//        note_to_load = 7'd10;        // Arbitrary
//        duration_to_load = 6'd2;     // Play for 2 beats
//        load_new_note = 1;
//        #30 load_new_note = 0;       

//        play_enable = 1;

//        // Waiting for the note to finish playing - harmonics on alternating 1s and 0s
//        wait(done_with_note == 1);
//        $display("1. note 1c done playing!");

//        harmonics_on = 1'b1;
//        overtones = 4'b0101;
//        // Test 1d: Loading a note and playing it    
//        note_to_load = 7'd10;        // Arbitrary
//        duration_to_load = 6'd2;     // Play for 2 beats
//        load_new_note = 1;
//        #30 load_new_note = 0;       

//        play_enable = 1;

//        // Waiting for the note to finish playing
//        wait(done_with_note == 1);
//        $display("1. note 1d done playing!");
        






//        // Test 2: waiting for next note (whether loading happenings properely)
//        note_to_load = 7'd20;        // Arbitraru
//        duration_to_load = 6'd5;     // Play for 5 beats
//        #20 // acount for handshake delay
//        load_new_note = 1;
//        #10 load_new_note = 0;  
        
//        play_enable = 1;
        
//        wait(done_with_note == 1);
//        $display("2. note 2 done playing!");
        
//        // Test 3: new note, but disable playing for two beats, then pick up again
//        note_to_load = 7'd28;        // Arbitraru
//        duration_to_load = 6'd6;     // Play for 5 beats
//        #20 // acount for handshake delay
//        load_new_note = 1;
//        #10 load_new_note = 0;  
//        play_enable = 1;
//        #300 // two beats
//        play_enable = 0;
//        #300 // two beats
//        play_enable = 1;

//        // Waiting for the note to finish playing
//        wait(done_with_note == 1);
//        $display("3. Note 2 done playing!");

//        // Test 4: Sample generation request while play_enable is off (expect no sample change)
//        #10
//        play_enable = 0;
//        #10
//        generate_next_sample = 1;
//        #10 generate_next_sample = 0; // we expect the sample to not change
//        #10 play_enable = 1;

//        // Test: Sample generation request while note is done
//        #100 generate_next_sample = 1;
//        #10 generate_next_sample = 0;
        
//        // Test: Play shortest duration
//        note_to_load = 7'd5;      
//        duration_to_load = 6'd1;     // Play for 1 beat
//        #20 
//        load_new_note = 1;
//        #10 load_new_note = 0; 
//        play_enable = 1;

//        wait(done_with_note == 1);
//        $display("4. Shortest duration note played!");
        
//        // Test: play 0 duration
//        note_to_load = 7'd5;
//        duration_to_load = 6'd0;
//        #20
//        load_new_note = 1;
//        #10 load_new_note = 0;
//        play_enable = 1;

//        // Test: load after 0
//        note_to_load = 7'd15;        
//        duration_to_load = 6'd2;   // Play for 2 beats
//        #20 
//        load_new_note = 1;
//        #10 load_new_note = 0; 
//        play_enable = 1;

//        wait(done_with_note == 1);
//        $display("5. load after 0 note");
        
//        // Test 7: Toggle play_enable during sample generation
//        note_to_load = 7'd15; 
//        duration_to_load = 6'd10;    // Play for 10 beats
//        #20 
//        load_new_note = 1;
//        #10 load_new_note = 0; 
//        play_enable = 1;
//        #100 
//        generate_next_sample = 1;
//        #10 generate_next_sample = 0;   
//        #20 play_enable = 0;
//        #10
//        generate_next_sample = 1;
//        #10 generate_next_sample = 0;  
//        #50 play_enable = 1;          // Enable play again
//        #10
//        generate_next_sample = 1;
//        #10 generate_next_sample = 0; // Stop sample generation
        
//        #10
//        repeat (5) begin
//            #30
//            generate_next_sample = 1;
//            #30 generate_next_sample = 0;
//        end
//        $display("6. Toggled play_enable during sample generation!");
        
//        wait(done_with_note == 1);
//        $display("7. Toggled play_enable during sample generation!");

//        // Test 8: No note loaded but play enabled
//        #40 play_enable = 1;
//        #40 
//        if (!done_with_note) $display("8. No new note loaded but play enabled");
        
//        // Test 9: first load generation test
//        note_to_load = 7'd35;      
//        duration_to_load = 6'd12;    // Play for 12 beats
//        #20 
//        load_new_note = 1;
//        #10 load_new_note = 0;  
//        repeat (5) begin
//            #10
//            generate_next_sample = 1;
//            #10 generate_next_sample = 0;
//        end
//         $display("8. Toggled play_enable during sample generation!");

//        // Test 9: Load new note while another is playing
//        note_to_load = 7'd35;      
//        duration_to_load = 6'd12;    // Play for 12 beats
//        #20 
//        load_new_note = 1;
//        #10 load_new_note = 0;  
//        play_enable = 1;
//        #50                          
//        note_to_load = 7'd45;      
//        duration_to_load = 6'd15;    
//        load_new_note = 1;          
//        #10 load_new_note = 0; 

//        wait(done_with_note == 1);
//        $display("9. Attempted to load a new note while another was playing");

//        // Test 10: Test 0 note duration edge case
//        note_to_load = 7'd50; 
//        duration_to_load = 6'd0;     // Edge case: 0 beat duration
//        #20 
//        load_new_note = 1;
//        #10 load_new_note = 0; 
//        play_enable = 1;

//        wait(done_with_note == 1);
//        $display("10. 0 note duration edge case tested");

//        if (new_sample_ready) $display("New Sample Ready: %h", sample_out);
        
                
//       $finish;
//    end
    
//endmodule