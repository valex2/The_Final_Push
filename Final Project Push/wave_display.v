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

endmodule

//module wave_display (
//    input clk,
//    input reset,
//    input [10:0] x,  // [0..1279]
//    input [9:0]  y,  // [0..1023]
//    input valid,
//    input [7:0] read_value,
//    input read_index,
//    output wire [8:0] read_address,
//    output wire valid_pixel,
//    output wire [7:0] r,
//    output wire [7:0] g,
//    output wire [7:0] b
//);

//wire [1:0] quadrant_pos = x[9:8]; // part of the logic that makes sure we don't write to quadrant 1 or 4 of the display

//assign read_address = {read_index, x[9], x[7:1]}; // a 9 bit address

//wire [8:0] prev_address;

////angelina edits
//wire signed [7:0] delta_y;
//wire signed [10:0] delta_x;
//wire signed [18:0] slope; // Q8.10 fixed-point format for slope
//wire signed [18:0] error; // Distance from the ideal line

    
//dffr #(9) addressor ( // used to remember previous read_address in order to compare it to the current one
//    .clk(clk),
//    .r(reset),
//    .d(read_address),
//    .q(prev_address)
//);

//wire address_change = (read_address != prev_address); // if the address changes, we want to read from the memory
//wire synchronized_address_change;
//dffr #(1) synchron ( // used to synchronize the address_change signal
//    .clk(clk),
//    .r(reset),
//    .d(address_change),
//    .q(synchronized_address_change)
//);

//wire [7:0] curr_value;

//wire [7:0] read_value_adjusted = ((read_value >> 1) + 8'd32);

//dffre #(8) bookworm ( // used to select when to read from the ram's output value
//    .clk(clk),
//    .r(reset),
//    .en(synchronized_address_change),
//    .d(read_value_adjusted),
//    .q(curr_value)
//);

//wire [7:0] prev_value;
//dffre #(8) waiter ( // stores the previous value of the ram's output in memory
//    .clk(clk),
//    .r(reset),
//    .en(synchronized_address_change),
//    .d(curr_value),
//    .q(prev_value)
//);

//wire [7:0] y_value = y[8:1]; // the y value is the input without the MSB or LSB

//wire increasing_wave = ((y_value >= prev_value) & (curr_value >= y_value)); // if the wave is increasing, we want to write to the display
//wire decreasing_wave = ((y_value <= prev_value) & (curr_value <= y_value)); // if the wave is decreasing, we want to write to the display

//wire want_pixel = (increasing_wave | decreasing_wave); // if the wave is increasing or decreasing, we want to write to the display

//wire valid_quadrant = ~((quadrant_pos == 2'b00) | (quadrant_pos == 2'b11) | (y[9])); // if we are in quadrant 1 or 4 or if the bottom half (y[9] == 1), we don't want to write to the display,

//assign valid_pixel = (valid & valid_quadrant & want_pixel & ({x[9], x[7:1]} > 8'd2) &({x[9], x[7:1]} < 8'd253)); // if the y_val is between the read values in the RAM, and we are in the right quadrant, and the right part of the screen, write to the display

//wire y_dif = (y > y_value) ? (y - y_value) : (y_value - y);

//reg [10:0] prev_x;
//reg [9:0] prev_y;

////// anti-aliasing: calculate intensity of various pixels
////assign delta_y = curr_value - prev_value;
////assign delta_x = x - prev_x; // storing previous x value

////// Calculate the slope 
////assign slope = (delta_x != 0) ? (delta_y << 10) / delta_x : 0;

////// For each pixel, calculate the error distance from the ideal line
////assign error = (y << 10) - (prev_y << 10) - (slope * (x - prev_x));

////// determine intensity based on distance from ideal line
//wire [7:0] intensity;
//assign intensity = (y_dif < 8'd16) ? (16 - y_dif) : 8'd0;

//// set color of pixel according to intensity
//assign r = 8'd0;
//assign g = intensity;
//assign b = 8'd0;


//endmodule