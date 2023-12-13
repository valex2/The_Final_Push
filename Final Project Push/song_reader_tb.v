module song_reader_tb();
    reg clk, reset, play, note_done;
    reg [1:0] song;
    wire [15:0] out_data;
    wire song_done, new_note;

    song_reader dut(
        .clk(clk),
        .reset(reset),
        .play(play),
        .song(song),
        .song_done(song_done),
        .out_data(out_data),
        .new_note(new_note),
        .note_done(note_done)
    );

    // Clock and reset generation
    initial begin
        clk = 1'b0;
        reset = 1'b1; // Assert the reset
        // Apply clock cycles during reset
        repeat (4) #5 clk = ~clk;
        reset = 1'b0; // De-assert the reset
        // Generate continuous clock
        forever #5 clk = ~clk;
    end

    // Test scenarios
    initial begin
        // Initialize inputs
        play = 1'b0;
        song = 2'b00;
        note_done = 1'b0;

        // Wait for reset to de-assert
        wait(reset == 1'b0);
        #10; // Wait for a few clock cycles after reset

        // Test Case 1: Play song 0
        $display("Test Case 1: Play song 0");
        song = 2'b00; // Select song 0
        play = 1'b1;  // Start playing the song
        #100; // Simulate time for song to potentially play

        // Simulate each note being played by asserting note_done
        repeat (32) begin // Assuming a max of 32 notes per song
            note_done = 1'b1;
            #10; // Duration for each note (this is an assumption)
            note_done = 1'b0;
            #50; // Wait between notes
        end

        play = 1'b0; // Stop playing
        #50; // Wait for some clock cycles between scenarios

        // Test Case 3: Play song 2
        $display("Test Case 2: Play song 1");
        song = 2; // Select song 1
        play = 1'b1;  // Start playing the song
        #100; // Simulate time for song to potentially play

        // Simulate each note being played by asserting note_done
        repeat (32) begin // Assuming a max of 32 notes per song
            note_done = 1'b1;
            #10; // Duration for each note (this is an assumption)
            note_done = 1'b0;
            #10; // Wait between notes
        end

        play = 1'b0; // Stop playing
        #50; // Wait for some clock cycles
        
               // Test Case 2: Play song 1
        $display("Test Case 2: Play song 1");
        song = 2'b01; // Select song 1
        play = 1'b1;  // Start playing the song
        #100; // Simulate time for song to potentially play

        // Simulate each note being played by asserting note_done
        repeat (32) begin // Assuming a max of 32 notes per song
            note_done = 1'b1;
            #10; // Duration for each note (this is an assumption)
            note_done = 1'b0;
            #10; // Wait between notes
        end

        play = 1'b0; // Stop playing
        #50; // Wait for some clock cycles
               


        $display("Simulation finished.");
        $finish; // End of simulation
    end

endmodule
