//--------------------------------------------------
// BeeSprite Module : Digilent Basys 3               
// BeeInvaders Tutorial 3 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//--------------------------------------------------
`timescale 1ns / 1ps

// Setup BeeSprite Module
module BeeSprite(
    input wire [9:0] xx, // current x position
    input wire [9:0] yy, // current y position
    input wire aactive, // high during active pixel drawing
    output reg BSpriteOn, // 1=on, 0=off
    output wire [7:0] dataout, // 8 bit pixel value from Bee.mem
    input wire BR, // right button
    input wire BL, // left button
    input wire BU,
    input wire BD,
    input wire Pclk, // 25MHz pixel clock
    input wire clk,
    input wire Kclk,
    input wire Kdata
    
    );

    // instantiate BeeRom code
    reg [9:0] address; // 2^10 or 1024, need 34 x 27 = 918
    BeeRom BeeVRom (.i_addr(address),.i_clk2(Pclk),.o_data(dataout));
    
    reg         start=0;
    wire [15:0] keycode;
    reg  [15:0] keycodev=0;
    wire flag;
    reg  cn=0;
    reg  [ 2:0] bcount=0;
    KBinput KBinput (
        .clk(clk),
        .kclk(Kclk),
        .kdata(Kdata),
        .dataOut(keycode),
        .oflag(flag)
    );
    
    always@(keycode)
        if (keycode[7:0] == 8'hf0) begin
            cn <= 1'b0;
            bcount <= 3'd0;
        end else if (keycode[15:8] == 8'hf0) begin
            cn <= keycode != keycodev;
            bcount <= 3'd5;
        end else begin
            cn <= keycode[7:0] != keycodev[7:0] || keycodev[15:8] == 8'hf0;
            bcount <= 3'd2;
        end
        
    always@(posedge clk)
        if (flag == 1'b1 && cn == 1'b1) begin
            start <= 1'b1;
            keycodev <= keycode;
        end else begin
            start <= 1'b0;
         end
            
            
    // setup character positions and sizes
    reg [9:0] BeeX = 297; // Bee X start position
    reg [8:0] BeeY = 433; // Bee Y start position
    localparam BeeWidth = 25; // Bee width in pixels
    localparam BeeHeight = 23; // Bee height in pixels
    reg ups,downs,lefts,rights;
    
    always @ (posedge Pclk)
    begin
        if (keycode[15:8] == 8'hf0) begin //release button
            if (keycode[7:0] == 8'h1d) begin ups=0; end
            else if (keycode[7:0] == 8'h1b) begin downs=0; end
            else if (keycode[7:0] == 8'h1c) begin lefts=0; end
            else if (keycode[7:0] == 8'h23) begin rights=0; end
        end
        else begin //press button
            if (keycode[7:0] == 8'h1d) begin ups=1; end 
            else if (keycode[7:0] == 8'h1b) begin downs=1; end
            else if (keycode[7:0] == 8'h1c) begin lefts=1; end
            else if (keycode[7:0] == 8'h23) begin rights=1; end
        end
        if (xx==799 && yy==599)
            begin // check for left or right button pressed
                if (BR == 1 && BeeX<800-BeeWidth)
                    BeeX<=BeeX+2;
                if (BL == 1 && BeeX>1)
                    BeeX<=BeeX-2;
                
                if (BD == 1 && BeeY<600-BeeHeight)
                    BeeY<=BeeY+2;
                if (BU == 1 && BeeY>1)
                    BeeY<=BeeY-2;
                 
                if (rights && BeeX<800-BeeWidth)
                    BeeX<=BeeX+2;
                if (lefts && BeeX>1)
                    BeeX<=BeeX-2;
                if (downs && BeeY<600-BeeHeight)
                  BeeY<=BeeY+2;
                if (ups && BeeY>1)
                  BeeY<=BeeY-2;
            end    
        if (aactive)
            begin // check if xx,yy are within the confines of the Bee character
                if (xx==BeeX-1 && yy==BeeY)
                    begin
                        address <= 0;
                        BSpriteOn <=1;
                    end
                if ((xx>BeeX-1) && (xx<BeeX+BeeWidth) && (yy>BeeY-1) && (yy<BeeY+BeeHeight))
                    begin
                        address <= address + 1;
                        BSpriteOn <=1;
                    end
                else
                    BSpriteOn <=0;
            end
        end
endmodule