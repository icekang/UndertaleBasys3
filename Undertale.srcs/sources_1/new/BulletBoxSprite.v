//--------------------------------------------------
// BeeSprite Module : Digilent Basys 3               
// BeeInvaders Tutorial 3 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//--------------------------------------------------
`timescale 1ns / 1ps

// Setup BeeSprite Module
module BulletBoxSprite(
    input wire [9:0] xx, // current x position
    input wire [9:0] yy, // current y position
    input wire aactive, // high during active pixel drawing
    output reg BBSpriteOn, // 1=on, 0=off
    output reg [7:0] dataout, // 8 bit pixel value from Bee.mem
    input wire Pclk // 25MHz pixel clock
    );

    // setup character positions and sizes
    reg [9:0] BulletBoxX = 275; // Bee X start position
    reg [8:0] BulletBoxY = 275; // Bee Y start position
    localparam BulletBoxWidth = 250; // Bee width in pixels
    localparam BulletBoxHeight = 250; // Bee height in pixels
    localparam BulletBoxThick = 10; // Bee height in pixels
    localparam WhiteIdx = 3;  
    always @ (posedge Pclk)
    begin
        if (aactive)
            begin // check if xx,yy are within the confines of the Bee character
                if (xx==BulletBoxX && yy==BulletBoxY)
                    begin
                        BBSpriteOn <=1;
                        dataout <= WhiteIdx;//White index 
                    end
                else
                if (
                     (
                        (xx>BulletBoxX-1) && (xx<BulletBoxX+BulletBoxThick+1) ||
                        (xx>=BulletBoxX+BulletBoxWidth-BulletBoxThick) && (xx<=BulletBoxX+BulletBoxWidth)
                      ) && 
                        (yy>BulletBoxY-1) && (yy<BulletBoxY+BulletBoxHeight+1)
                    )
                    begin
                        BBSpriteOn <=1;
                        dataout <= WhiteIdx;//White index 
                    end
                else
                if (
                     (
                        (yy>=BulletBoxY) && (yy<=BulletBoxY+BulletBoxThick) ||
                        (yy>=BulletBoxY+BulletBoxHeight-BulletBoxThick) && (yy<=BulletBoxY+BulletBoxHeight)
                      ) && 
                        (xx>BulletBoxX-1) && (xx<BulletBoxX+BulletBoxWidth+1)
                    )
                    begin
                        BBSpriteOn <=1;
                        dataout <= WhiteIdx;
                    end
                else
                    BBSpriteOn <=0;
            end
    end
endmodule