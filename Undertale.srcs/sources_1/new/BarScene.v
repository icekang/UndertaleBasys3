//--------------------------------------------------
// BeeSprite Module : Digilent Basys 3               
// BeeInvaders Tutorial 3 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//--------------------------------------------------
`timescale 1ns / 1ps

// BarScene Module
module BarScene(
    input wire [9:0] xx, // current x position
    input wire [9:0] yy, // current y position
    input wire aactive, // high during active pixel drawing (on screen)
    input wire Pclk, // 25MHz pixel clock
    input wire Reset, // 1=restart, 0=continue
    input wire ibtnX, // 1=pressX
    output reg [3:0] oRED,
    output reg [3:0] oGREEN,
    output reg [3:0] oBLUE,
    output reg isEnding,
    input wire [10:0] health,
    output reg [10:0] nextHealth
);

    // setup character positions and sizes
    reg isEnding = 0;
    reg [9:0] BarX = 0; // Bee X start position
    reg [8:0] BarY = 225; // Bee Y start position
    localparam BarWidth = 20; // Bee width in pixels
    localparam BarHeight = 150; // Bee height in pixels

    localparam GoodScaleX = 360;
    localparam GoodScaleY = 80;
    localparam GoodScaleWidth = 70;
    localparam GoodScaleHeight = 270;
    reg [1:0] dir = 1;
    reg [9:0] delaliens = 0;
//    always @(posedge Reset)
//    begin
//        BarX = 0;
//        isEnding = 0;
//    end
    always @(posedge Pclk)
    begin
        if (xx==800 && yy==600)
            begin
                delaliens<=delaliens+1;
                if (delaliens>5)
                    begin
                        if(dir == 1)
                            begin
                                BarX <= BarX + 15;
                                if (BarX + BarWidth > 750)
                                    dir <= 0;
                            end
                        if(dir == 0)
                            begin
                                BarX <= BarX - 15;
                                if (BarX <= 15)
                                    dir <= 1;
                            end
                    end
            end
    end
    
    always @(posedge Pclk)
    begin
        if (aactive)
            begin
                // render moving bar
                if (BarX <= xx && xx <= BarX + BarWidth
                &&  BarY <= yy && yy <= BarY + BarHeight) {oRED, oGREEN, oBLUE} <= 12'hFFF;
                
                // render good static scale
                else 
                if (GoodScaleX <= xx && xx <= GoodScaleX + GoodScaleWidth
                &&  GoodScaleX <= xx && xx <= GoodScaleX + GoodScaleWidth) 
                begin
                    {oRED, oGREEN, oBLUE} <= 12'h5FB;
                end

                // render empty
                else {oRED, oGREEN, oBLUE} <= 12'h000;
            end
    end

    always @(posedge ibtnX)
    begin
        // press x on good scale (HIT)
        if (GoodScaleX < BarX + BarWidth && BarX < GoodScaleX + GoodScaleWidth)
            begin
                nextHealth <= health - 10;    
                isEnding <= 1;
            end
        else // (MISS)
            isEnding = 1;
    end
endmodule