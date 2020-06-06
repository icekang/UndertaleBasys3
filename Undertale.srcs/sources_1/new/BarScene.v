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
    
    input wire iCLK,
    input wire iPS2Clk,
    input wire iPS2Data,
    
    input wire [1:0] noksel,
    
    input wire [10:0] hp_mon1,
    input wire [10:0] hp_mon2,
    input wire [10:0] hp_mon3,
    output reg [10:0] o_hp_mon1,
    output reg [10:0] o_hp_mon2,
    output reg [10:0] o_hp_mon3,
    
    input wire [3:0] state,
    output reg [3:0] nextState
);

    wire [15:0] keycode;
    wire flag;
    KBinput KBinput (
        .clk(iCLK),
        .kclk(iPS2Clk),
        .kdata(iPS2Data),
        .dataOut(keycode),
        .oflag(flag)
    );
    // setup character positions and sizes
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

    reg de=1;
    reg space;
    initial
    begin
        nextState <= 2;
        o_hp_mon1 <= hp_mon1;
        o_hp_mon2 <= hp_mon2;
        o_hp_mon3 <= hp_mon3;
    end
    
    always @(posedge Pclk && state == 3)
    begin
        //normal input
        if (keycode[15:8] == 8'hf0) de=1;
        else if (!de) begin space=0; end
        else if (keycode[7:0] == 8'h29) begin space=1;de=0; end
        
        if (space==1 || ibtnX == 1)
            begin
                case(noksel)
                    0:
                        begin
                            if (BarX > GoodScaleX)
                                begin
                                    o_hp_mon1 <= hp_mon1 > ((BarX - GoodScaleX) >> 3) ? hp_mon1 - ((BarX - GoodScaleX) >> 3) : 0;
                                end
                            else
                                begin
                                    o_hp_mon1 <= hp_mon1 > ((GoodScaleX - BarX) >> 3) ? hp_mon1 - ((GoodScaleX - BarX) >> 3) : 0;
                                end
                            o_hp_mon2 <= hp_mon2;
                            o_hp_mon3 <= hp_mon3;
                        end
                    1:
                        begin
                            if (BarX > GoodScaleX)
                                begin
                                    o_hp_mon2 <= hp_mon2 > ((BarX - GoodScaleX) >> 3) ? hp_mon2 - ((BarX - GoodScaleX) >> 3) : 0;
                                end
                            else
                                begin
                                    o_hp_mon2 <= hp_mon2 > ((GoodScaleX - BarX) >> 3) ? hp_mon2 - ((GoodScaleX - BarX) >> 3) : 0;
                                end
                            o_hp_mon1 <= hp_mon1;
                            o_hp_mon3 <= hp_mon3;
                        end
                    2: 
                        begin
                            if (BarX > GoodScaleX)
                                begin
                                    o_hp_mon3 <= hp_mon3 > ((BarX - GoodScaleX) >> 3) ? hp_mon3 - ((BarX - GoodScaleX) >> 3) : 0;
                                end
                            else
                                begin
                                    o_hp_mon3 <= hp_mon3 > ((GoodScaleX - BarX) >> 3) ? hp_mon3 - ((GoodScaleX - BarX) >> 3) : 0;
                                end
                            o_hp_mon1 <= hp_mon1;
                            o_hp_mon2 <= hp_mon2;
                        end
                    default:
                        begin
                            o_hp_mon1 <= hp_mon1;
                            o_hp_mon2 <= hp_mon2;
                            o_hp_mon3 <= hp_mon3;
                        end
                endcase
                nextState <= 1;
            end
        else
            begin
                nextState <= 2;
            end

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
endmodule