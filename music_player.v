//
//  music_player module
//
//  This music_player module connects up the MCU, song_reader, note_player,
//  beat_generator, and codec_conditioner. It provides an output that indicates
//  a new sample (new_sample_generated) which will be used in lab 5.
//

module music_player(
    // Standard system clock and reset
    input clk,
    input reset,

    // Our debounced and one-pulsed button inputs.
    input play_button,
    input next_button,

    // The raw new_frame signal from the ac97_if codec.
    input new_frame,

    // This output must go high for one cycle when a new sample is generated.
    output wire new_sample_generated,

    // Our final output sample to the codec. This needs to be synced to
    // new_frame.
    output wire [15:0] sample_out,
    output wire [15:0] sample_left,
    output wire [15:0] sample_right,
    output wire [5:0] current_note,
    output wire [5:0] current_note_duration
);
    // The BEAT_COUNT is parameterized so you can reduce this in simulation.
    // If you reduce this to 100 your simulation will be 10x faster.
    parameter BEAT_COUNT = 1000;


//
//  ****************************************************************************
//      Master Control Unit
//  ****************************************************************************
//   The reset_player output from the MCU is run only to the song_reader because
//   we don't need to reset any state in the note_player. If we do it may make
//   a pop when it resets the output sample.
//
 
    wire play;
    wire reset_player;
    wire [1:0] current_song;
    wire song_done;
    mcu mcu(
        .clk(clk),
        .reset(reset),
        .play_button(play_button),
        .next_button(next_button),
        .play(play),
        .reset_player(reset_player),
        .song(current_song),
        .song_done(song_done)
    );

//
//  ****************************************************************************
//      Song Reader
//  ****************************************************************************
//
    wire [15:0] data_out;
    wire new_note;
    wire note_done;
    song_reader song_reader(
        .clk(clk),
        .reset(reset | reset_player),
        .play(play),
        .song(current_song),
        .song_done(song_done),
        .out_data(data_out),
        .new_note(new_note),
        .note_done(note_done)
    );

//
//  ****************************************************************************
//      Note Arranger
//  ****************************************************************************
//  
    wire beat;
    
    wire note_1_done;
    wire note_1_load;
    wire [5:0] note_1_value;
    wire [5:0] note_1_duration;
    
    wire note_2_done;
    wire note_2_load;
    wire [5:0] note_2_value;
    wire [5:0] note_2_duration;
    
    wire note_3_done;
    wire note_3_load;
    wire [5:0] note_3_value;
    wire [5:0] note_3_duration;
    
    wire advance_time;
    note_arranger note_arranger(
        .clk(clk),
        .reset(reset),
        .beat(beat),
        .note_to_load(data_out),
        .load_new_note(new_note),
        .play_enable(play),
        
        .note_1_done(note_1_done),
        .note_1_load(note_1_load),
        .note_1(note_1_value),
        .note_1_duration(note_1_duration),
        
        .note_2_done(note_2_done),
        .note_2_load(note_2_load),
        .note_2(note_2_value),
        .note_2_duration(note_2_duration),
        
        .note_3_done(note_3_done),
        .note_3_load(note_3_load),
        .note_3(note_3_value),
        .note_3_duration(note_3_duration),
        
        .note_done(note_done),
        .advance_time(advance_time) 
    );

//   
//  ****************************************************************************
//      Note Players
//  ****************************************************************************
//  
    wire [3:0] overtones = 4'b1111;
    wire generate_next_sample;
    wire [16:0] note_1_sample;
    wire note_1_sample_ready;
    note_player note_player1(
        .clk(clk),
        .reset(reset),
        .play_enable(advance_time),
        .note_to_load(note_1_value),
        .input_duration(note_1_duration),
        .load_new_note(note_1_load),
        .done_with_note(note_1_done),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(note_1_sample),
        .new_sample_ready(note_1_sample_ready),
        .overtones(overtones)
    );
    
    wire [16:0] note_2_sample;
    wire note_2_sample_ready;
    note_player note_player2(
        .clk(clk),
        .reset(reset),
        .play_enable(advance_time),
        .note_to_load(note_2_value),
        .input_duration(note_2_duration),
        .load_new_note(note_2_load),
        .done_with_note(note_2_done),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(note_2_sample),
        .new_sample_ready(note_2_sample_ready),
        .overtones(overtones)
    );
    
    wire [16:0] note_3_sample;
    wire note_3_sample_ready;
    note_player note_player3(
        .clk(clk),
        .reset(reset),
        .play_enable(advance_time),
        .note_to_load(note_3_value),
        .input_duration(note_3_duration),
        .load_new_note(note_3_load),
        .done_with_note(note_3_done),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(note_3_sample),
        .new_sample_ready(note_3_sample_ready),
        .overtones(overtones)
    );
      
//   
//  ****************************************************************************
//      Sample Sum
//  ****************************************************************************
// 
//    wire [15:0] note_sample;
//    sample_sum summator(
//        .toneOneSample(note_1_sample), 
//        .toneTwoSample(note_2_sample),
//        .toneThreeSample(note_3_sample),
//        .toneFourSample(16'd0),
//        .summed_output(note_sample)
//    );

//    sample_sum sum_left(
//        .toneOneSample(note_1_sample),
//        .toneTwoSample(note_2_sample),
//        .toneThreeSample(note_3_sample),
//        .toneFourSample(16'b0), // only need 3 channels
//        .summed_output(note_sample)
//    );
    
//   
//  ****************************************************************************
//      Stereo Conditioner
//  ****************************************************************************
  
    stereo_conditioner stereo_heart(
        .note_data_a(note_1_sample),
        .note_data_b(note_2_sample),
        .note_data_c(note_3_sample),
        .sample_l(sample_left),
        .sample_r(sample_right)
    );
    
   
//  ****************************************************************************
//      Beat Generator
//  ****************************************************************************
//  By default this will divide the generate_next_sample signal (48kHz from the
//  codec's new_frame input) down by 1000, to 48Hz. If you change the BEAT_COUNT
//  parameter when instantiating this you can change it for simulation.
//  
    beat_generator #(.WIDTH(10), .STOP(BEAT_COUNT)) beat_generator(
        .clk(clk),
        .reset(reset),
        .en(generate_next_sample),
        .beat(beat)
    );

//  
//  ****************************************************************************
//      Codec Conditioner
//  ****************************************************************************
//  
    assign new_sample_generated = generate_next_sample;
    assign current_note = note_1_value;
    assign current_note_duration = note_1_duration[5:0];

    codec_conditioner codec_conditioner(
        .clk(clk),
        .reset(reset),
        .new_sample_in(sample_left),
        .latch_new_sample_in(note_1_sample_ready),
        .generate_next_sample(generate_next_sample),
        .new_frame(new_frame),
        .valid_sample(sample_out)
    );

endmodule
