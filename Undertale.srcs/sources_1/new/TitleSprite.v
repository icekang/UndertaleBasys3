`timescale 1ns / 1ps

module TitleSprite(
    input wire [9:0] xx, // current x position
    input wire [9:0] yy, // current y position
    input wire aactive, // high during active pixel drawing
    output reg SpriteOn, // 1=on, 0=off
    output wire [7:0] dataout, // 8 bit pixel value from Bee.mem
    input wire Pclk, // 25MHz pixel clock
    input wire clk,
    input wire Kclk
    );
    
    reg [18:0] address;
    TitleRom TitleVRom (.i_addr(address),.i_clk2(Pclk),.o_data(dataout));
    
    // setup character positions and sizes
    reg [9:0] TitleX = 25; // Bee X start position
    reg [8:0] TitleY = 25; // Bee Y start position
    localparam TitleWidth = 796;//199; // Bee width in pixels
    localparam TitleHeight = 548;//145; // Bee height in pixels
    
//    NokauanRom NokRom (.i_Nokaddr(address),.i_clk2(Pclk),.o_Nokdata(dataout));

//    // setup character positions and sizes
//    reg [9:0] SpriteX = 312; // Sprite X start position
//    reg [8:0] SpriteY = 100; // Sprite Y start position
//    localparam SpriteWidth = 176; // Sprite width in pixels
//    localparam SpriteHeight = 161; // Sprite height in pixels
    
    reg [1:0] nextState = 0;
   always @ (posedge Pclk)
    begin
        // EDIT nextState to 3 when Menu is ready 
        if (aactive)
            begin // check if xx,yy are within the confines of the Bee character
//                if (xx==SpriteX-1 && yy==SpriteY)
//                    begin
//                        address <= 0;
//                        SpriteOn <=1;
//                    end
//                if ((xx>SpriteX-1) && (xx<SpriteX+SpriteWidth) && (yy>SpriteY-1) && (yy<SpriteY+SpriteHeight))
//                    begin
//                        address <= address + 1;
//                        SpriteOn <=1;
//                    end
                if (xx==TitleX-1 && yy==TitleY)
                    begin
                        address <= 0;
                        SpriteOn <=1;
                    end
                if ((xx>TitleX-1) && (xx<TitleX+TitleWidth) && (yy>TitleY-1) && (yy<TitleY+TitleHeight))
                    begin
                        address <= address + 1;
                        SpriteOn <=1;
                    end
                else
                    SpriteOn <=0;
            end
        end
endmodule
