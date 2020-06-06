//--------------------------------------------------
// AlienSprites Module : Digilent Basys 3               
// BeeInvaders Tutorial 4 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//--------------------------------------------------
`timescale 1ns / 1ps

// Setup AlienSprites Module
module BulletSprite3(
    input wire [9:0] xx,            // current x position
    input wire [9:0] yy,            // current y position
    input wire aactive,             // high during active pixel drawing
    output reg BSpriteOn,          // 1=on, 0=off
    output wire [7:0] Bdataout,    // 8 bit pixel value from Alien1.mem
    input wire Pclk                 // 25MHz pixel clock
    );

    // instantiate Alien1Rom code
    reg [9:0] Baddress;            // 2^10 or 1024, need 31 x 26 = 806
    BulletRom BulletVRom (.i_A1addr(Baddress),.i_clk2(Pclk),.o_A1data(Bdataout));

    // setup character positions and sizes
    localparam BXstart = 275+250;
    localparam BYstart = 285;
    reg [9:0] BX = BXstart;            // Alien1 X start position
    reg [9:0] BY = BYstart;             // Alien1 Y start position
    localparam BWidth = 12;        // Alien1 width in pixels
    localparam BHeight = 12;       // Alien1 height in pixels
    localparam BOffset = 55;

    reg [9:0] BoX = 0;              // Offset for X Position of next Alien in row
    reg [9:0] BoY = 0;              // Offset for Y Position of next row of Aliens
    reg [9:0] BcounterW = 0;        // Counter to check if Alien width reached
    reg [9:0] BcounterH = 0;        // Counter to check if Alien height reached
    reg [3:0] BcolCount = 1;       // Number of horizontal aliens in all columns
    reg [1:0] Bdir = 1;             // direction of aliens: 0=right, 1=left
    reg [9:0] delaliens=0;          // counter to slow alien movement

    reg [9:0] BYvel = 7;
    reg [9:0] BYacc = 0;
    reg [3:0] BYAccDel = 0;
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
                                BoX <= BoX + BOffset;
                                if(BoX<(BcolCount-1)*BOffset)
								    Baddress <= Baddress - (BWidth-1);
							    else
							    if(BoX==(BcolCount-1)*BOffset)
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
        if (xx==800 && yy==600)
            begin
                delaliens<=delaliens+1;
                if (delaliens>1)
                    begin
                        delaliens<=0;
                        if (Bdir==1)
                            begin
                                BX<=BX-BYvel;
                                BY<=BY+BYvel;
                                BYAccDel<=BYAccDel+1;
                                if (BYAccDel == 0)
                                    BYvel=BYvel+BYacc;
                                if (BY>275+250-10)
                                    begin
                                        Bdir<=0;
//                                        BYvel<=0;
                                    end
                            end
                        if (Bdir==0)
                            begin
                                BX<=BX+BYvel;
                                BY<=BY-BYvel;
                                BYAccDel<=BYAccDel+1;
                                if (BYAccDel == 0)
                                    BYvel=BYvel+BYacc;
                                BYvel=BYvel+BYacc;
                                if (BY<285)
                                    begin    
                                        Bdir<=1;
//                                        BYvel<=0;
                                    end
                            end
                    end
            end
    end
endmodule