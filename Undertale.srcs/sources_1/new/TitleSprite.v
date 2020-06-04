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
    reg [9:0] TitleX = 0; // Bee X start position
    reg [8:0] TitleY = 0; // Bee Y start position
    localparam TitleWidth = 796; // Bee width in pixels
    localparam TitleHeight = 548; // Bee height in pixels
    reg [1:0] nextState = 0;
   always @ (posedge Pclk)
    begin
        // EDIT nextState to 3 when Menu is ready 
        if (aactive)
            begin // check if xx,yy are within the confines of the Bee character
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
