//---------------------------------------------------
// BeeRom Module - Single Port ROM : Digilent Basys 3               
// BeeInvaders Tutorial 2 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//---------------------------------------------------
`timescale 1ns / 1ps

// Setup BeeRom Module
module TitleRom(
    input wire [9:0] i_addr,
    input wire i_clk2,
    output reg [7:0] o_data
    );

    (*ROM_STYLE="block"*) reg [7:0] memory_array [0:436207];

    initial begin
            $readmemh("name.mem", memory_array);
    end

    always @ (posedge i_clk2)
            o_data <= memory_array[i_addr];     
endmodule
