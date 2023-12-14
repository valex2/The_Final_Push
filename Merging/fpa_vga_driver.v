//=============================================================================
// VGA display driver for Final Project
//
// Uses TCGROM to display characters based on current/prev note and harmonics/stereo/overtones toggling
//
// Updated: 2020/07/12
//=============================================================================

`include "dvi_defines.v"

`define TEXT_X_LOC 128
`define LINE_X_LOC 190
`define FPA_TEXT_Y_LOC_DIV_32 12 // 64 absolute
`define SYMBOLS_TEXT_Y_LOC_DIV_32 2 // 192 absolute
`define FEATURES_TEXT_Y_LOC_DIV_32 14 // 288 absolute
`define LINE_Y_LOC  0
`define LINE_Y_WIDTH 3 
//`define RESULT_TEXT_Y_LOC_DIV_32 11 // 352 absolute

module fpa_vga_driver(
    input clk, 
    input [`log2NUM_COLS-1:0] XPos, 
    input [`log2NUM_ROWS-1:0] YPos, 
    input Valid, 
    
    input [5:0] input_note1, 
    input [5:0] note_duration1, 
    input new_note_available_1,
    
    input [5:0] input_note2, 
    input [5:0] note_duration2, 
    input new_note_available_2,

    input [5:0] input_note3, 
    input [5:0] note_duration3, 
    input new_note_available_3,
    
    input stereo_on, harmonics_on, overtones_on, 
    input [3:0] overtones,
    input next_button,
    input play_button,

    output wire [5:0] vga_rgb
);

    wire [7:0] tcgrom_d, tcgrom_q;
    reg        color;
    reg  [5:0] char_selection;
    wire [5:0] char_selection_q;
    reg  [5:0] char_color;
    wire [5:0] char_color_q, char_color_2_q;
    wire       lineValid;

    wire [`log2NUM_COLS-1:0] XPos_offset = XPos - `TEXT_X_LOC;
    
    // lookup table for note indices
    function [5:0] get_note_chars;
        input [5:0] input_note; 
        begin
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
                6'd0 : get_note_chars = 6'd32; // "rest"
              default: get_note_chars = 6'd32;  // edge case for unknown note
            endcase
        end
    endfunction      

//=============================================================================
//  Hook up the VGA modules and define the output colors
//=============================================================================
    
    reg [11:0] cur_note1_chars, cur_note2_chars, cur_note3_chars; // these track the display value of the current note
    wire [11:0] prev_note1_chars, prev_note2_chars, prev_note3_chars, prevprev_note1_chars, prevprev_note2_chars, prevprev_note3_chars; // flopped outputs to display the past note (we want these to be clocked at the new sample from music player, the same as the initial inputs)
    
    // previous note flops, only update when we load a new note
    dff #(12) note1_char_reg (
        .clk(new_note_available_1),
        .d(cur_note1_chars),
        .q(prev_note1_chars)
    );
    
    dff #(12) note2_char_reg (
        .clk(new_note_available_2),
        .d(cur_note2_chars),
        .q(prev_note2_chars)
    );
    
    dff #(12) note3_char_reg (
        .clk(new_note_available_3),
        .d(cur_note3_chars),
        .q(prev_note3_chars)
    );
    // previous previous note flops, only update when we load a new note
    dff #(12) note1_char_reg2 (
        .clk(new_note_available_1),
        .d(prev_note1_chars),
        .q(prevprev_note1_chars)
    );
    
    dff #(12) note2_char_reg2 (
        .clk(new_note_available_2),
        .d(prev_note2_chars),
        .q(prevprev_note2_chars)
    );
    
    dff #(12) note3_char_reg2 (
        .clk(new_note_available_3),
        .d(prev_note3_chars),
        .q(prevprev_note3_chars)
    );
    
    // Display the correct characters
    always @* begin
        cur_note1_chars = get_note_chars(input_note1);
        cur_note2_chars = get_note_chars(input_note2);
        cur_note3_chars = get_note_chars(input_note3);
               
        case (YPos[`log2NUM_ROWS-1:5])
            // First row of text
            `SYMBOLS_TEXT_Y_LOC_DIV_32: begin
            char_color = 6'b01111; // Set the color for the text
                case (XPos_offset[`log2NUM_COLS-1:5])
                    0: begin
                        if (play_button) begin
                            char_selection = 6'd42;
                        end else begin
                            char_selection = 6'd62;
                        end
                    end
                    2: begin
                        if(next_button) begin
                            char_selection = 6'd63;
                        end else begin
                            char_selection = 6'b100000; 
                        end 
                    end
                    default: char_selection = 6'b100000;
                endcase
            end

            `FPA_TEXT_Y_LOC_DIV_32: begin
               char_color = 6'b001111;
               case (XPos_offset[`log2NUM_COLS-1:5])
                    0: char_selection = 6'd14;  // 'N'
                    1: char_selection = 6'd15;  // 'O'
                    2: char_selection = 6'd20;   // 'T' (5th letter)
                    3: char_selection = 6'd05;  // 'E' (22nd letter)
                    4: char_selection = 6'd19;  // 'S'
                    5: char_selection = 6'd33;  // ' ' (space)
                    6: char_selection = 6'd32;  // ' ' (space)
                    7: begin 
                        char_selection = cur_note1_chars; // First character of the note
                        char_color = 6'b001100;
                    end
                    8: begin 
                        char_selection = cur_note2_chars;  // Second character of the note
                        char_color = 6'b001100;
                    end
                    9: begin
                        char_selection = cur_note3_chars;
                        char_color = 6'b001100;
                    end
                    10: char_selection = 6'd32;  // ' ' (space)
                    11: begin
                        char_selection = prev_note1_chars; // First character of the note
                        char_color = 6'b110000;
                    end
                    12: begin
                        char_selection = prev_note2_chars;  // Second character of the note
                        char_color = 6'b110000;
                    end
                    13: begin 
                        char_selection = prev_note3_chars;
                        char_color = 6'b110000;
                    end
                    14: char_selection = 6'd32;  // ' ' (space)
                    15: begin 
                        char_selection = cur_note1_chars; // First character of the note
                        char_color = 6'b111000;
                    end
                    16: begin 
                        char_selection = prevprev_note1_chars; // First character of the note
                        char_color = 6'b111000;
                    end
                    17: begin 
                        char_selection = prevprev_note2_chars;  // Second character of the note
                        char_color = 6'b111000;
                    end
                    18: begin
                        char_selection = prevprev_note3_chars;
                        char_color = 6'b111000;
                    end
                    19: char_selection = 6'd32;  // ' ' (space)
                    default: char_selection = 6'b100000; // Blank for other positions
                endcase
             end
        
            `FEATURES_TEXT_Y_LOC_DIV_32: begin
                char_color = 6'b111111; // Set the color for the text
                case (XPos_offset[`log2NUM_COLS-1:5])
                    // Logic to display "STEREO"
                    0: char_selection = stereo_on ? 6'd19 : 6'b100000; // 'S' (19th letter)
                    1: char_selection = stereo_on ? 6'd20 : 6'b100000; // 'T' (20th letter)
                    2: char_selection = stereo_on ? 6'd5 : 6'b100000;  // 'E' (5th letter)
                    3: char_selection = stereo_on ? 6'd18 : 6'b100000; // 'R' (18th letter)
                    4: char_selection = stereo_on ? 6'd5 : 6'b100000;  // 'E' (5th letter)
                    5: char_selection = stereo_on ? 6'd15 : 6'b100000; // 'O' (15th letter)
                    // Space between words
                    6: char_selection = 6'd32; // ' ' (space)
                    // Logic to display "HARMONICS"
                    7: char_selection = harmonics_on ? 6'd8 : 6'b100000;  // 'H' (8th letter)
                    8: char_selection = harmonics_on ? 6'd1 : 6'b100000;  // 'A' (1st letter)
                    9: char_selection = harmonics_on ? 6'd18 : 6'b100000; // 'R' (18th letter)
                    10: char_selection = harmonics_on ? 6'd13 : 6'b100000;// 'M' (13th letter)
                    
                    11: char_selection = 6'd32; // ' ' (space)
                    
                    // Logic to display "OVERTONES"
//                    7: char_selection = overtones_on ? 6'd15 : 6'b100000;// 'O' (15th letter)
//                    8: char_selection = overtones_on ? 6'd22 : 6'b100000;// 'V' (22nd letter)
//                    9: char_selection = overtones_on ? 6'd5 : 6'b100000; // 'E' (5th letter)
//                    10: char_selection = overtones_on ? 6'd18 : 6'b100000;// 'R' (18th letter)
                    12: char_selection = overtones_on ? 6'd20 : 6'b100000;// 'T' (20th letter)
                    13: char_selection = overtones_on ? 6'd15 : 6'b100000;// 'O' (15th letter)
                    14: char_selection = overtones_on ? 6'd14 : 6'b100000;// 'N' (14th letter)
                    15: char_selection = overtones_on ? 6'd5 : 6'b100000; // 'E' (5th letter)
                    16: char_selection = overtones_on ? 6'd19: 6'b100000;// 'S' (19th letter)
                    
                    17: char_selection = 6'd32; // ' ' (space)
                    
                    18: begin
                        if(overtones[3]) begin
                            char_selection = 6'd49;
                        end else begin
                            char_selection = 6'd48;
                        end
                    end
                    19: begin
                        if(overtones[2]) begin
                            char_selection = 6'd49;
                        end else begin
                            char_selection = 6'd48;
                        end
                    end
                    20: begin
                        if(overtones[1]) begin
                            char_selection = 6'd49;
                        end else begin
                            char_selection = 6'd48;
                        end
                    end
                    21: begin
                        if(overtones[0]) begin
                            char_selection = 6'd49;
                        end else begin
                            char_selection = 6'd48;                    
                        end
                    end       
//                23: char_selection = harmonics_on ? 6'd15 : 6'b100000;// 'O' (15th letter)
//                24: char_selection = harmonics_on ? 6'd14 : 6'b100000;// 'N' (14th letter)
//                25: char_selection = harmonics_on ? 6'd9 : 6'b100000; // 'I' (9th letter)
//                26: char_selection = harmonics_on ? 6'd3 : 6'b100000; // 'C' (3rd letter)
//                27: char_selection = harmonics_on ? 6'd19 : 6'b100000;// 'S' (19th letter)
        
                    // Space between words
                    23: char_selection = 6'd32; // ' ' (space)
                    default: char_selection = 6'b100000; // Blank for other positions
                endcase
            end
            default: begin
                char_selection = 6'b100000;
                char_color = 6'b111111;
            end
        endcase
    end

     //Add the addition horizontal line
    assign lineValid  = (XPos >= `LINE_X_LOC)
                     && (XPos <= `LINE_X_LOC + 512)
                     && (YPos >= `LINE_Y_LOC)
                     && (YPos < `LINE_Y_LOC + `LINE_Y_WIDTH); 

    // Register the output of the tcgrom
    tcgrom tcgrom(.addr({char_selection_q, YPos[4:2]}), .data(tcgrom_d));
    //tcgrom tcgrom(.addr({char_selection_q, YPos[2:0]}), .data(tcgrom_d));

    always @* begin     
        case (XPos[4:2])
            3'h0 : color = tcgrom_q[7];
            3'h1 : color = tcgrom_q[6];
            3'h2 : color = tcgrom_q[5];
            3'h3 : color = tcgrom_q[4];
            3'h4 : color = tcgrom_q[3];
            3'h5 : color = tcgrom_q[2];
            3'h6 : color = tcgrom_q[1];
            3'h7 : color = tcgrom_q[0];                            
        endcase 
    end  

    // Generates the RGB signals based on raster position
    assign vga_rgb = lineValid ? 6'b111111
                     : ((Valid && color) ? char_color_2_q : 6'b0);

    //For character display
    dff #(8) tcgrom_reg (.clk(clk), .d(tcgrom_d), .q(tcgrom_q));
    dff #(6) char_selection_reg (.clk(clk), .d(char_selection), .q(char_selection_q));
    dff #(6) char_color_reg (.clk(clk), .d(char_color), .q(char_color_q));
    dff #(6) char_color_2_reg (.clk(clk), .d(char_color_q), .q(char_color_2_q));

endmodule
