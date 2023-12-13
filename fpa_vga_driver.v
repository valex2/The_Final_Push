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
//    input [7:0] aIn,
//    input [7:0] bIn,
//    input [7:0] result,
    input [`log2NUM_COLS-1:0] XPos, 
    input [`log2NUM_ROWS-1:0] YPos, 
    input Valid, 
    
    // new inputs from angelina

    input [5:0] input_note1, // Current note index
    input [5:0] note_duration1, // Previous note index
    input [5:0] input_note2, // Current note index
    input [5:0] note_duration2, // Previous note index
    input [5:0] input_note3, // Current note index
    input [5:0] note_duration3, // Previous note index
    input stereo_on, harmonics_on, overtones_on, // Feature flags
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

    // angelina added
    reg [5:0] next_timer;
    reg [5:0] next_cur_note1, next_cur_note2, next_cur_note3;

    wire [5:0] cur_note1, cur_note2, cur_note3, current_duration1, timer, previous_note1, previous_note2, previous_note3;
    reg reset_timer;
    reg [11:0] prev_note1_chars, cur_note1_chars, prev_note2_chars, cur_note2_chars, prev_note3_chars, cur_note3_chars;
    //wire [11:0] prev_note1_chars2, cur_note1_chars2, prev_note2_chars2, cur_note2_chars2, prev_note3_chars2, cur_note3_chars2;
    wire timer_expired = (timer == note_duration1);
//    assign cur_note1 = input_note1;
//    assign cur_note2 = input_note2;
//    assign cur_note3 = input_note3;
//    always @(*) begin
//        reset_timer = 0;
//        next_timer = timer + 1'b1;
//        next_current_note = current_note;

//        if (current_note1 != current_note1) begin
//            reset_timer = 1;
//            next_current_note = current_note1;
//        end else if (timer_expired) begin
//            reset_timer = 1;
//            next_current_note = 6'd0; // Representing no note or rest
//        end
//    end

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
                6'd0 : get_note_chars = 6'd00; // "rest"
              default: get_note_chars = 6'd01;  // edge case for unknown note
       endcase
   end
endfunction      
/*                6'd1 : get_note_chars = {6'd01, 6'd01};  // "1A"
                6'd2 : get_note_chars = {6'd01, 6'd01};  // "1A#Bb"
                6'd3 : get_note_chars = {6'd01, 6'd02};  // "1B"
                6'd4 : get_note_chars = {6'd01, 6'd03};  // "1C"
                6'd5 : get_note_chars = {6'd01, 6'd03};  // "1C#Db"
                6'd6 : get_note_chars = {6'd01, 6'd04};  // "1D"
                6'd7 : get_note_chars = {6'd01, 6'd04};  // "1D#Eb"
                6'd8 : get_note_chars = {6'd01, 6'd05};  // "1E"
                6'd9 : get_note_chars = {6'd01, 6'd06};  // "1F"
                6'd10: get_note_chars = {6'd01, 6'd06};  // "1F#Gb"
                6'd11: get_note_chars = {6'd01, 6'd07};  // "1G"
                6'd12: get_note_chars = {6'd01, 6'd07};  // "1G#Ab"
                6'd13: get_note_chars = {6'd02, 6'd01};  // "2A"
                6'd14: get_note_chars = {6'd02, 6'd01};  // "2A#Bb"
                6'd15: get_note_chars = {6'd02, 6'd02};  // "2B"
                6'd16: get_note_chars = {6'd02, 6'd03};  // "2C"
                6'd17: get_note_chars = {6'd02, 6'd03};  // "2C#Db"
                6'd18: get_note_chars = {6'd02, 6'd04};  // "2D"
                6'd19: get_note_chars = {6'd02, 6'd04};  // "2D#Eb"
                6'd20: get_note_chars = {6'd02, 6'd05};  // "2E"
                6'd21: get_note_chars = {6'd02, 6'd06};  // "2F"
                6'd22: get_note_chars = {6'd02, 6'd06};  // "2F#Gb"
                6'd23: get_note_chars = {6'd02, 6'd07};  // "2G"
                6'd24: get_note_chars = {6'd02, 6'd07};  // "2G#Ab"
                6'd25: get_note_chars = {6'd03, 6'd01};  // "3A"
                6'd26: get_note_chars = {6'd03, 6'd01};  // "3A#Bb"
                6'd27: get_note_chars = {6'd03, 6'd02};  // "3B"
                6'd28: get_note_chars = {6'd03, 6'd03};  // "3C"
                6'd29: get_note_chars = {6'd03, 6'd03};  // "3C#Db"
                6'd30: get_note_chars = {6'd03, 6'd04};  // "3D"
                6'd31: get_note_chars = {6'd03, 6'd04};  // "3D#Eb"
                6'd32: get_note_chars = {6'd03, 6'd05};  // "3E"
                6'd33: get_note_chars = {6'd03, 6'd06};  // "3F"
                6'd34: get_note_chars = {6'd03, 6'd06};  // "3F#Gb"
                6'd35: get_note_chars = {6'd03, 6'd07};  // "3G"
                6'd36: get_note_chars = {6'd03, 6'd07};  // "3G#Ab"
                6'd37: get_note_chars = {6'd04, 6'd01};  // "4A"
                6'd38: get_note_chars = {6'd04, 6'd01};  // "4A#Bb"
                6'd39: get_note_chars = {6'd04, 6'd02};  // "4B"
                6'd40: get_note_chars = {6'd04, 6'd03};  // "4C"
                6'd41: get_note_chars = {6'd04, 6'd03};  // "4C#Db"
                6'd42: get_note_chars = {6'd04, 6'd04};  // "4D"
                6'd43: get_note_chars = {6'd04, 6'd04};  // "4D#Eb"
                6'd44: get_note_chars = {6'd04, 6'd05};  // "4E"
                6'd45: get_note_chars = {6'd04, 6'd06};  // "4F"
                6'd46: get_note_chars = {6'd04, 6'd06};  // "4F#Gb"
                6'd47: get_note_chars = {6'd04, 6'd07};  // "4G"
                6'd48: get_note_chars = {6'd04, 6'd07};  // "4G#Ab"
                6'd49: get_note_chars = {6'd05, 6'd01};  // "5A"
                6'd50: get_note_chars = {6'd05, 6'd01};  // "5A#Bb"
                6'd51: get_note_chars = {6'd05, 6'd02};  // "5B"
                6'd52: get_note_chars = {6'd05, 6'd03};  // "5C"
                6'd53: get_note_chars = {6'd05, 6'd03};  // "5C#Db"
                6'd54: get_note_chars = {6'd05, 6'd04};  // "5D"
                6'd55: get_note_chars = {6'd05, 6'd04};  // "5D#Eb"
                6'd56: get_note_chars = {6'd05, 6'd05};  // "5E"
                6'd57: get_note_chars = {6'd05, 6'd06};  // "5F"
                6'd58: get_note_chars = {6'd05, 6'd06};  // "5F#Gb"
                6'd59: get_note_chars = {6'd05, 6'd07};  // "5G"
                6'd60: get_note_chars = {6'd05, 6'd07};  // "5G#Ab"
                6'd61: get_note_chars = {6'd06, 6'd01};  // "6A"
                6'd62: get_note_chars = {6'd06, 6'd01};  // "6A#Bb"
                6'd63: get_note_chars = {6'd06, 6'd02};  // "6B"
                6'd0 : get_note_chars = {6'd72, 6'd00}; // "rest"
              default: get_note_chars = {6'd00, 6'd0};  // edge case for unknown note
            endcase*/
//        end
//    endfunction

//get_note_chars prev_note1 (
//        .input_note(previous_note1), .get_note_chars(prev_note1_chars)
//        );
//get_note_chars prev_note2 (
//        .input_note(previous_note2), .get_note_chars(prev_note2_chars)
//        );
//get_note_chars prev_note3 (
//        .input_note(previous_note3), .get_note_chars(prev_note3_chars)
//        );
//get_note_chars curr_note1 (
//        .input_note(cur_note1), .get_note_chars(cur_note1_chars)
//        );
//get_note_chars curr_note2 (
//        .input_note(cur_note2), .get_note_chars(cur_note2_chars)
//        );
//get_note_chars curr_note3 (
//        .input_note(cur_note3), .get_note_chars(prev_note3_chars)
//        );
//=============================================================================
//  Hook up the VGA modules and define the output colors
//=============================================================================
    // Display the correct characters
    always @* begin
        //char_selection = 6'b100000;
        //char_color = 6'b111111;  // RRBBGG
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
                        char_selection = 6'd45;
                    end else begin
                        char_selection = 6'd46;
                    end
                    end
                    20: begin
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
               char_color = 6'b01111;
               case (XPos_offset[`log2NUM_COLS-1:5])
                0: char_selection = 6'd14;  // 'N'
                1: char_selection = 6'd15;  // 'O'
                2: char_selection = 6'd20;   // 'T' (5th letter)
                3: char_selection = 6'd05;  // 'E' (22nd letter)
                4: char_selection = 6'd19;  // 'S'
                5: char_selection = 6'd33;  // ' ' (space)
                6: char_selection = 6'd32;  // ' ' (space)
                7: char_selection = prev_note1_chars; // First character of the note
                8: char_selection = prev_note2_chars;  // Second character of the note
                9: char_selection = prev_note3_chars;
                10: char_selection = 6'd32;  // ' ' (space)
                11: char_selection = cur_note1_chars; // First character of the note
                12: char_selection = cur_note2_chars;  // Second character of the note
                13: char_selection = cur_note3_chars;
                14: char_selection = 6'd32; //space
//                15: char_selection = cur_note1_chars; // First character of the note
//                16: char_selection = cur_note2_chars;  // Second character of the note
//                17: char_selection = cur_note3_chars;
                default: char_selection = 6'b100000; // Blank for other positions
            endcase
      end
//             char_color = 6'b101010;
//             case (XPos_offset[`log2NUM_COLS-1:5])
//             0: char_selection = 6'd16;  // 'P' (16th letter)
//             1: char_selection = 6'd18;  // 'L' (18th letter)
//             2: char_selection = 6'd5;   // 'E' (5th letter)
//             3: char_selection = 6'd22;  // 'V' (22nd letter)
//             4: char_selection = 6'd45;  // ''
//             5: char_selection = 6'd32;  // ' ' (space)
//             6: char_selection = prev_note_chars[11:6]; // First character of the note
//             7: char_selection = prev_note_chars[5:0];  // Second character of the note
//             default: char_selection = 6'b100000; // Blank for other positions
//            endcase
//        end

//        `CURRENT_TEXT_Y_LOC_DIV_32: begin
//            char_color = 6'b111111; // Set the color for the text

//            case (XPos_offset[`log2NUM_COLS-1:5])
//                0: char_selection = 6'd03;   // 'C' (3rd letter)
//                1: char_selection = 6'd21;  // 'U' (21st letter)
//                2: char_selection = 6'd18;  // 'R' (18th letter)
//                3: char_selection = 6'd18;  // 'R' (18th letter)
//                4: char_selection = 6'd05;   // 'E' (5th letter)
//                5: char_selection = 6'd14;  // 'N' (14th letter)
//                6: char_selection = 6'd20;  // 'T' (20th letter)
//                7: char_selection = 6'd45;  // '-'
//                8: char_selection = 6'd32;  // ' ' (space)
//                9: char_selection = cur_note_chars[11:6]; // First character of the note
//                10: char_selection = cur_note_chars[5:0]; // Second character of the note
//                default: char_selection = 6'b100000; // Blank for other positions
//            endcase
//        end
        
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
                // Logic to display "OVERTONES"
                7: char_selection = overtones_on ? 6'd15 : 6'b100000;// 'O' (15th letter)
                8: char_selection = overtones_on ? 6'd22 : 6'b100000;// 'V' (22nd letter)
                9: char_selection = overtones_on ? 6'd5 : 6'b100000; // 'E' (5th letter)
                10: char_selection = overtones_on ? 6'd18 : 6'b100000;// 'R' (18th letter)
                11: char_selection = overtones_on ? 6'd20 : 6'b100000;// 'T' (20th letter)
                12: char_selection = overtones_on ? 6'd15 : 6'b100000;// 'O' (15th letter)
                13: char_selection = overtones_on ? 6'd14 : 6'b100000;// 'N' (14th letter)
                14: char_selection = overtones_on ? 6'd5 : 6'b100000; // 'E' (5th letter)
                //25: char_selection = overtones_on ? 6'd50: 6'b100000;// 'S' (19th letter)
                15: begin
                    if(overtones[0]) begin
                       char_selection = 6'd50;
                    end else begin
                        char_selection = 6'd49;
                    end
                end
                16: begin
                    if(overtones[1]) begin
                       char_selection = 6'd49;
                    end else begin
                        char_selection = 6'd48;
                    end
                end
                17: begin
                    if(overtones[2]) begin
                       char_selection = 6'd49;
                    end else begin
                        char_selection = 6'd48;
                    end
                end
                18: begin
                    if(overtones[3]) begin
                       char_selection = 6'd49;
                    end else begin
                        char_selection = 6'd48;                    
                    end
                end       
                // Logic to display "HARMONICS"
                19: char_selection = harmonics_on ? 6'd8 : 6'b100000;  // 'H' (8th letter)
                20: char_selection = harmonics_on ? 6'd1 : 6'b100000;  // 'A' (1st letter)
                21: char_selection = harmonics_on ? 6'd18 : 6'b100000; // 'R' (18th letter)
                22: char_selection = harmonics_on ? 6'd13 : 6'b100000;// 'M' (13th letter)
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

//    // Generates the RGB signals based on raster position
//    assign vga_rgb = lineValid ? 6'b111111
//                     : ((Valid && color) ? char_color_2_q : 6'b0);

    // angelina's flip flops
    dff #(.WIDTH(6)) current_note1_ff (.clk(clk), .d(next_cur_note1), .q(cur_note1));
    dff #(.WIDTH(6)) previous_note1_ff (.clk(clk), .d(cur_note1), .q(previous_note1));
    dff #(.WIDTH(6)) current_note2_ff (.clk(clk), .d(next_cur_note2), .q(cur_note2));
    dff #(.WIDTH(6)) previous_note2_ff (.clk(clk), .d(cur_note2), .q(previous_note2));
    dff #(.WIDTH(6)) current_note3_ff (.clk(clk), .d(next_cur_note3), .q(cur_note3));
    dff #(.WIDTH(6)) previous_note3_ff (.clk(clk), .d(cur_note3), .q(previous_note3));
    //dffre #(.WIDTH(6)) timer_ff (.clk(clk), .r(reset_timer), .en(1'b1), .d(next_timer), .q(timer));

    //For character display
    dff #(8) tcgrom_reg (.clk(clk), .d(tcgrom_d), .q(tcgrom_q));
    dff #(6) char_selection_reg (.clk(clk), .d(char_selection), .q(char_selection_q));
    dff #(6) char_color_reg (.clk(clk), .d(char_color), .q(char_color_q));
    dff #(6) char_color_2_reg (.clk(clk), .d(char_color_q), .q(char_color_2_q));

endmodule












/*case (YPos[`log2NUM_ROWS-1:6])
            // Dummy line to silence ISE warnings; doesn't display anything
            0: char_color = {XPos[2:0], YPos[2:0]};

            // First row of text
            //3: begin
            1: begin
                char_color = 6'b101010;
                case (XPos[`log2NUM_COLS-1:6])
                    0:  char_selection = 6'd06; //F
                    1:  char_selection = 6'd12; //L
                    2:  char_selection = 6'd15; //O
                    3:  char_selection = 6'd01; //A
                    4:  char_selection = 6'd20; //T
                    5:  char_selection = 6'd09; //I
                    6:  char_selection = 6'd14; //N
                    7:  char_selection = 6'd07; //G

                    9:  char_selection = 6'd16; //P
                    10: char_selection = 6'd15; //O
                    11: char_selection = 6'd09; //I
                    12: char_selection = 6'd14; //N
                    13: char_selection = 6'd20; //T

                    15: char_selection = 6'd01; //A
                    16: char_selection = 6'd04; //D
                    17: char_selection = 6'd04; //D
                    18: char_selection = 6'd05; //E
                    19: char_selection = 6'd18; //R
                    default: char_selection = 6'b100000;
                endcase
            end

            // aIn
            //6: begin
            3: begin
                if (XPos[`log2NUM_COLS-1:6] < 8)
                    char_color = 6'b001100;
                else if (!aIn[4])  // Not normalized
                    char_color = 6'b110000;
                else
                    char_color = 6'b111111;
                case (XPos[`log2NUM_COLS-1:6])
                    5:  char_selection = 6'd01; //A
                    6:  char_selection = 6'd09; //I
                    7:  char_selection = 6'd14; //N

                    9:  char_selection = 6'd48 | aIn[7];
                    10: char_selection = 6'd48 | aIn[6];
                    11: char_selection = 6'd48 | aIn[5];

                    13: char_selection = 6'd48 | aIn[4];
                    14: char_selection = 6'd48 | aIn[3];
                    15: char_selection = 6'd48 | aIn[2];
                    16: char_selection = 6'd48 | aIn[1];
                    17: char_selection = 6'd48 | aIn[0];

                    default: char_selection = 6'b100000;
                endcase
            end

            // bIn
            //8: begin
            5: begin
                if (XPos[`log2NUM_COLS-1:6] < 8)
                    char_color = 6'b001100;
                else if (!bIn[4])  // Not normalized
                    char_color = 6'b110000;
                else
                    char_color = 6'b111111;
                case (XPos[`log2NUM_COLS-1:6])
                    3:  char_selection = 6'd43; //+

                    5:  char_selection = 6'd02; //B
                    6:  char_selection = 6'd09; //I
                    7:  char_selection = 6'd14; //N

                    9:  char_selection = 6'd48 | bIn[7];
                    10: char_selection = 6'd48 | bIn[6];
                    11: char_selection = 6'd48 | bIn[5];

                    13: char_selection = 6'd48 | bIn[4];
                    14: char_selection = 6'd48 | bIn[3];
                    15: char_selection = 6'd48 | bIn[2];
                    16: char_selection = 6'd48 | bIn[1];
                    17: char_selection = 6'd48 | bIn[0];

                    default: char_selection = 6'b100000;
                endcase
            end

            // Result
            //11: begin
            8: begin
                if (XPos[`log2NUM_COLS-1:6] < 8)
                    char_color = 6'b000011;
                else if (!result[4] || result < aIn || result < bIn)
                    // not normalized, or result is less than the inputs
                    char_color = 6'b110000;
                else if (&result)  // result is saturated
                    char_color = 6'b111100;
                else
                    char_color = 6'b111111;
                case (XPos[`log2NUM_COLS-1:6])
                    2:  char_selection = 6'd18; //R
                    3:  char_selection = 6'd05; //E
                    4:  char_selection = 6'd19; //S
                    5:  char_selection = 6'd21; //U
                    6:  char_selection = 6'd12; //L
                    7:  char_selection = 6'd20; //T

                    9:  char_selection = 6'd48 | result[7];
                    10: char_selection = 6'd48 | result[6];
                    11: char_selection = 6'd48 | result[5];

                    13: char_selection = 6'd48 | result[4];
                    14: char_selection = 6'd48 | result[3];
                    15: char_selection = 6'd48 | result[2];
                    16: char_selection = 6'd48 | result[1];
                    17: char_selection = 6'd48 | result[0];

                    default: char_selection = 6'b100000;
                endcase
            end
        endcase
*/
