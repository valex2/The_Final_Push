//////////////////////////////////////////////////////////////////////////////////
// Company: Furious 101
// Engineer: Vassilis Alexopoulos
// 
// Create Date: 12/01/2023 03:12:02 PM
// Design Name: note_arranger v1
// Module Name: note_arranger
// Project Name: Lord Chen
// Target Devices: pynq baddie
// Tool Versions: 
// Description: arrange those notes
// 
// Dependencies: everything
// 
// Revision: first one?
// Revision 0.01 - File Created
// Additional Comments: please work -- so real
//////////////////////////////////////////////////////////////////////////////////
module note_arranger_tb();
    reg clk, reset, load_new_note, play_enable;
    wire advance_time, note_done;
    reg [15:0] note_to_load;
     wire beat;
    
    reg note_1_done;
    wire note_1_load;
    wire [5:0] note_1, note_1_duration;
    
    reg note_2_done;
    wire note_2_load;
    wire [5:0] note_2, note_2_duration;
    
    reg note_3_done;
    wire note_3_load;
    wire [5:0] note_3, note_3_duration;

    note_arranger na(
        .clk(clk),
        .reset(reset),
        .load_new_note (load_new_note),
        .note_to_load (note_to_load),
        .play_enable (play_enable),
        .beat (beat),
        
        .note_1_load (note_1_load),
        .note_1 (note_1),
        .note_1_duration (note_1_duration),
        .note_1_done (note_1_done),
        
        .note_2_load (note_2_load),
        .note_2 (note_2),
        .note_2_duration (note_2_duration),
        .note_2_done (note_2_done),
        
        .note_3_load (note_3_load),
        .note_3 (note_3),
        .note_3_duration (note_3_duration),
        .note_3_done (note_3_done),
        
        .note_done(note_done),
        .advance_time (advance_time)
    );
    
    beat_generator #(.WIDTH(4), .STOP(10)) beat_generator(
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .beat(beat)
    );
    
    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // tests
    
    // note to load nneds inputs
    
    
    initial begin
        // initialize control signals
        load_new_note = 1'b0;
        play_enable = 1'b1;
        note_1_done = 1'b0;
        
        // Test 1: Schedule Note 1 To Play
        #40
        load_new_note = 1'b1;
        note_to_load = 16'b0101010111111000; // schedule note 101010 to play for 111111
        
        #10
        load_new_note = 1'b0;
        
        // Test 2: Input Play Note, load and play everything
        #40
        load_new_note = 1'b1;
        note_to_load = 16'b1000000000011000; // play for 000011 = 3 beats
        #10
        load_new_note = 1'b0;
        
        #355
        note_1_done = 1'b1;
        #10
        note_1_done = 1'b0;
        
        
    end
endmodule
