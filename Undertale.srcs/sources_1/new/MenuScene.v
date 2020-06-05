`timescale 1ns / 1ps

module MenuScene(
input wire [9:0] ix,
input wire [9:0] iy,
input wire iactive,
input wire ibtnC,
input wire ibtnR,
input wire ibtnL,
input wire ibtnU,
input wire ibtnD,
input wire iPixCLK,
input wire iCLK,
input wire iPS2Clk,
input wire iPS2Data,

output reg [3:0] oRED,
output reg [3:0] oGREEN,
output reg [3:0] oBLUE,

output reg [1:0] nextState,
output reg [1:0] noksel
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
    
    reg [1:0] selection = 0;

    
    wire FightSpriteOn;
    wire [7:0] fightout;      
    wire SelFightSpriteOn;
    wire [7:0] selfightout;
    wire self;
    assign self = selection == 0;
    FightButtonSprite FSprite  (.xx(ix),.yy(iy),.aactive(iactive),
                          .Pclk(iPixCLK),.clk(iCLK),
                          .chosen(self), .FightSpriteOn(FightSpriteOn), .dataout(fightout),
                          .BSpriteOn(SelFightSpriteOn), .Bdataout(selfightout)
                          );

    wire MercySpriteOn;
    wire [7:0] mercyout;      
    wire SelMercySpriteOn;
    wire [7:0] selmercyout;
    wire selm;
    assign selm = selection == 1;
    MercyButtonSprite MSprite  (.xx(ix),.yy(iy),.aactive(iactive),
                          .Pclk(iPixCLK),.clk(iCLK),
                          .chosen(selm), .MercySpriteOn(MercySpriteOn), .dataout(mercyout),
                          .BSpriteOn(SelMercySpriteOn), .Bdataout(selmercyout)
                          );
    
    wire SpriteOn1;
    wire SpriteOn2;
    wire SpriteOn3;
    wire [7:0] nokout;
    
    wire SelNokSpriteOn;
    wire [7:0] selnokout;

    NokauanSelectionSprite NSprite (.xx(ix),.yy(iy),.aactive(iactive),
                          .Pclk(iPixCLK),.clk(iCLK),
                          .i_noksel(noksel),
                          .SpriteOn1(SpriteOn1), .SpriteOn2(SpriteOn2), .SpriteOn3(SpriteOn3),
                          .dataout(nokout),
                          .BSpriteOn(SelNokSpriteOn), .Bdataout(selnokout)
                          );
    // load colour palette
    reg [7:0] palette [0:191];  // 8 bit values from the 192 hex entries in the colour palette
    reg [7:0] COL = 0;          // background colour palette value
    initial begin
        $readmemh("palall.mem", palette); // load 192 hex values into "palette"
        nextState = 3;
        noksel = 0;
    end
    
    
    
    wire ups,downs,lefts,rights, spaces;
    assign ups = keycode[7:0] == 8'h1d;
    assign downs = keycode[7:0] == 8'h1b;
    assign lefts = keycode[7:0] == 8'h1c;
    assign rights = keycode[7:0] == 8'h23;
    assign spaces = keycode[7:0] == 8'h29;

    reg de=1;
    reg up, down, left, right, space;
    
always @ (posedge iPixCLK)
    begin
        //normal input
        if (keycode[15:8] == 8'hf0) de=1;
        else if (!de) begin up=0;down=0;left=0;right=0;space=0; end
        else if (keycode[7:0] == 8'h1d) begin up=1;de=0; end //press button
        else if (keycode[7:0] == 8'h1b) begin down=1;de=0; end
        else if (keycode[7:0] == 8'h23) begin left=1;de=0; end
        else if (keycode[7:0] == 8'h1c) begin right=1;de=0; end
        else if (keycode[7:0] == 8'h29) begin space=1;de=0; end
        
        if (ibtnL == 1 || left == 1)
            begin
                if (selection >= 1) selection <= 1;
                else selection <= selection + 1;
            end
        else
        if (ibtnR == 1 || right == 1)
            begin
                if (selection <= 0) selection <= 0;
                else selection <= selection - 1;
            end
            
        if ((ibtnU==1 || up==1))
            begin
                noksel <= noksel < 1 ? 0 : noksel - 1;
            end
        else
        if ((ibtnD==1 || down==1))
            begin
                noksel <= noksel > 1 ? 2 : noksel + 1;
            end
        

        if (space==1 || ibtnC == 1)
            begin
                case(selection)
                    0: nextState <= 2;
                    1: nextState <= 0;
                    default: nextState <= 0;
                endcase
                 //go to home pai gorn
            end
        else
            begin
                nextState <= 3;
            end
        
        if (iactive)
            begin
                if (FightSpriteOn==1)
                    begin
                        oRED <= (palette[(fightout*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(fightout*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(fightout*3)+2])>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                if (MercySpriteOn==1)
                    begin
                        oRED <= (palette[(mercyout*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(mercyout*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(mercyout*3)+2])>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                if (SelFightSpriteOn==1)
                    begin
                        oRED <= (palette[(selfightout*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(selfightout*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(selfightout*3)+2])>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                if (SelMercySpriteOn==1)
                    begin
                        oRED <= (palette[(selmercyout*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(selmercyout*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(selmercyout*3)+2])>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                if (SpriteOn1==1)
                    begin
                        oRED <= (palette[(nokout*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(nokout*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(nokout*3)+2])>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                if (SpriteOn2==1)
                    begin
                        oRED <= (palette[((nokout+1)*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[((nokout+1)*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[((nokout+1)*3)+2])>>4;       // BLUE bits(7:4) from colour palette
//                        oRED <= palette[(nokout*3)] == 8'hff ? (8'h22)>>4 : palette[(nokout*3)]>>4;          // RED bits(7:4) from colour palette
//                        oGREEN <= palette[(nokout*3)+1] == 8'hff ? (8'h8c)>>4 : palette[(nokout*3)+1]>>4;      // GREEN bits(7:4) from colour palette
//                        oBLUE <= palette[(nokout*3)+2] == 8'hff ? (8'h22)>>4 : palette[(nokout*3)+2]>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                if (SpriteOn3==1)
                    begin
                        oRED <= (palette[((nokout+2)*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[((nokout+2)*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[((nokout+2)*3)+2])>>4;       // BLUE bits(7:4) from colour palette
//                        oRED <= palette[(nokout*3)] == 8'hff ? (8'hf5)>>4 : palette[(nokout*3)]>>4;          // RED bits(7:4) from colour palette
//                        oGREEN <= palette[(nokout*3)+1] == 8'hff ? (8'h1b)>>4 : palette[(nokout*3)+1]>>4;      // GREEN bits(7:4) from colour palette
//                        oBLUE <= palette[(nokout*3)+2] == 8'hff ? (8'h00)>>4 : palette[(nokout*3)+2]>>4;       // BLUE bits(7:4) from colour palette
                    end
                else
                if (SelNokSpriteOn==1)
                    begin
                        oRED <= (palette[(selnokout*3)])>>4;          // RED bits(7:4) from colour palette
                        oGREEN <= (palette[(selnokout*3)+1])>>4;      // GREEN bits(7:4) from colour palette
                        oBLUE <= (palette[(selnokout*3)+2])>>4;       // BLUE bits(7:4) from colour palette
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
