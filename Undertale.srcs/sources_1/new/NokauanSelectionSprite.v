`timescale 1ns / 1ps

module NokauanSelectionSprite(
    input wire [9:0] xx, // current x position
    input wire [9:0] yy, // current y position
    input wire aactive, // high during active pixel drawing

    input wire Pclk, // 25MHz pixel clock
    input wire clk,
    
    input wire [1:0] i_noksel,
    
    output reg SpriteOn1, // 1=on, 0=off
    output reg SpriteOn2, // 1=on, 0=off
    output reg SpriteOn3, // 1=on, 0=off
    output wire [7:0] dataout,

    output reg BSpriteOn,          // 1=on, 0=off
    output wire [7:0] Bdataout    // 8 bit pixel value from Alien1.mem
    );

    // instantiate NokRom code
    reg [14:0] address; // 2^10 or 1024, need 34 x 27 = 918
    NokauanRom NokRom (.i_Nokaddr(address),.i_clk2(Pclk),.o_Nokdata(dataout));

    // setup character positions and sizes
    reg [9:0] NokX = 550; // Bee X start position
    reg [8:0] NokY = 25; // Bee Y start position
    localparam NokWidth = 176; // Bee width in pixels
    localparam NokHeight = 161; // Bee height in pixels
    
    reg [9:0] Baddress;            // 2^10 or 1024, need 31 x 26 = 806
    BulletRom BulletVRom (.i_A1addr(Baddress),.i_clk2(Pclk),.o_A1data(Bdataout));
    
    localparam BXstart = 520;
    localparam BYstart = 156;
    reg [9:0] BX = BXstart;            // Alien1 X start position
    reg [9:0] BY = BYstart;             // Alien1 Y start position
    localparam BWidth = 12;        // Alien1 width in pixels
    localparam BHeight = 12;       // Alien1 height in pixels
    
    localparam offsetY1 = 200;
    localparam offsetY2 = 400;
    always @ (posedge Pclk)
    begin
        case(i_noksel)
            0: BY <= BYstart;
            1: BY <= BYstart + offsetY1;
            2: BY <= BYstart + offsetY2;
            default: BY <= BYstart;
        endcase
        if (aactive)
            begin // check if xx,yy are within the confines of the Bee character
                if (xx==NokX-1)
                    begin
                        if (yy==NokY)
                            begin
                                address <= 0;
                                SpriteOn1 <=1;
                            end
                        else if (yy==NokY+offsetY1)
                            begin
                                address <= 0;
                                SpriteOn2 <=1;
                            end
                        else if (yy==NokY+offsetY2)
                            begin
                                address <= 0;
                                SpriteOn3 <=1;
                            end
                    end
                if ( (xx>NokX-1) && (xx<NokX+NokWidth) )
                   begin
                        if ((yy>NokY-1) && (yy<NokY+NokHeight))
                            begin
                                address <= address + 1;
                                SpriteOn1 <=1;
                            end
                        else if((yy>NokY+offsetY1-1) && (yy<NokY+offsetY1+NokHeight))
                            begin
                                address <= address + 1;
                                SpriteOn2 <=1;
                            end
                        else if((yy>NokY+offsetY2-1) && (yy<NokY+offsetY2+NokHeight))
                            begin
                                address <= address + 1;
                                SpriteOn3 <=1;
                            end
                   end
                else
                    begin
                            SpriteOn1 <=0;
                            SpriteOn2 <=0;
                            SpriteOn3 <=0;
                    end
                
                //Selection indicator
                if (xx==BX-1 && yy==BY)
                    begin
                        Baddress <= 0;
                        BSpriteOn <=1;
                    end   
                else
                if ((xx>BX-1) && (xx<BX+BWidth) && (yy>BY-1) && (yy<BY+BHeight)) 
                    begin
                        Baddress <= Baddress + 1;
                        BSpriteOn <=1;
                    end
                else
                    BSpriteOn <=0;
            end
        end
endmodule