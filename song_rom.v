// How to use:					
// 1. Edit the songs on the Enter Song sheet.					
// 2. Select this whole worksheet, copy it, and paste it into a new file.					
// 3. Save the file as song_rom.v.					
					
module song_rom (					
	input clk,				
	input [6:0] addr,				
	output reg [15:0] dout				
);					
					
	wire [15:0] memory [127:0];				
					
	always @(posedge clk)				
		dout = memory[addr];			
					
	assign memory[	  0	] =	{1'b0,6'd27, 6'd12,3'b111};	// Note: 3B
	assign memory[	  1	] =	{1'b0,6'd30, 6'd12,3'b111};	// Note: 3D
	assign memory[	  2	] =	{1'b0,6'd35, 6'd12,3'b111};	// Note: 3G
	assign memory[	  3	] =	{1'b1,6'd35, 6'd12,3'b111};	// Note: 3G
	assign memory[	  4	] =	{1'b0,6'd27, 6'd6,3'b111};	// Note: 3B
	assign memory[	  5	] =	{1'b0,6'd30, 6'd6,3'b111};	// Note: 3D
	assign memory[	  6	] =	{1'b0,6'd35, 6'd6,3'b111};	// Note: 3G
	assign memory[	  7	] =	{1'b1,6'd35, 6'd6,3'b111};	// Note: 3G
	assign memory[	  8	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	  9	] =	{1'b0,6'd30, 6'd8,3'b111};	// Note: 3D
	assign memory[	 10	] =	{1'b0,6'd35, 6'd8,3'b111};	// Note: 3G
	assign memory[	 11	] =	{1'b1,6'd35, 6'd8,3'b111};	// Note: 3G
	assign memory[	 12	] =	{1'b0,6'd27, 6'd4,3'b111};	// Note: 3B
	assign memory[	 13	] =	{1'b0,6'd30, 6'd4,3'b111};	// Note: 3D
	assign memory[	 14	] =	{1'b0,6'd25, 6'd4,3'b111};	// Note: 3A
	assign memory[	 15	] =	{1'b1,6'd25, 6'd4,3'b111};	// Note: 3A
	assign memory[	 16	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 17	] =	{1'b0,6'd30, 6'd8,3'b111};	// Note: 3D
	assign memory[	 18	] =	{1'b0,6'd25, 6'd8,3'b111};	// Note: 3A
	assign memory[	 19	] =	{1'b1,6'd25, 6'd8,3'b111};	// Note: 3A
	assign memory[	 20	] =	{1'b0,6'd30, 6'd12,3'b111};	// Note: 3D
	assign memory[	 21	] =	{1'b0,6'd35, 6'd12,3'b111};	// Note: 3G
	assign memory[	 22	] =	{1'b0,6'd27, 6'd12,3'b111};	// Note: 3B
	assign memory[	 23	] =	{1'b1,6'd27, 6'd12,3'b111};	// Note: 3B
	assign memory[	 24	] =	{1'b0,6'd30, 6'd6,3'b111};	// Note: 3D
	assign memory[	 25	] =	{1'b0,6'd35, 6'd6,3'b111};	// Note: 3G
	assign memory[	 26	] =	{1'b0,6'd27, 6'd6,3'b111};	// Note: 3B
	assign memory[	 27	] =	{1'b1,6'd27, 6'd6,3'b111};	// Note: 3B
	assign memory[	 28	] =	{1'b0,6'd30, 6'd8,3'b111};	// Note: 3D
	assign memory[	 29	] =	{1'b0,6'd35, 6'd8,3'b111};	// Note: 3G
	assign memory[	 30	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 31	] =	{1'b1,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 32	] =	{1'b0,6'd30, 6'd8,3'b111};	// Note: 3D
	assign memory[	 33	] =	{1'b0,6'd35, 6'd8,3'b111};	// Note: 3G
	assign memory[	 34	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 35	] =	{1'b1,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 36	] =	{1'b0,6'd30, 6'd4,3'b111};	// Note: 3D
	assign memory[	 37	] =	{1'b0,6'd35, 6'd4,3'b111};	// Note: 3G
	assign memory[	 38	] =	{1'b0,6'd27, 6'd4,3'b111};	// Note: 3B
	assign memory[	 39	] =	{1'b1,6'd27, 6'd4,3'b111};	// Note: 3B
	assign memory[	 40	] =	{1'b0,6'd27, 6'd12,3'b111};	// Note: 3B
	assign memory[	 41	] =	{1'b0,6'd30, 6'd12,3'b111};	// Note: 3D
	assign memory[	 42	] =	{1'b0,6'd25, 6'd12,3'b111};	// Note: 3A
	assign memory[	 43	] =	{1'b1,6'd25, 6'd12,3'b111};	// Note: 3A
	assign memory[	 44	] =	{1'b0,6'd30, 6'd6,3'b111};	// Note: 3D
	assign memory[	 45	] =	{1'b0,6'd35, 6'd6,3'b111};	// Note: 3G
	assign memory[	 46	] =	{1'b0,6'd27, 6'd6,3'b111};	// Note: 3B
	assign memory[	 47	] =	{1'b1,6'd27, 6'd6,3'b111};	// Note: 3B
	assign memory[	 48	] =	{1'b0,6'd30, 6'd8,3'b111};	// Note: 3D
	assign memory[	 49	] =	{1'b0,6'd35, 6'd8,3'b111};	// Note: 3G
	assign memory[	 50	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 51	] =	{1'b1,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 52	] =	{1'b0,6'd30, 6'd8,3'b111};	// Note: 3D
	assign memory[	 53	] =	{1'b0,6'd35, 6'd8,3'b111};	// Note: 3G
	assign memory[	 54	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 55	] =	{1'b1,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 56	] =	{1'b0,6'd30, 6'd4,3'b111};	// Note: 3D
	assign memory[	 57	] =	{1'b0,6'd35, 6'd4,3'b111};	// Note: 3G
	assign memory[	 58	] =	{1'b0,6'd27, 6'd4,3'b111};	// Note: 3B
	assign memory[	 59	] =	{1'b1,6'd27, 6'd4,3'b111};	// Note: 3B
	assign memory[	 60	] =	{1'b0,6'd30, 6'd4,3'b111};	// Note: 3D
	assign memory[	 61	] =	{1'b0,6'd33, 6'd4,3'b111};	// Note: 3F
	assign memory[	 62	] =	{1'b1,6'd33, 6'd4,3'b111};	// Note: 3F
	assign memory[	 63	] =	{1'b0,6'd30, 6'd6,3'b111};	// Note: 3D
	assign memory[	 64	] =	{1'b0,6'd33, 6'd6,3'b111};	// Note: 3F
	assign memory[	 65	] =	{1'b1,6'd33, 6'd6,3'b111};	// Note: 3F
	assign memory[	 66	] =	{1'b0,6'd30, 6'd8,3'b111};	// Note: 3D
	assign memory[	 67	] =	{1'b0,6'd33, 6'd8,3'b111};	// Note: 3F
	assign memory[	 68	] =	{1'b1,6'd33, 6'd8,3'b111};	// Note: 3F
	assign memory[	 69	] =	{1'b0,6'd30, 6'd4,3'b111};	// Note: 3D
	assign memory[	 70	] =	{1'b0,6'd33, 6'd4,3'b111};	// Note: 3F
	assign memory[	 71	] =	{1'b1,6'd0, 6'd4,3'b111};	// Note: rest
	assign memory[	 72	] =	{1'b0,6'd30, 6'd4,3'b111};	// Note: 3D
	assign memory[	 73	] =	{1'b0,6'd35, 6'd4,3'b111};	// Note: 3G
	assign memory[	 74	] =	{1'b1,6'd0, 6'd4,3'b111};	// Note: rest
	assign memory[	 75	] =	{1'b0,6'd33, 6'd8,3'b111};	// Note: 3F
	assign memory[	 76	] =	{1'b1,6'd33, 6'd4,3'b111};	// Note: 3F
	assign memory[	 77	] =	{1'b0,6'd32, 6'd4,3'b111};	// Note: 3E
	assign memory[	 78	] =	{1'b0,6'd32, 6'd4,3'b111};	// Note: 3E
	assign memory[	 79	] =	{1'b0,6'd35, 6'd4,3'b111};	// Note: 3G
	assign memory[	 80	] =	{1'b1,6'd32, 6'd4,3'b111};	// Note: 3E
	assign memory[	 81	] =	{1'b0,6'd32, 6'd6,3'b111};	// Note: 3E
	assign memory[	 82	] =	{1'b0,6'd35, 6'd6,3'b111};	// Note: 3G
	assign memory[	 83	] =	{1'b1,6'd32, 6'd6,3'b111};	// Note: 3E
	assign memory[	 84	] =	{1'b0,6'd32, 6'd8,3'b111};	// Note: 3E
	assign memory[	 85	] =	{1'b0,6'd35, 6'd8,3'b111};	// Note: 3G
	assign memory[	 86	] =	{1'b1,6'd32, 6'd8,3'b111};	// Note: 3E
	assign memory[	 87	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 88	] =	{1'b1,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 89	] =	{1'b0,6'd28, 6'd8,3'b111};	// Note: 3C
	assign memory[	 90	] =	{1'b1,6'd28, 6'd8,3'b111};	// Note: 3C
	assign memory[	 91	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 92	] =	{1'b1,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 93	] =	{1'b0,6'd18, 6'd24,3'b111};	// Note: 2D
	assign memory[	 94	] =	{1'b1,6'd18, 6'd24,3'b111};	// Note: 2D
	assign memory[	 95	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 96	] =	{1'b1,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	 97	] =	{1'b0,6'd28, 6'd8,3'b111};	// Note: 3C
	assign memory[	 98	] =	{1'b1,6'd28, 6'd8,3'b111};	// Note: 3C
	assign memory[	 99	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	100	] =	{1'b1,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	101	] =	{1'b0,6'd18, 6'd24,3'b111};	// Note: 2D
	assign memory[	102	] =	{1'b1,6'd18, 6'd24,3'b111};	// Note: 2D
	assign memory[	103	] =	{1'b0,6'd16, 6'd8,3'b111};	// Note: 2C
	assign memory[	104	] =	{1'b1,6'd16, 6'd8,3'b111};	// Note: 2C
	assign memory[	105	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	106	] =	{1'b1,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	107	] =	{1'b0,6'd25, 6'd26,3'b111};	// Note: 3A
	assign memory[	108	] =	{1'b1,6'd25, 6'd26,3'b111};	// Note: 3A
	assign memory[	109	] =	{1'b0,6'd0, 6'd8,3'b111};	// Note: rest
	assign memory[	110	] =	{1'b1,6'd0, 6'd8,3'b111};	// Note: rest
	assign memory[	111	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	112	] =	{1'b1,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	113	] =	{1'b0,6'd16, 6'd8,3'b111};	// Note: 2C
	assign memory[	114	] =	{1'b1,6'd16, 6'd8,3'b111};	// Note: 2C
	assign memory[	115	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	116	] =	{1'b1,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	117	] =	{1'b0,6'd18, 6'd24,3'b111};	// Note: 2D
	assign memory[	118	] =	{1'b1,6'd18, 6'd24,3'b111};	// Note: 2D
	assign memory[	119	] =	{1'b0,6'd28, 6'd8,3'b111};	// Note: 3C
	assign memory[	120	] =	{1'b1,6'd28, 6'd8,3'b111};	// Note: 3C
	assign memory[	121	] =	{1'b0,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	122	] =	{1'b1,6'd27, 6'd8,3'b111};	// Note: 3B
	assign memory[	123	] =	{1'b0,6'd25, 6'd40,3'b111};	// Note: 3A
	assign memory[	124	] =	{1'b1,6'd25, 6'd40,3'b111};	// Note: 3A
	assign memory[	125	] =	{1'b1,6'd0, 6'd24,3'b111};	// Note: rest
	assign memory[	126	] =	{1'b0,6'd0, 6'd24,3'b111};	// Note: rest
	assign memory[	127	] =	{1'b1,6'd0, 6'd24,3'b111};	// Note: rest
endmodule					
