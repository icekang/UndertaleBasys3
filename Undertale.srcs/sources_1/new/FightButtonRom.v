//------------------------------------------------------
// Alien1Rom Module - Single Port ROM : Digilent Basys 3               
// BeeInvaders Tutorial 3 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//------------------------------------------------------
`timescale 1ns / 1ps

// Setup Alien1Rom Module
//92 36
module FightButtonRom(
    input wire [11:0] i_addr,
    input wire i_clk,
    output reg [7:0] o_data // (7:0) 8 bit pixel value from Alien1.mem
    );

    (*ROM_STYLE="block"*) reg [7:0] A1memory_array [0:3312]; // 8 bit values for 806 pixels of Alien1 (31 x 26)

    initial begin
            $readmemh("fight.mem", A1memory_array);
    end

    always @ (posedge i_clk)
            o_data <= A1memory_array[i_addr];     
endmodule
