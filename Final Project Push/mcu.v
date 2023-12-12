module mcu(
    input clk,
    input reset,
    input play_button,
    input next_button,
    input song_done,
    output play,
    output reset_player,
    output [1:0] song
);

// system states
parameter PAUSED = 2'b00;
parameter PLAYING = 2'b01;
parameter NEXT = 2'b10;

// signals
wire [1:0] state; // Current state of MCU
reg [1:0] next_state; // Next state of MCU
wire [1:0] song_reg; // Current song number
reg [1:0] next_song; // Next song number

// State transition
always @(*) begin
    // Default values
    next_state = state;
    next_song = song_reg;

    case (state)
        PAUSED: begin
            if (play_button) begin // Play button pressed
                next_state = PLAYING; // Go to playing state
            end else if (next_button) begin // Next button pressed
                next_state = NEXT; // Go to next state
                next_song = (song_reg == 3) ? 0 : (song_reg + 1); // Increment song number or wrap around
            end else begin
                next_state = PAUSED;
            end
        end

        PLAYING: begin
            if (play_button) begin // Play button pressed
                next_state = PAUSED; // Go back to paused state
            end else if (next_button) begin // Next button pressed
                next_state = NEXT; // Go to next state
                next_song = (song_reg == 3) ? 0 : (song_reg + 1); // Increment song number or wrap around
            end else if (song_done) begin // Song finished playing
                next_state = PAUSED; // Go back to paused state
                next_song = (song_reg == 3) ? 0 : (song_reg + 1); // Increment song number or wrap around
            end else begin
                next_state = PLAYING;
            end
        end

        NEXT: begin
            if (play_button) begin // Play button pressed
                next_state = PLAYING; // Go to playing state
            end else begin // No button pressed or next button pressed again
                next_state = PAUSED; // Go back to paused state
            end 
        end

        default: begin // Should not happen, but just in case
            next_state = PAUSED; // Go to paused state
            next_song = 0; // Reset song number 
        end

    endcase

end

// State update flip flop
dffre #2 state_ff(
    .clk(clk),
    .r(reset),
    .en(1'b1),
    .d(next_state),
    .q(state)
);

// Song update flip flop
dffre #2 song_ff(
    .clk(clk),
    .r(reset),
    .en(1'b1),
    .d(next_song),
    .q(song_reg)
);

// output
assign play = (state == PLAYING); // Play signal is high when in playing state 
assign reset_player = (state == NEXT || song_done); // Reset player signal is high when in next state 
assign song = song_reg; // Song output is current song number 

endmodule