module wave_display (
    input clk,
    input reset,
    input [10:0] x,  // [0..1279]
    input [9:0]  y,  // [0..1023]
    input valid,
    input [7:0] read_value,
    input read_index,
    output wire [8:0] read_address,
    output wire valid_pixel,
    output wire [7:0] r,
    output wire [7:0] g,
    output wire [7:0] b
);

// Implement me! -- NO, begone!
wire [1:0] quadrant_pos = x[9:8]; // part of the logic that makes sure we don't write to quadrant 1 or 4 of the display

assign read_address = {read_index, x[9], x[7:1]}; // a 9 bit address

wire [8:0] prev_address;
dffr #(9) addressor ( // used to remember previous read_address in order to compare it to the current one
    .clk(clk),
    .r(reset),
    .d(read_address),
    .q(prev_address)
);

wire address_change = (read_address != prev_address); // if the address changes, we want to read from the memory
wire synchronized_address_change;
dffr #(1) synchron ( // used to synchronize the address_change signal
    .clk(clk),
    .r(reset),
    .d(address_change),
    .q(synchronized_address_change)
);

wire [7:0] curr_value;

wire [7:0] read_value_adjusted = ((read_value >> 1) + 8'd32);

dffre #(8) bookworm ( // used to select when to read from the ram's output value
    .clk(clk),
    .r(reset),
    .en(synchronized_address_change),
    .d(read_value_adjusted),
    .q(curr_value)
);

wire [7:0] prev_value;
dffre #(8) waiter ( // stores the previous value of the ram's output in memory
    .clk(clk),
    .r(reset),
    .en(synchronized_address_change),
    .d(curr_value),
    .q(prev_value)
);

wire [7:0] y_value = y[8:1]; // the y value is the input without the MSB or LSB

wire increasing_wave = ((y_value >= prev_value) & (curr_value >= y_value)); // if the wave is increasing, we want to write to the display
wire decreasing_wave = ((y_value <= prev_value) & (curr_value <= y_value)); // if the wave is decreasing, we want to write to the display

wire want_pixel = (increasing_wave | decreasing_wave); // if the wave is increasing or decreasing, we want to write to the display

wire valid_quadrant = ~((quadrant_pos == 2'b00) | (quadrant_pos == 2'b11) | (y[9])); // if we are in quadrant 1 or 4 or if the bottom half (y[9] == 1), we don't want to write to the display,

assign valid_pixel = (valid & valid_quadrant & want_pixel & ({x[9], x[7:1]} > 8'd2) &({x[9], x[7:1]} < 8'd253)); // if the y_val is between the read values in the RAM, and we are in the right quadrant, and the right part of the screen, write to the display

assign r = 8'd255;
assign g = 8'd0;
assign b = 8'd0;



//reg [29:0] next_color;
//wire [29:0] curr_color;
//dffr #(30) color (
//    .clk(clk),
//    .r(reset),
//    .d(next_color),
//    .q(curr_color)
//);
//// create an 8-bit counter to cycle 0-255 for ramp
//reg [7:0] reduced_count;
//always @(*) begin
//    case(curr_color)
//        22'bxxxxxxxxxxx1xxxxxxxxxx : reduced_count = reduced_count + 1;
//        default : reduced_count = reduced_count;
//        endcase
//end

//// implement HSV rainbow functionality on display lines
//always @(*) begin
//    if (curr_color >= 22'd0 && curr_color <= 22'd699050) begin
//        r = 8'd255;
//        g = reduced_count; //up
//        b = 8'd0;
//    end else if (curr_color >= 22'd699051 && curr_color <= 22'd1398101) begin
//        r = 8'd255 - reduced_count; // down
//        g = 8'd255;
//        b = 8'd0;
//    end else if (curr_color >= 22'd1348102 && curr_color <= 22'd2097152) begin
//        r = 8'd0;
//        g = 8'd255;
//        b = reduced_count; // up
//    end else if (curr_color >= 22'd2097153 && curr_color <= 22'd2796202) begin
//        r = 8'd0;
//        g = 8'd255 - reduced_count; // down
//        b = 8'd255;
//    end else if (curr_color >= 22'd2796203 && curr_color <= 22'd3495253) begin
//        r = reduced_count; // up
//        g = 8'd0;
//        b = 8'd255;
//    end else if (curr_color >= 22'd3495254 && curr_color <= 22'd4194303) begin
//        r = 8'd255;
//        g = 8'd0;
//        b = 8'd255 - reduced_count; // down
//    end
//    next_color = curr_color + 1;
//end

/*
always @(*) begin
    next_color = curr_color + 1;
end

assign r = curr_color[29:22];
assign g = curr_color[21:14];
assign b = curr_color[13:6];
*/
//assign r = 8'b10000000;
//assign g = 8'd0;
//assign b = 8'b10000000;

endmodule
