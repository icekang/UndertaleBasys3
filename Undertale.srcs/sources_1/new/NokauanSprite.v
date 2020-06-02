//--------------------------------------------------
// SpriteSprite Module : Digilent Basys 3               
// SpriteInvaders Tutorial 3 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//--------------------------------------------------
`timescale 1ns / 1ps

// Setup SpriteSprite Module
module NokauanSprite(
    input wire [9:0] xx, // current x position
    input wire [9:0] yy, // current y position
    input wire aactive, // high during active pixel drawing
    output reg SpriteOn, // 1=on, 0=off
    output wire [7:0] dataout, // 8 bit pixel value from Sprite.mem
    input wire Pclk // 25MHz pixel clock
    );

    // instantiate SpriteRom code
    reg [14:0] address; // 2^10 or 1024, need 34 x 27 = 918
    NokauanRom NokRom (.i_Nokaddr(address),.i_clk2(Pclk),.o_Nokdata(dataout));

    // setup character positions and sizes
    reg [9:0] SpriteX = 312; // Sprite X start position
    reg [8:0] SpriteY = 100; // Sprite Y start position
    localparam SpriteWidth = 176; // Sprite width in pixels
    localparam SpriteHeight = 161; // Sprite height in pixels
    always @ (posedge Pclk)
    begin
        if (aactive)
            begin // check if xx,yy are within the confines of the Sprite character
                if (xx==SpriteX-1 && yy==SpriteY)
                    begin
                        address <= 0;
                        SpriteOn <=1;
                    end
                if ((xx>SpriteX-1) && (xx<SpriteX+SpriteWidth) && (yy>SpriteY-1) && (yy<SpriteY+SpriteHeight))
                    begin
                        address <= address + 1;
                        SpriteOn <=1;
                    end
                else
                    SpriteOn <=0;
            end
    end
endmodule