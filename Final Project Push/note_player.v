module note_player(
    input clk,
    input reset,
    input play_enable,  // When high we play, when low we don't.
    input [5:0] note_to_load,  // The note to play
    input [5:0] duration_to_load,  // The duration of the note to play
    input load_new_note,  // Tells us when we have a new note to load
    output reg done_with_note,  // When we are done with the note this stays high.
    input beat,  // This is our 1/48th second beat
    input generate_next_sample,  // Tells us when the codec wants a new sample
    output [15:0] sample_out,  // Our sample output
    output new_sample_ready  // Tells the codec when we've got a sample
);
    reg [5:0] next;
    wire [5:0] loaded_duration;
    wire [5:0] loaded_note;
    wire [19:0] step_size;

    wire [1:0] state;
    reg [1:0] next_state;
    dffr #(2) state_reg ( // State flip-flop
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(state)
    );
    
    wire delayed_new_note;
    dffr#(1) load_delay(
        .clk(clk),
        .r(reset),
        .d(load_new_note),
        .q(delayed_new_note)
    );
    
    frequency_rom freaky(
        .addr(loaded_note),
        .clk(clk),
        .dout(step_size)
    );

    dffre #(6) note_loader( // Address flip-flop
        .clk(clk),
        .r(reset),
        .en(load_new_note),
        .d(note_to_load),
        .q(loaded_note)
    );

    dffre #(6) duration_loader( // Address flip-flop
        .clk(clk),
        .r(reset),
        .en(load_new_note),
        .d(duration_to_load),
        .q(loaded_duration)
    );

    wire [5:0] count;
    reg [5:0] next_count;
    dffr #(6) counter ( // Duration flip-flop
        .clk(clk),
        .r(reset),
        .d(next_count),
        .q(count)
    );

    parameter WAIT = 2'd0, PAUSE = 2'd1, PLAY = 2'd3;
    always @(*) begin // state control
        next_state = reset ? WAIT : state;
        case(state) // used next_state before
            WAIT: begin
                if (delayed_new_note && loaded_duration == 0) begin
                    next_state = WAIT;
                    next_count = count;
                    done_with_note = 1'b1;
                end else if (delayed_new_note) begin 
                    next_state = PLAY;
                    next_count = loaded_duration - 1;
                    done_with_note = 1'b0;
                    // This is done automatically //loaded_duration = duration_to_load; // update wires
                    //loaded_note = note_to_load;
                end else begin 
                    next_state = WAIT;
                    next_count = count;
                    done_with_note = 1'b0;
                end
            end
            PAUSE: begin
                next_count = count;
                done_with_note = 1'b0;
                if (play_enable) begin 
                    next_state = PLAY;
                end else begin 
                    next_state = PAUSE;
                end
            end
            PLAY: begin
               if (beat & (count == 6'd0)) begin // this might need to be 6'd0
                    next_state = WAIT;
                    done_with_note = 1'b1;
                    next_count = count;
                end else if (!play_enable) begin 
                    next_state = PAUSE;
                    done_with_note = 1'b0;
                    next_count = count;
               end else if (delayed_new_note) begin
                    next_state = PLAY;
                    done_with_note = 1'b0;
                    next_count = loaded_duration - 1;
               end else if (beat) begin
                    next_state = PLAY;
                    done_with_note = 1'b0;
                    next_count = count - 1;
                end
                else begin
                    next_state = PLAY;
                    done_with_note = 1'b0;
                    next_count = count;
                end
            end
            default: begin 
                next_state = WAIT;
                done_with_note = 1'b0;
                next_count = count;
            end
        endcase
    end

    reg generate_next;
    always @(*) begin
        case (state)
            PLAY: begin
                generate_next = generate_next_sample;
            end
            default: generate_next = 1'b0;
        endcase
    end

    sine_reader sinester(
        .clk(clk),
        .reset(reset),
        .step_size(step_size),
        .generate_next(generate_next),
        .sample_ready(new_sample_ready),
        .sample(sample_out)
    );
endmodule