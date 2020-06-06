`timescale 1ns / 1ps

module BulletScene(
input wire [9:0] ix,
input wire [9:0] iy,
input wire iactive,
input wire ibtnR,
input wire ibtnL,
input wire ibtnU,
input wire ibtnD,
input wire iPixCLK,
input wire iCLK,
input wire iPS2Clk,
input wire iPS2Data,
input wire [6:0] hp ,

output reg [3:0] oRED,
output reg [3:0] oGREEN,
output reg [3:0] oBLUE,
output integer hpO = 100
    );
    // instantiate BeeSprite code
    wire BeeSpriteOn;       // 1=on, 0=off
    wire [7:0] dout;        // pixel value from Bee.mem
    BeeSprite BeeDisplay (.xx(ix),.yy(iy),.aactive(iactive),
                          .BSpriteOn(BeeSpriteOn),.dataout(dout),
                          .BR(ibtnR),.BL(ibtnL),.BU(ibtnU),.BD(ibtnD),
                          .Pclk(iPixCLK),.clk(iCLK),.Kclk(iPS2Clk),.Kdata(iPS2Data));
    // instantiate BulletBoxSprite code
    wire BBSpriteOn;       // 1=on, 0=off
    wire [7:0] BBout;        // pixel value from Bee.mem
    BulletBoxSprite BBSprite (.xx(ix),.yy(iy),.aactive(iactive),
                          .BBSpriteOn(BBSpriteOn),.dataout(BBout),
                          .Pclk(iPixCLK));
    // instantiate BulletBoxSprite code
    wire BulletSpriteOn;       // 1=on, 0=off
    wire [7:0] B1out;        // pixel value from Bee.mem

    BulletSprite BulletDisplay (.xx(ix),.yy(iy),.aactive(iactive),
                          .BSpriteOn(BulletSpriteOn),.Bdataout(B1out),
                          .Pclk(iPixCLK));
    // instantiate BulletBoxSprite code
    wire Bullet2SpriteOn;       // 1=on, 0=off
    wire [7:0] B21out;        // pixel value from Bee.mem

    BulletSprite2 Bullet2Display (.xx(ix),.yy(iy),.aactive(iactive),
                          .BSpriteOn(Bullet2SpriteOn),.Bdataout(B21out),
                          .Pclk(iPixCLK));
    // instantiate BulletBoxSprite code
    wire Bullet3SpriteOn;       // 1=on, 0=off
    wire [7:0] B31out;        // pixel value from Bee.mem

    BulletSprite3 Bullet3Display (.xx(ix),.yy(iy),.aactive(iactive),
                          .BSpriteOn(Bullet3SpriteOn),.Bdataout(B31out),
                          .Pclk(iPixCLK));
    // instantiate BulletBoxSprite code
    wire NokauanSpriteOn;       // 1=on, 0=off
    wire [7:0] Nokout;        // pixel value from Bee.mem
    NokauanSprite NokauanDisplay (.xx(ix),.yy(iy),.aactive(iactive),
                          .SpriteOn(NokauanSpriteOn),.dataout(Nokout),
                          .Pclk(iPixCLK));
                          
    // load colour palette
    reg [7:0] palette [0:191];  // 8 bit values from the 192 hex entries in the colour palette
    reg [7:0] COL = 0;          // background colour palette value
    initial begin
        $readmemh("palall.mem", palette); // load 192 hex values into "palette"
    end
    
    integer ms_count = 0;
    reg sec_pulse;
always @ (posedge iPixCLK)
    begin
         sec_pulse <= 0;
        if (ms_count == 999999)
                    begin
                        if((BeeSpriteOn == 1 & BulletSpriteOn == 1)& (palette[(dout*3)] > 0 | palette[(dout*3) + 1] > 0 | palette[(dout*3) + 2] > 0) & (palette[(B1out*3)] > 0 | palette[(B1out*3) + 1] > 0 | palette[(B1out*3) + 2] > 0))
                            begin
                                hpO = hp - 2;
                                if(hpO <= 0)
                                    hpO = 0;
                                ms_count <= 0;
                                sec_pulse <= 1;
                            end
                        else
                            hpO = hp;
                        
                    end
                else
                    ms_count <= ms_count + 1;
                
        if (iactive)
            begin
               
                if (BeeSpriteOn==1)
                    begin
                        oRED <= (palette[(dout*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(dout*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(dout*3)+2])>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                if (BBSpriteOn==1)
                    begin
                        oRED <= (palette[(BBout*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(BBout*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(BBout*3)+2])>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                if (BulletSpriteOn==1)
                    begin
                        oRED <= (palette[(B1out*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(B1out*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(B1out*3)+2])>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                if (Bullet2SpriteOn==1)
                    begin
                        oRED <= (palette[(B21out*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(B21out*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(B21out*3)+2])>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                if (Bullet3SpriteOn==1)
                    begin
                        oRED <= (palette[(B31out*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(B31out*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(B31out*3)+2])>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                if (NokauanSpriteOn==1)
                    begin
                        oRED <= (palette[(Nokout*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(Nokout*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(Nokout*3)+2])>>4;       // BLUE bits(7:4) from colour palette
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
