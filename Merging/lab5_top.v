module lab5_top(
    /*
    'define H_SYNC_PULSE 112
	'define H_BACK_PORCH 248
	'define H_FRONT_PORCH 48
	'define V_SYNC_PULSE 3
	'define V_BACK_PORCH 38
	'define V_FRONT_PORCH 1
    */ 	  

    // System Clock (125MHz)
    input sysclk,
    	 
    // ADAU_1761 interface
    output  AC_ADR0,            // I2C Address pin (DO NOT CHANGE)
    output  AC_ADR1,            // I2C Address pin (DO NOT CHANGE)
    
    output  AC_DOUT,           // I2S Signals
    input   AC_DIN,           // I2S Signals
    input   AC_BCLK,           // I2S Byte Clock
    input   AC_WCLK,           // I2S Channel Clock
    
    output  AC_MCLK,            // Master clock (48MHz)
    output  AC_SCK,             // I2C SCK
    inout   AC_SDA,             // I2C SDA 
    
    // LEDs
    output wire [3:0] led,
    output wire [2:0] leds_rgb_0,
    output wire [2:0] leds_rgb_1,

    input [2:0] btn,
    input [7:0] sw,

    /* 
    //VGA OUTPUT 
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS*/
  
    // HDMI output
    output TMDS_Clk_p,
    output TMDS_Clk_n,
    output [2:0] TMDS_Data_p,
    output [2:0] TMDS_Data_n
    
    // TODO: output LED0 onto something
  
);  
    wire [3:0] overtone_input = {sw[5], sw[4], sw[3], sw[2]}; // 0000 (max volue), where msb is fundamental

    wire reset, play_button, next_button;
    assign {reset, play_button, next_button} = btn;

    // Clock converter
    wire clk_100, display_clk, serial_clk;
    wire LED0;      // TODO: assign this to a real LED
 
    clk_wiz_0 U2 (
        .clk_out1(clk_100),     // 100 MHz
        .clk_out2(display_clk),	// 30 MHz
        .clk_out3(serial_clk),	// 150 Mhz
        .reset(reset),
        .locked(LED0),
        .clk_in1(sysclk)
    );


    /////////// LEDS ///////////
    //assign led = codec_sample[15:12];
    wire [3:0] led_duty_cycle;
    assign led_duty_cycle = overtone_input;
    
    wire pwm_signal, rgb_pwm_signal;
    pwm pwm_led (
        .clk(clk_100),
        .duty(led_duty_cycle),
        .pwm_signal(pwm_signal)
   );
   assign led = {pwm_signal, pwm_signal, pwm_signal, pwm_signal};
   
   pwm pwm_rgb0 (
        .clk(clk_100),
        .duty(led_duty_cycle),
        .pwm_signal(rgb_pwm_signal)
   );
    assign leds_rgb_0 = {rgb_pwm_signal, rgb_pwm_signal, rgb_pwm_signal};
    assign leds_rgb_1 = {rgb_pwm_signal, rgb_pwm_signal, rgb_pwm_signal};

    // button_press_unit's WIDTH parameter is exposed here so that you can
    // reduce it in simulation.  Setting it to 1 effectively disables it.
    parameter BPU_WIDTH = 20;
    // The BEAT_COUNT is parameterized so you can reduce this in simulation.
    // If you reduce this to 100 your simulation will be 10x faster.
    parameter BEAT_COUNT = 1000;

   
    // These signals are for determining which color to display
    wire [11:0] x;  // [0..1279]
    wire [11:0] y;  // [0..1023] 
    
    // Color to display at the given x,y
    wire [31:0] pix_data;
    reg [3:0]  r, g, b;
    wire [7:0] r_1, g_1, b_1;
      
  wire [3:0] VGA_R;
  wire [3:0] VGA_G;
  wire [3:0] VGA_B;
  wire VGA_HS;
  wire VGA_VS;
 
//   
//  ****************************************************************************
//      Button processor units
//  ****************************************************************************
//  
    wire play;
    button_press_unit #(.WIDTH(BPU_WIDTH)) play_button_press_unit(
        .clk(clk_100),
        .reset(reset),
        .in(play_button),
        .out(play)
    );

    wire next;
    button_press_unit #(.WIDTH(BPU_WIDTH)) next_button_press_unit(
        .clk(clk_100),
        .reset(reset),
        .in(next_button),
        .out(next)
    );
       
//   
//  ****************************************************************************
//      The music player
//  ****************************************************************************
//       
    wire new_frame;
    wire [15:0] left_sample, flopped_left_sample;
    wire [15:0] right_sample, flopped_right_sample;
    wire signed [15:0] normal_sample, flopped_normal_sample;
    wire new_sample, flopped_new_sample;
    
    wire [5:0] current_note1, note_duration1, current_note2, note_duration2, current_note3, note_duration3;
    wire note_1_load, note_2_load, note_3_load;
    
    music_player #(.BEAT_COUNT(BEAT_COUNT)) music_player(
        .clk(clk_100),
        .reset(reset),
        .play_button(play),
        .next_button(next),
        .new_frame(new_frame),
        .stereo_on(sw[7]), 
        .harmonics_on(sw[6]),
        .overtones(overtone_input), // use switches for this eventually
        .sample_left(left_sample),
        .sample_right(right_sample),
        .sample_normal(normal_sample),
        .new_sample_generated(new_sample),
        
        .current_note_1(current_note1),
        .current_note_duration_1(note_duration1),
        .new_note_available_1(note_1_load),
        .current_note_2(current_note2),
        .current_note_duration_2(note_duration2),
        .new_note_available_2(note_2_load),
        .current_note_3(current_note3),
        .current_note_duration_3(note_duration3),
        .new_note_available_3(note_3_load)
    );
    dff #(.WIDTH(33)) sample_reg (
        .clk(clk_100),
        .d({new_sample, left_sample, right_sample}),
        .q({flopped_new_sample, flopped_left_sample, flopped_right_sample})
    );
    
    dff #(16) normal_sample_reg (
        .clk(clk_100),
        .d(normal_sample),
        .q(flopped_normal_sample)
    );

//   
//  ****************************************************************************
//      Codec interface
//  ****************************************************************************
//  
    wire [23:0] hphone_r = 0;
    wire [23:0] line_in_l = 0;  
	wire [23:0] line_in_r =  0; 
	
    adau1761_codec adau1761_codec(
        .clk_100(clk_100),
        .reset(reset),
        .AC_ADR0(AC_ADR0),
        .AC_ADR1(AC_ADR1),
        .I2S_MISO(AC_DOUT),
        .I2S_MOSI(AC_DIN),
        .I2S_bclk(AC_BCLK),
        .I2S_LR(AC_WCLK),
        .AC_MCLK(AC_MCLK),
        .AC_SCK(AC_SCK),
        .AC_SDA(AC_SDA),
        .hphone_l({left_sample, 8'h00}),
        .hphone_r({right_sample, 8'h00}),
        .line_in_l(line_in_l),
        .line_in_r(line_in_r),
        .new_sample(new_frame)
    );  
    
//   
//  ****************************************************************************
//      Display management
//  ****************************************************************************
//  
 
    //==========================================================================
    // Display management -> do not touch!
    //==========================================================================
	 
//	wire valid, de;
//    vga_generator vga_g (
//        .clk(clk_100),
//        .r(r), 
//        .g(g),
//        .b(b),
//        .color({r_1, g_1, b_1}),
//        .xpos(x),
//        .ypos(y),
//        .valid(valid),
//        .de(de),
//        .vsync(VGA_VS),
//        .hsync(VGA_HS)
//    );

    wire vde, hsync, vsync, blank;
    vga_controller_800x480_60 vga_control (
        .pixel_clk(display_clk),
        .rst(reset),
        .HS(hsync),
        .VS(vsync),
        .VDE(vde),
        .hcount(x),
        .vcount(y),
        .blank(blank)
    );
    
    
    
    
    wave_display_top wd_top (
		.clk (clk_100),
		.reset (reset),
		.new_sample (new_sample),
		.sample (flopped_normal_sample <<< 1),
        .x(x[10:0]),
        .y(y[9:0]),
        //.valid(valid),
		.valid(vde),
		.vsync(vsync),
		.r(r_1),
		.g(g_1),
		.b(b_1)
    );
    
    wire [10:0] x_q, y_q;
    wire [5:0] vga_rgb, rgb_q;
    always @(*) begin
        r = r_1[7:4];
        g = g_1[7:4];
        b = b_1[7:4];

        if (rgb_q [5:4] != 0 || rgb_q[3:2] != 0 || rgb_q [1:0] != 0) begin
            r = {2{rgb_q [5:4]}};
            g = {2{rgb_q [3:2]}};
            b = {2{rgb_q [1:0]}};
        end
   end

    assign pix_data = {
                        8'b0, 
                        r[3], r[3], r[2], r[2], r[1], r[1], r[0], r[0],
                        g[3], g[3], g[2], g[2], g[1], g[1], g[0], g[0],
                        b[3], b[3], b[2], b[2], b[1], b[1], b[0], b[0]
                       }; 
                  
    hdmi_tx_0 U3 (
        .pix_clk(display_clk),
        .pix_clkx5(serial_clk),
        .pix_clk_locked(LED0),
        .rst(reset),
        .pix_data(pix_data),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        .TMDS_CLK_P(TMDS_Clk_p),
        .TMDS_CLK_N(TMDS_Clk_n),
        .TMDS_DATA_P(TMDS_Data_p),
        .TMDS_DATA_N(TMDS_Data_n)
    );
   
    	dff #(.WIDTH (11)) x_dff (
        .clk (clk_100),
        .d (x),
        .q (x_q)
    );

	dff #(.WIDTH (11)) y_dff (
        .clk (clk_100),
        .d (y),
        .q (y_q)
    );

//    );
	wire [5:0] note_duration1_d1, note_duration1_d2, note_duration1_d3,note_duration2_d1, note_duration2_d2, note_duration2_d3, note_duration3_d1, note_duration3_d2, note_duration3_d3;
    wire [5:0] current_note1_d1, current_note1_d2, current_note1_d3, current_note2_d1, current_note2_d2, current_note2_d3,current_note3_d1, current_note3_d2, current_note3_d3;

    // Delay for note_duration
    dff #(.WIDTH(6)) delay_note1_duration_1 (.clk(clk_100), .d(note_duration1), .q(note_duration1_d1));
    dff #(.WIDTH(6)) delay_note1_duration_2 (.clk(clk_100), .d(note_duration1_d1), .q(note_duration1_d2));
    dff #(.WIDTH(6)) delay_note1_duration_3 (.clk(clk_100), .d(note_duration1_d2), .q(note_duration1_d3));

    // Delay for current_note
    dff #(.WIDTH(6)) delay_current_note1_1 (.clk(clk_100), .d(current_note1), .q(current_note1_d1));
    dff #(.WIDTH(6)) delay_current_note1_2 (.clk(clk_100), .d(current_note1_d1), .q(current_note1_d2));
    dff #(.WIDTH(6)) delay_current_note1_3 (.clk(clk_100), .d(current_note1_d2), .q(current_note1_d3));

    // Delay for note_duration
    dff #(.WIDTH(6)) delay_note2_duration_1 (.clk(clk_100), .d(note_duration2), .q(note_duration2_d1));
    dff #(.WIDTH(6)) delay_note2_duration_2 (.clk(clk_100), .d(note_duration2_d1), .q(note_duration2_d2));
    dff #(.WIDTH(6)) delay_note2_duration_3 (.clk(clk_100), .d(note_duration2_d2), .q(note_duration2_d3));

    // Delay for current_note
    dff #(.WIDTH(6)) delay_current_note2_1 (.clk(clk_100), .d(current_note2), .q(current_note2_d1));
    dff #(.WIDTH(6)) delay_current_note2_2 (.clk(clk_100), .d(current_note2_d1), .q(current_note2_d2));
    dff #(.WIDTH(6)) delay_current_note2_3 (.clk(clk_100), .d(current_note2_d2), .q(current_note2_d3));

    // Delay for note_duration
    dff #(.WIDTH(6)) delay_note3_duration_1 (.clk(clk_100), .d(note_duration3), .q(note_duration1_d1));
    dff #(.WIDTH(6)) delay_note3_duration_2 (.clk(clk_100), .d(note_duration3_d1), .q(note_duration1_d2));
    dff #(.WIDTH(6)) delay_note3_duration_3 (.clk(clk_100), .d(note_duration3_d2), .q(note_duration1_d3));

    // Delay for current_note
    dff #(.WIDTH(6)) delay_current_note3_1 (.clk(clk_100), .d(current_note3), .q(current_note3_d1));
    dff #(.WIDTH(6)) delay_current_note3_2 (.clk(clk_100), .d(current_note3_d1), .q(current_note3_d2));
    dff #(.WIDTH(6)) delay_current_note3_3 (.clk(clk_100), .d(current_note2_d2), .q(current_note3_d3));

    // Display Driver
    fpa_vga_driver fpa_vga (
        .clk     (clk_100),
        .XPos    (x_q), // x_q
        .YPos    (y_q),

	   .input_note1(current_note1_d3),
	   .note_duration1(note_duration1_d3),
	   .new_note_available_1(note_1_load),

	   .input_note2(current_note2_d3),
	   .note_duration2(note_duration2_d3),
	   .new_note_available_2(note_2_load),

	   .input_note3(current_note3_d3),
	   .note_duration3(note_duration3_d3),
	   .new_note_available_3(note_3_load),

	   .play_button(play),
	   .next_button(next),
	   .stereo_on(sw[7]),
	   .harmonics_on(sw[6]),
	   .overtones_on(sw[6]),
       .overtones(overtone_input),
        //.Valid   (vde),
        .Valid   (1'b1),

        .vga_rgb (vga_rgb)
    );

    dff #(.WIDTH (6)) rgb_dff (
        .clk (clk_100),
        .d (vga_rgb),
        .q (rgb_q)
    );
   
endmodule

