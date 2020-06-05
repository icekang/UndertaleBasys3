`timescale 1ns / 1ps

module TitleScene(
input wire [9:0] ix,
input wire [9:0] iy,
input wire iactive,
input wire ibtnC,
input wire iPixCLK,
input wire iCLK,
input wire iPS2Clk,
input wire iPS2Data,

output reg [3:0] oRED,
output reg [3:0] oGREEN,
output reg [3:0] oBLUE,

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
    
    // instantiate BeeSprite code
    wire TitleSpriteOn;       // 1=on, 0=off
    wire [7:0] dout;        // pixel value from Bee.mem
    TitleSprite TitleDisplay (.xx(ix),.yy(iy),.aactive(iactive),
                          .SpriteOn(TitleSpriteOn),.dataout(dout),
                          .Pclk(iPixCLK),.clk(iCLK));

    // load colour palette
    reg [7:0] palette [0:191];  // 8 bit values from the 192 hex entries in the colour palette
    reg [7:0] COL = 0;          // background colour palette value
    initial begin
        $readmemh("palall.mem", palette); // load 192 hex values into "palette"
    end
    reg de=1;
    reg space;
always @ (posedge iPixCLK)
    begin
    //normal input
        if (keycode[15:8] == 8'hf0) de=1;
        else if (!de) begin space=0; end
        else if (keycode[7:0] == 8'h29) begin space=1;de=0; end
        if (space == 1 || ibtnC == 1)
            begin
                nextState <= 3; //go to menu
            end
        else
            begin
                nextState <= 0;
            end

        if (iactive)
            begin
                if (TitleSpriteOn==1)
                    begin
                        oRED <= (palette[(dout*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(dout*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(dout*3)+2])>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                    begin
                        oRED <= 0;   // set RED, GREEN & BLUE
                        oGREEN <= 0; // to "0" when ix,iy outside of
                        oBLUE <= 0;  // the iactive display area
                    end
            end
        else
            begin
                oRED <= 0;   // set RED, GREEN & BLUE
                oGREEN <= 0; // to "0" when ix,iy outside of
                oBLUE <= 0;  // the iactive display area
            end
    end
endmodule
