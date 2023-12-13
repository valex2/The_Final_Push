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
// Additional Comments: please work
//////////////////////////////////////////////////////////////////////////////////
module note_arranger(
    input clk,
    input reset, 
    input beat, // one-pulse from the beat generator (every 48th note)
    input [15:0] note_to_load, // note from song-reader
    input load_new_note,
    input play_enable,
    
    // the following are one-pulses from the note_players
    input note_1_done,
    input note_2_done,
    input note_3_done,

    // the following feed to the note_players (for each note_player)
    output reg note_1_load,
    output [5:0] note_1,
    output [5:0] note_1_duration,
    output [1:0] note_1_stereo,
    
    output reg note_2_load,
    output [5:0] note_2,
    output [5:0] note_2_duration,
    output [1:0] note_2_stereo,
    
    output reg note_3_load,
    output [5:0] note_3,
    output [5:0] note_3_duration,
    output [1:0] note_3_stereo,

    output note_done, // this is a one-pulse that goes to the song-reader
    output reg advance_time // this is high when note_players should be playing, low when they should be paused
);
    wire note_1_done_delayed;
    dffr #(1) note_1_done_delay_reg (
        .clk(clk),
        .r(reset),
        .d(note_1_done),
        .q(note_1_done_delayed)
    );
    
    wire note_2_done_delayed;
    dffr #(1) note_2_done_delay_reg (
        .clk(clk),
        .r(reset),
        .d(note_2_done),
        .q(note_2_done_delayed)
    );
    
    wire note_3_done_delayed;
    dffr #(1) note_3_done_delay_reg (
        .clk(clk),
        .r(reset),
        .d(note_3_done),
        .q(note_3_done_delayed)
    );

    // State machine flip-flop
    wire [2:0] state;
    reg [2:0] next_state;
    dffr #(3) state_reg ( // State flip-flop
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(state)
    );

    // Note_tracker flip-flop
    wire [2:0] full;
    reg [2:0] next_full;
    dffr #(3) full_reg ( // Note_trakcer flip-flop -- this will be 3'b111 when all three note_players are full
        .clk(clk),
        .r(reset),
        .d(next_full),
        .q(full)
    );

    // Duration counter
    wire [5:0] count;
    reg [5:0] next_count;
    dffr #(6) counter ( // Duration flip-flop
        .clk(clk),
        .r(reset),
        .d(next_count),
        .q(count)
    );
    
    // Note_done delayer
    reg note_done_early;
    dffr #(1) note_done_reg ( // Note_done flip-flop
        .clk(clk),
        .r(reset),
        .d(note_done_early),
        .q(note_done)
    );

    // Note information flip-flops
    reg [5:0] next_note_1, next_note_1_duration;
    reg [1:0] next_note_1_stereo;
    dffr #(6) note_1_reg ( // Note flip-flop
        .clk(clk),
        .r(reset),
        .d(next_note_1),
        .q(note_1)
    );
    dffr #(6) note_1_duration_reg ( // Note duration flip-flop
        .clk(clk),
        .r(reset),
        .d(next_note_1_duration),
        .q(note_1_duration)
    );
    dffr #(2) note_1_stereo_reg (
        .clk(clk),
        .r(reset),
        .d(next_note_1_stereo),
        .q(note_1_stereo)
    );
    
    reg [5:0] next_note_2, next_note_2_duration;
    reg [1:0] next_note_2_stereo;
    dffr #(6) note_2_reg ( // Note flip-flop
        .clk(clk),
        .r(reset),
        .d(next_note_2),
        .q(note_2)
    );
    dffr #(6) note_2_duration_reg ( // Note duration flip-flop
        .clk(clk),
        .r(reset),
        .d(next_note_2_duration),
        .q(note_2_duration)
    );
    dffr #(2) note_2_stereo_reg (
        .clk(clk),
        .r(reset),
        .d(next_note_2_stereo),
        .q(note_2_stereo)
    );
    
    reg [5:0] next_note_3, next_note_3_duration;
    reg [1:0] next_note_3_stereo;
    dffr #(6) note_3_reg ( // Note flip-flop
        .clk(clk),
        .r(reset),
        .d(next_note_3),
        .q(note_3)
    );
    dffr #(6) note_3_duration_reg ( // Note duration flip-flop
        .clk(clk),
        .r(reset),
        .d(next_note_3_duration),
        .q(note_3_duration)
    );
    dffr #(2) note_3_stereo_reg (
        .clk(clk),
        .r(reset),
        .d(next_note_3_stereo),
        .q(note_3_stereo)
    );

    // State machine parameters
    parameter PAUSE = 3'd1, ADVANCE_TIME = 3'd2, ASSIGN = 3'd3, LISTEN = 3'd4, LOAD = 3'd5;

    always @(*) begin // state control
        advance_time = 1'b0;
        note_done_early = 1'b0;
        
        note_1_load = 1'b0;
        note_2_load = 1'b0;
        note_3_load = 1'b0;
        
        {next_note_1, next_note_1_duration, next_note_1_stereo} = {note_1, note_1_duration, note_1_stereo};
        {next_note_2, next_note_2_duration, next_note_2_stereo} = {note_2, note_2_duration, note_2_stereo};
        {next_note_3, next_note_3_duration, next_note_3_stereo} = {note_3, note_3_duration, note_3_stereo};
        
        next_count = count;
        next_full = reset ? 3'd0 : full;
    
        if (reset) begin
            next_state = ASSIGN;
        end

        case(state) // state transition logic
            ASSIGN: begin
                if (load_new_note & !note_to_load[15]) begin
                    casex(full) // if all note_players are full, pause
                        3'b0xx: begin
                            next_state = ASSIGN;

                            {next_note_1, next_note_1_duration} = note_to_load[14:3]; // information updates
                            next_note_1_stereo = note_to_load[2:1];
                            note_done_early = 1'b1; // pulse song-reader to load new note // this should be moved to assign
                            
                            next_full = (full | 3'b100); // set note_player 1 to full
                        end
                        3'b10x: begin
                            next_state = ASSIGN;
                            
                            {next_note_2, next_note_2_duration} = note_to_load[14:3]; // information updates
                            next_note_2_stereo = note_to_load[2:1];
                            note_done_early = 1'b1; // pulse song-reader to load new note // this should be moved to assign
                            
                            next_full = (full | 3'b010); // set note_player 1 to full

                        end
                        3'b110: begin
                            next_state = ASSIGN;

                            {next_note_3, next_note_3_duration} = note_to_load[14:3]; // information updates
                            next_note_3_stereo = note_to_load[2:1];
                            note_done_early = 1'b1; // pulse song-reader to load new note // this should be moved to assign
                            
                            next_full = (full | 3'b001); // set note_player 1 to full

                        end
                        default: next_state = ASSIGN; // stay at assign if all note_players are full TODO: maybe this should be an error
                    endcase
                end
                else if (load_new_note & note_to_load[15]) begin
                    next_state = LOAD;
                    next_count = note_to_load[8:3] - 1'd1;

                    if (full[2] == 1'b0) begin
                        {next_note_1, next_note_1_duration} = {6'd0, note_to_load[8:3]}; // set unfilled note_players to play 0 for the note duration
                        next_note_1_stereo = 2'b11;
                    end
                    if (full[1] == 1'b0) begin
                        {next_note_2, next_note_2_duration} = {6'd0, note_to_load[8:3]}; // set unfilled note_players to play 0 for the note duration
                        next_note_2_stereo = 2'b11;
                    end
                    if (full[0] == 1'b0) begin
                        {next_note_3, next_note_3_duration} = {6'd0, note_to_load[8:3]}; // set unfilled note_players to play 0 for the note duration
                        next_note_3_stereo = 2'b11;
                    end
                end
                else begin
                    next_state = ASSIGN;
                end
            end
            LOAD: begin
                next_state = ADVANCE_TIME;

                note_1_load = 3'b1; // load note_players -- add , note_2_load, note_3_load
                note_2_load = 3'b1;
                note_3_load = 3'b1;
            end
            ADVANCE_TIME: begin
                advance_time = 1'b1;
                if (beat & (count == 6'd0)) begin // if the duration counter is zero and it's a beat, continue playing
                    next_state = LISTEN;
                    note_done_early = 1'b1; // pulse song-reader to load new note
                    next_count = count;
                end else if (!play_enable) begin // if play is disabled, pause
                    next_state = PAUSE;
                    advance_time = 1'b0;
                    note_done_early = 1'b0;
                    next_count = count;
                end else if (beat) begin
                    next_state = ADVANCE_TIME;
                    note_done_early = 1'b0;
                    next_count = count - 1;
                end else begin
                    next_state = ADVANCE_TIME;
                    note_done_early = 1'b0;
                    next_count = count;
                end
            end
            LISTEN: begin // see which note_players are now finished
                next_state = ASSIGN;
                
                case({note_1_done_delayed, note_2_done_delayed, note_3_done_delayed}) // update internal states
                    3'b001: next_full = (full & 3'b110);
                    3'b010: next_full = (full & 3'b101);
                    3'b011: next_full = (full & 3'b100);
                    3'b100: next_full = (full & 3'b011);
                    3'b101: next_full = (full & 3'b010);
                    3'b110: next_full = (full & 3'b001);
                    3'b111: next_full = 3'b000;
                    default: next_full = 3'b111;
                endcase
            end
            PAUSE: begin
                note_done_early = 1'b0;
                next_count = count;
                if (play_enable) begin
                    next_state = ADVANCE_TIME;
                end else begin
                    next_state = PAUSE;
                end
            end
            default: next_state = ASSIGN;
        endcase
      end
endmodule