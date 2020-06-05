//--------------------------------------------------
// BeeSprite Module : Digilent Basys 3               
// BeeInvaders Tutorial 3 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//--------------------------------------------------
`timescale 1ns / 1ps

// Setup BeeSprite Module
module MercyButtonSprite(
    input wire [9:0] xx, // current x position
    input wire [9:0] yy, // current y position
    input wire aactive, // high during active pixel drawing

    input wire Pclk, // 25MHz pixel clock
    input wire clk,
    
    input wire chosen,
    
    output reg MercySpriteOn, // 1=on, 0=off
    output wire [7:0] dataout, // 8 bit pixel value from Bee.mem
    
    output reg BSpriteOn,          // 1=on, 0=off
    output wire [7:0] Bdataout    // 8 bit pixel value from Alien1.mem
    );

    // instantiate BeeRom code
    reg [11:0] address; // 2^10 or 1024, need 34 x 27 = 918
    MercyButtonRom MercyRom (.i_addr(address),.i_clk(Pclk),.o_data(dataout));
    
    // setup character positions and sizes
    reg [9:0] BtnX = 297; // Bee X start position
    reg [8:0] BtnY = 282; // Bee Y start position
    localparam BtnWidth = 92; // Bee width in pixels
    localparam BtnHeight = 36; // Bee height in pixels
    
    reg [9:0] Baddress;            // 2^10 or 1024, need 31 x 26 = 806
    BulletRom BulletVRom (.i_A1addr(Baddress),.i_clk2(Pclk),.o_A1data(Bdataout));
    
    localparam BXstart = 337;
    localparam BYstart = 260;
    reg [9:0] BX = BXstart;            // Alien1 X start position
    reg [9:0] BY = BYstart;             // Alien1 Y start position
    localparam BWidth = 12;        // Alien1 width in pixels
    localparam BHeight = 12;       // Alien1 height in pixels
    
    always @ (posedge Pclk)
    begin
        if (aactive)
            begin // check if xx,yy are within the confines of the Bee character
                if (xx==BtnX-1 && yy==BtnY)
                    begin
                        address <= 0;
                        MercySpriteOn <=1;
                    end
                else
                if ((xx>BtnX-1) && (xx<BtnX+BtnWidth) && (yy>BtnY-1) && (yy<BtnY+BtnHeight))
                    begin
                        address <= address + 1;
                        MercySpriteOn <=1;
                    end
                else
                    MercySpriteOn <=0;
                
                //Selection indicator
                if (xx==BX-1 && yy==BY && chosen == 1)
                    begin
                        Baddress <= 0;
                        BSpriteOn <=1;
                    end   
                else
                if ((xx>BX-1) && (xx<BX+BWidth) && (yy>BY-1) && (yy<BY+BHeight)  && chosen == 1) 
                    begin
                        Baddress <= Baddress + 1;
                        BSpriteOn <=1;
                    end
                else
                    BSpriteOn <=0;
            end
        end
endmodule