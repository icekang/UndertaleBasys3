`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2020 02:36:15 AM
// Design Name: 
// Module Name: NokauanRom
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

//w h 176x161
module NokauanRom(
    input wire [14:0] i_Nokaddr,
    input wire i_clk2,
    output reg [7:0] o_Nokdata
    );

    (*ROM_STYLE="block"*) reg [7:0] Nokmemory_array [0:28335];

    initial begin
            $readmemh("nokauan.mem", Nokmemory_array);
    end

    always @ (posedge i_clk2)
            o_Nokdata <= Nokmemory_array[i_Nokaddr];     
endmodule
