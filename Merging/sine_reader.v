module sine_reader(
    input clk,
    input reset,
    input [19:0] step_size,
    input generate_next,
    output sample_ready,
    output reg [15:0] sample
);

reg [21:0] next_address;
wire [21:0] current_address;
reg [9:0] ROM_address_next;
wire [9:0] ROM_address;
wire [15:0] current_sample;

sine_rom letsGetReadyToROMble (.clk(clk), .addr(ROM_address), .dout(current_sample));

// ROM address update
always @(*) begin
    case(current_address[21:20])
        2'b00: ROM_address_next = current_address[19:10];
        2'b01: ROM_address_next = ~current_address[19:10];
        2'b10: ROM_address_next = current_address[19:10];
        2'b11: ROM_address_next = ~current_address[19:10];
        default: ROM_address_next = 10'd0;
    endcase
end

//wire [9:0] wait_ROM_address;
//dff #(10) ROM_delay(
//    .clk(clk),
//    .r(reset),
//    .d(ROM_address_next),
//    .q(wait_ROM_address)
//);

//dffre #(10) ROM_address_ff ( // Vassili -- removed the enable port
//    .clk(clk),
//    .r(reset),
//    .en(generate_next), 
//    .d(ROM_address_next),
//    .q(ROM_address)
//);

dffr #(10) ROM_address_ff (
    .clk(clk),
    .r(reset),
    .d(ROM_address_next),
    .q(ROM_address)
);

always @(*) begin
    if (generate_next) next_address = current_address + step_size;
    else next_address = current_address;
end

dffre #(22) update_address (
    .clk(clk),
    .r(reset),
    .en(1'b1), 
    .d(next_address),
    .q(current_address)
);

always @(*) begin
    case(current_address[21:20])
        2'b00: sample = current_sample;
        2'b01: sample = current_sample; // Mirrored value, handled by ROM address mapping
        2'b10: sample = 0 - current_sample; // Vertically flipped
        2'b11: sample = 0 - current_sample; // Horizontally mirrored and vertically flipped, horizontal part handled by ROM address mapping
        default: sample = 16'd6;
    endcase
end

// delay generate_next into sample_ready
wire delay_1;
dffre #(1) delay_ff (
    .clk(clk),
    .r(reset),
    .en(1'b1),
    .d(generate_next), 
    .q(delay_1)
);

//dffre #(1) sample_ready_ff ( // Vassili: trying to add another delay
//    .clk(clk),
//    .r(reset),
//    .en(1'b1),
//    .d(delay_1),
//    .q(sample_ready)
//);

wire delay_2;
dffre #(1) delay2_ff (
    .clk(clk),
    .r(reset),
    .en(1'b1),
    .d(delay_1),
    .q(delay_2)
);
wire delay_3;
dffre #(1) delay3_ff (
    .clk(clk),
    .r(reset),
    .en(1'b1),
    .d(delay_2),
    .q(delay_3)
);
dffre #(1) sample_ready_ff (
    .clk(clk),
    .r(reset),
    .en(1'b1),
    .d(delay_3),
    .q(sample_ready)
);

endmodule