module wave_capture (
    input clk,
    input reset,
    input new_sample_ready,
    input [15:0] new_sample_in,
    input wave_display_idle,
    output wire [8:0] write_address,
    output wire write_enable,
    output wire [7:0] write_sample,
    output wire read_index
);

parameter ARMED = 2'b00, ACTIVE = 2'b01, WAIT = 2'b11;
// current values
wire [1:0] state; // 00 - armed, 01 - active, 11 - wait
wire [7:0] counter;
wire current_read_index;
wire [7:0] current_write_sample;

//next values
reg [1:0] next_state;
reg [7:0] next_counter;
reg next_read_index;
reg [7:0] next_write_sample;

// stores last sample to compare for zero crossings
dffre #(8) get_last_sample (
    .clk(clk),
    .r(reset),
    .en(1'b1),
    .d(new_sample_in[15:8]),
    .q(current_write_sample)
);

// flip flop for FSM state
dffre #(2) state_ff (
    .clk(clk),
    .r(reset),
    .en(1'b1),
    .d(next_state),
    .q(state)
);

//counter flip flop
dffr #(8) counter_ff (
    .clk(clk),
    .r(reset),
    .d(next_counter),
    .q(counter)
);

dffr #(1) index_tog (
    .clk(clk),
    .r(reset),
    .d(next_read_index),
    .q(current_read_index)
);

always @(*) begin // toggle states for FSM
    next_state = (reset) ? ARMED : state; // Default state
    next_counter = counter;
    next_read_index = current_read_index;
    next_write_sample = (new_sample_in[15:8]);
    case (state)
        ARMED: begin
            if (current_write_sample[7] == 1'b1 && new_sample_in[15] == 1'b0) begin
                next_state = ACTIVE;
                next_counter = 0; // Reset counter in preparation for new wave capture
            end
        end
        ACTIVE: begin
            if (new_sample_ready) begin
                next_counter = counter + 1'b1;
                next_write_sample = new_sample_in[15:8];
            end
            if (counter == 8'd255) begin
                next_state = WAIT;
            end
        end
        WAIT: begin
            if (wave_display_idle) begin
                next_state = ARMED;
                next_read_index = ~current_read_index;
            end
        end
    endcase
end

wire [7:0] new_write_sample = new_sample_in[15:8] + 8'd128;
//wire [7:0] new_write_sample = new_sample_in[15] ? (8'd127 + new_sample_in[14:7]) : 8'd127 - new_sample_in[14:7];

assign write_address = {current_read_index, counter};
assign write_enable = (state == ACTIVE) && new_sample_ready;
assign write_sample = new_write_sample;
assign read_index = current_read_index;

endmodule
