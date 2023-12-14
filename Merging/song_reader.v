module song_reader(
    input clk,
    input reset,
    input play,
    input [1:0] song,
    input note_done,
    output reg song_done,
    output reg [15:0] out_data,
    output reg new_note
);

    // Internal signals and parameters
    wire [6:0] song_addr;
    reg [6:0] next_song_addr; 
    wire [15:0] song_data; 
    wire [1:0] state;
    reg [1:0] next_state;
    parameter IDLE = 2'b00, READ = 2'b01, WAIT = 2'b10, DONE = 2'b11;

    // Instantiate song_rom
    song_rom song_rom_inst (
        .clk(clk),
        .addr(song_addr),
        .dout(song_data)
    );

    // State flip-flop
    dffr #(2) state_reg (
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(state)
    );

    // Address flip-flop
    dff #(7) addr_reg (
        .clk(clk),
        .d(next_song_addr),
        .q(song_addr)
    );

    // Determine the next state
    always @(*) begin
        next_state = (reset) ? IDLE : state; // Default state
        case(state)
            IDLE: begin
                if (play) next_state = READ;
            end
            READ: begin
                if (song_addr[6:5] != song) begin
                    next_state = DONE; // Song ended indication
                end else begin
                    next_state = WAIT; // Wait for the note to be played
                end
            end
            WAIT: begin
                if (note_done) next_state = READ; // Ready for the next note
            end
            DONE: begin
                if (!play) next_state = IDLE; // Ready for the next song
            end
            default: next_state = IDLE; // Safety condition
        endcase
    end

    // Determine the song address
    always @(*) begin
        if (reset || (state == IDLE && next_state == READ)) begin
            // If reset, or if we are about to start playback, set the initial address based on the song number
            next_song_addr = {song, 5'b00000}; 
        end else if (state == READ && next_state == WAIT) begin
            // If we are about to move from reading the note to waiting, increment the address
            next_song_addr = song_addr + 7'b0000001; 
        end else begin
            // Otherwise, keep the address steady
            next_song_addr = song_addr;
        end
    end

//    reg [5:0] prev_note;
//    reg [5:0] prev_duration;
    // outputs
    always @(*) begin
        // defaults
//        note = prev_note;
//        duration = prev_duration;
        new_note = 1'b0;
        song_done = 1'b0;
        
        out_data = song_data;
        // use state to adjust
        case(state)
            READ: begin
                if (next_state == WAIT) begin
                    new_note = 1'b1; // Indicate a new note is being sent
                end else begin 
                    new_note = 1'b0;
                end
            end
            WAIT: begin
                // Keep the current note and duration
                new_note = 1'b0; // Indicate we are playing, so no new note is needed
            end
            DONE: begin
                // Indicate the song is done
                song_done = 1'b1;
            end
        endcase
    end
endmodule