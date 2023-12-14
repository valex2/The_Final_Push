`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2023 07:33:14 AM
// Design Name: 
// Module Name: get_note_chars
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module get_note_chars(
    input wire [5:0] input_note,
    output reg [5:0] get_note_chars
    );
   
    always @(*) begin
        case (input_note)
                6'd1 : get_note_chars = 6'd01;  // "1A"
                6'd2 : get_note_chars = 6'd01;  // "1A#Bb"
                6'd3 : get_note_chars = 6'd02;  // "1B"
                6'd4 : get_note_chars = 6'd03;  // "1C"
                6'd5 : get_note_chars = 6'd03;  // "1C#Db"
                6'd6 : get_note_chars = 6'd04;  // "1D"
                6'd7 : get_note_chars = 6'd04;  // "1D#Eb"
                6'd8 : get_note_chars = 6'd05;  // "1E"
                6'd9 : get_note_chars = 6'd06;  // "1F"
                6'd10: get_note_chars = 6'd06;  // "1F#Gb"
                6'd11: get_note_chars = 6'd07;  // "1G"
                6'd12: get_note_chars = 6'd07;  // "1G#Ab"
                6'd13: get_note_chars = 6'd01;  // "2A"
                6'd14: get_note_chars = 6'd01;  // "2A#Bb"
                6'd15: get_note_chars = 6'd02;  // "2B"
                6'd16: get_note_chars = 6'd03;  // "2C"
                6'd17: get_note_chars = 6'd03;  // "2C#Db"
                6'd18: get_note_chars = 6'd04;  // "2D"
                6'd19: get_note_chars = 6'd04;  // "2D#Eb"
                6'd20: get_note_chars = 6'd05;  // "2E"
                6'd21: get_note_chars = 6'd06;  // "2F"
                6'd22: get_note_chars = 6'd06;  // "2F#Gb"
                6'd23: get_note_chars = 6'd07;  // "2G"
                6'd24: get_note_chars = 6'd07;  // "2G#Ab"
                6'd25: get_note_chars = 6'd01;  // "3A"
                6'd26: get_note_chars = 6'd01;  // "3A#Bb"
                6'd27: get_note_chars = 6'd02;  // "3B"
                6'd28: get_note_chars = 6'd03;  // "3C"
                6'd29: get_note_chars = 6'd03;  // "3C#Db"
                6'd30: get_note_chars = 6'd04;  // "3D"
                6'd31: get_note_chars = 6'd04;  // "3D#Eb"
                6'd32: get_note_chars = 6'd05;  // "3E"
                6'd33: get_note_chars = 6'd06;  // "3F"
                6'd34: get_note_chars = 6'd06;  // "3F#Gb"
                6'd35: get_note_chars = 6'd07;  // "3G"
                6'd36: get_note_chars = 6'd07;  // "3G#Ab"
                6'd37: get_note_chars = 6'd01;  // "4A"
                6'd38: get_note_chars = 6'd01;  // "4A#Bb"
                6'd39: get_note_chars = 6'd02;  // "4B"
                6'd40: get_note_chars = 6'd03;  // "4C"
                6'd41: get_note_chars = 6'd03;  // "4C#Db"
                6'd42: get_note_chars = 6'd04;  // "4D"
                6'd43: get_note_chars = 6'd04;  // "4D#Eb"
                6'd44: get_note_chars = 6'd05;  // "4E"
                6'd45: get_note_chars = 6'd06;  // "4F"
                6'd46: get_note_chars = 6'd06;  // "4F#Gb"
                6'd47: get_note_chars = 6'd07;  // "4G"
                6'd48: get_note_chars = 6'd07;  // "4G#Ab"
                6'd49: get_note_chars = 6'd01;  // "5A"
                6'd50: get_note_chars = 6'd01;  // "5A#Bb"
                6'd51: get_note_chars = 6'd02;  // "5B"
                6'd52: get_note_chars = 6'd03;  // "5C"
                6'd53: get_note_chars = 6'd03;  // "5C#Db"
                6'd54: get_note_chars = 6'd04;  // "5D"
                6'd55: get_note_chars = 6'd04;  // "5D#Eb"
                6'd56: get_note_chars = 6'd05;  // "5E"
                6'd57: get_note_chars = 6'd06;  // "5F"
                6'd58: get_note_chars = 6'd06;  // "5F#Gb"
                6'd59: get_note_chars = 6'd07;  // "5G"
                6'd60: get_note_chars = 6'd07;  // "5G#Ab"
                6'd61: get_note_chars = 6'd01;  // "6A"
                6'd62: get_note_chars = 6'd01;  // "6A#Bb"
                6'd63: get_note_chars = 6'd02;  // "6B"
                6'd0 : get_note_chars = 6'd00; // "rest"
              default: get_note_chars = 6'd01;  // edge case for unknown note
   endcase
end     
endmodule
