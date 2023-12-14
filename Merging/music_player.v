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
    
    input stereo_on,     // turns stereo effects on or off
    
    input harmonics_on, // turns harmonics on or off
    input wire [3:0] overtones, // 0000 corresponds to all at maximum volume, 0111 corresponds to fundamentals at full, all others at half

    // This output must go high for one cycle when a new sample is generated.
    output wire new_sample_generated,

    // Our final output sample to the codec. This needs to be synced to new_frame.
    output wire [15:0] sample_left,
    output wire [15:0] sample_right,
    output wire [15:0] sample_normal,
    
    output wire [5:0] current_note_1,
    output wire [5:0] current_note_duration_1,
    output wire new_note_available_1,

    output wire [5:0] current_note_2,
    output wire [5:0] current_note_duration_2,
    output wire new_note_available_2,

    output wire [5:0] current_note_3,
    output wire [5:0] current_note_duration_3,
    output wire new_note_available_3
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
    wire [1:0] note_1_stereo;
    
    wire note_2_done;
    wire note_2_load;
    wire [5:0] note_2_value;
    wire [5:0] note_2_duration;
    wire [1:0] note_2_stereo;
    
    wire note_3_done;
    wire note_3_load;
    wire [5:0] note_3_value;
    wire [5:0] note_3_duration;
    wire [1:0] note_3_stereo;
    
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
        .note_1_stereo(note_1_stereo),
        
        .note_2_done(note_2_done),
        .note_2_load(note_2_load),
        .note_2(note_2_value),
        .note_2_duration(note_2_duration),
        .note_2_stereo(note_2_stereo),
        
        .note_3_done(note_3_done),
        .note_3_load(note_3_load),
        .note_3(note_3_value),
        .note_3_duration(note_3_duration),
        .note_3_stereo(note_3_stereo),
        
        .note_done(note_done),
        .advance_time(advance_time) 
    );

//   
//  ****************************************************************************
//      Note Players
//  ****************************************************************************
//  
    wire generate_next_sample;
    wire [15:0] note_1_sample;
    wire note_1_sample_ready;
    wire [1:0] note_1_stereo_out;
    note_player note_player1(
        .clk(clk),
        .reset(reset),
        .play_enable(advance_time),
        .note_to_load(note_1_value),
        .duration_to_load(note_1_duration),
        .stereo_side_to_load(note_1_stereo),
        .load_new_note(note_1_load),
        .done_with_note(note_1_done),
        .beat(beat),
        .generate_next_sample(new_sample_generated),
        .sample_out(note_1_sample),
        .new_sample_ready(note_1_sample_ready),
        .stereo_side_out(note_1_stereo_out),
        .harmonics_on(harmonics_on),
        .overtones(overtones)
    );
    
    wire [15:0] note_2_sample;
    wire note_2_sample_ready;
    wire [1:0] note_2_stereo_out;
    note_player note_player2(
        .clk(clk),
        .reset(reset),
        .play_enable(advance_time),
        .note_to_load(note_2_value),
        .duration_to_load(note_2_duration),
        .stereo_side_to_load(note_2_stereo),
        .load_new_note(note_2_load),
        .done_with_note(note_2_done),
        .beat(beat),
        .generate_next_sample(new_sample_generated),
        .sample_out(note_2_sample),
        .new_sample_ready(note_2_sample_ready),
        .stereo_side_out(note_2_stereo_out),
        .harmonics_on(harmonics_on),
        .overtones(overtones)
    );
    
    wire [15:0] note_3_sample;
    wire note_3_sample_ready;
    wire [1:0] note_3_stereo_out;
    note_player note_player3(
        .clk(clk),
        .reset(reset),
        .play_enable(advance_time),
        .note_to_load(note_3_value),
        .duration_to_load(note_3_duration),
        .stereo_side_to_load(note_3_stereo),
        .load_new_note(note_3_load),
        .done_with_note(note_3_done),
        .beat(beat),
        .generate_next_sample(new_sample_generated),
        .sample_out(note_3_sample),
        .new_sample_ready(note_3_sample_ready),
        .stereo_side_out(note_3_stereo_out),
        .harmonics_on(harmonics_on),
        .overtones(overtones)
    );
    
    assign new_note_available_1 = note_1_load;
    assign new_note_available_2 = note_2_load;
    assign new_note_available_3 = note_3_load;

    dffre #(.WIDTH(6)) dff_current_note1 (.clk(clk), .r(reset), .en(note_1_load), .d(note_1_value), .q(current_note_1));
    dffre #(.WIDTH(6)) dff_current_duration1 (.clk(clk), .r(reset), .en(note_1_load), .d(note_1_duration), .q(current_note_duration_1));
    dffre #(.WIDTH(6)) dff_current_note2 (.clk(clk), .r(reset), .en(note_2_load), .d(note_2_value), .q(current_note_2));
    dffre #(.WIDTH(6)) dff_current_duration2 (.clk(clk), .r(reset), .en(note_2_load), .d(note_2_duration), .q(current_note_duration_2));
    dffre #(.WIDTH(6)) dff_current_note3 (.clk(clk), .r(reset), .en(note_3_load), .d(note_3_value), .q(current_note_3));
    dffre #(.WIDTH(6)) dff_current_duration3 (.clk(clk), .r(reset), .en(note_3_load), .d(note_3_duration), .q(current_note_duration_3));
//   
//  ****************************************************************************
//      Sample Sum
//  ****************************************************************************
// 

      wire [15:0] left_sample, right_sample;
      wire [15:0] normal_sample;
      stereo_conditioner steroids (
          .note_data_a(note_1_sample),
          .stereo_a(note_1_stereo_out),
          .note_data_b(note_2_sample),
          .stereo_b(note_2_stereo_out),
          .note_data_c(note_3_sample),
          .stereo_c(note_3_stereo_out),
          .sample_l(left_sample),
          .sample_r(right_sample),
          .sample_normal(normal_sample),
          .stereo_on(stereo_on),
          .clk(clk)
      );

//   
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
//  need to sync stuff to a new frame
//    assign new_sample_generated = generate_next_sample;
    
    dff #(1) generate_delay( // adds slack to the system to avoid timing violations
        .clk(clk),
        .d(generate_next_sample),
        .q(new_sample_generated)
    );
    
    codec_conditioner codec_conditioner_left(
        .clk(clk),
        .reset(reset),
        .new_sample_in(left_sample),
        .latch_new_sample_in(note_1_sample_ready),
        .generate_next_sample(generate_next_sample),
        .new_frame(new_frame),
        .valid_sample(sample_left)
    );
    
    wire generate_next_sample_redundant_one; // captures the output from the unused right codec
    codec_conditioner codec_conditioner_right(
        .clk(clk),
        .reset(reset),
        .new_sample_in(right_sample),
        .latch_new_sample_in(note_1_sample_ready),
        .generate_next_sample(generate_next_sample_redundant_one),
        .new_frame(new_frame),
        .valid_sample(sample_right)
    );
    
    wire generate_next_sample_redundant_two;
    codec_conditioner codec_conditioner_normal(
        .clk(clk),
        .reset(reset),
        .new_sample_in(normal_sample),
        .latch_new_sample_in(note_1_sample_ready),
        .generate_next_sample(generate_next_sample_redundant_two),
        .new_frame(new_frame),
        .valid_sample(sample_normal)
    );

endmodule
