//--------------------------------------------------
// AlienSprites Module : Digilent Basys 3               
// BeeInvaders Tutorial 4 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//--------------------------------------------------
`timescale 1ns / 1ps

// Setup AlienSprites Module
module BulletSprite(
    input wire [9:0] xx,            // current x position
    input wire [9:0] yy,            // current y position
    input wire aactive,             // high during active pixel drawing
    output reg BSpriteOn,          // 1=on, 0=off
    output wire [7:0] Bdataout,    // 8 bit pixel value from Alien1.mem
    input wire Pclk                 // 25MHz pixel clock
    );

    // instantiate Alien1Rom code
    reg [9:0] Baddress;            // 2^10 or 1024, need 31 x 26 = 806
    BulletRom BulletVRom (.i_A1addr(Baddress),.i_clk2(Pclk),.o_A1data(A1dataout));

    // setup character positions and sizes
    reg [9:0] BX = 135;            // Alien1 X start position
    reg [9:0] BY = 85;             // Alien1 Y start position
    localparam BWidth = 12;        // Alien1 width in pixels
    localparam BHeight = 12;       // Alien1 height in pixels

    reg [9:0] BoX = 0;              // Offset for X Position of next Alien in row
    reg [9:0] BoY = 0;              // Offset for Y Position of next row of Aliens
    reg [9:0] BcounterW = 0;        // Counter to check if Alien width reached
    reg [9:0] BcounterH = 0;        // Counter to check if Alien height reached
    reg [3:0] BcolCount = 11;       // Number of horizontal aliens in all columns
    reg [1:0] Bdir = 1;             // direction of aliens: 0=right, 1=left
    reg [9:0] delaliens=0;          // counter to slow alien movement

    always @ (posedge Pclk)
    begin
        if (aactive)
            begin
                // check if xx,yy are within the confines of the Alien characters
                // Alien1
                if (xx==BX+BoX-1 && yy==BY+BoY)
                    begin
                        Baddress <= 0;
                        BSpriteOn <=1;
                        BcounterW<=0;
                    end                   
                if ((xx>BX+BoX-1) && (xx<BX+BWidth+BoX) && (yy>BY+BoY-1) && (yy<BY+BHeight+BoY))   
                    begin
                        Baddress <= Baddress + 1;
                        BcounterW <= BcounterW + 1;
                        BSpriteOn <=1;
                        if (BcounterW==BWidth-1)
                            begin
                                BcounterW <= 0;
                                BoX <= BoX + 40;
                                if(BoX<(BcolCount-1)*40)
								    Baddress <= Baddress - (BWidth-1);
							    else
							    if(BoX==(BcolCount-1)*40)
								    BoX<=0;
					        end
                    end
                else
                    BSpriteOn <=0;
            end
        
    end
    
    always @ (posedge Pclk)
    begin
        // slow down the alien movement / move aliens left or right
        if (xx==639 && yy==479)
            begin
                delaliens<=delaliens+1;
                if (delaliens>1)
                    begin
                        delaliens<=0;
                        if (Bdir==1)
                            begin
                                BX<=BX-1;
                                if (BX<3)
                                    Bdir<=0;
                            end
                        if (Bdir==0)
                            begin
                                BX<=BX+1;
                                if (BX+BWidth+((BcolCount-1)*40)>636)    
                                    Bdir<=1;
                            end
                    end
            end
    end
endmodule