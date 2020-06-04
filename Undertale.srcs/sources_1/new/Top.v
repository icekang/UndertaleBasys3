//--------------------------------------------------
// Top Module : Digilent Basys 3               
// BeeInvaders Tutorial 4 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//--------------------------------------------------
`timescale 1ns / 1ps

module Top(
    input wire CLK,         // Onboard clock 100MHz : INPUT Pin W5
    input wire PS2Clk,
    input wire PS2Data,
    input wire btnC,       // Reset button / Centre Button : INPUT Pin U18
    output wire HSYNC,      // VGA horizontal sync : OUTPUT Pin P19
    output wire VSYNC,      // VGA vertical sync : OUTPUT Pin R19
    output reg [3:0] RED,   // 4-bit VGA Red : OUTPUT Pin G19, Pin H19, Pin J19, Pin N19
    output reg [3:0] GREEN, // 4-bit VGA Green : OUTPUT Pin J17, Pin H17, Pin G17, Pin D17
    output reg [3:0] BLUE,  // 4-bit VGA Blue : OUTPUT Pin N18, Pin L18, Pin K18, Pin J18/ 4-bit VGA Blue : OUTPUT Pin N18, Pin L18, Pin K18, Pin J18
    input btnR,             // Right button : INPUT Pin T17
    input btnL,              // Left button : INPUT Pin W19
    input btnU,
    input btnD
    );
    
    reg [3:0] state = 1;
    wire rst = 0;       // Setup Reset button

    // instantiate vga640x480 code
    wire [9:0] x;           // pixel x position: 10-bit value: 0-1023 : only need 800
    wire [9:0] y;           // pixel y position: 10-bit value: 0-1023 : only need 525
    wire active;            // high during active pixel drawing
    wire PixCLK;            // 25MHz pixel clock
    vga800x600 display (.i_clk(CLK),.i_rst(rst),.o_hsync(HSYNC), 
                        .o_vsync(VSYNC),.o_x(x),.o_y(y),.o_active(active),
                        .pix_clk(PixCLK));
                        
    wire [3:0] bulletRED;
    wire [3:0] bulletGREEN;
    wire [3:0] bulletBLUE;
    BulletScene bulletScene (.ix(x), .iy(y), .iactive(active),
        .ibtnL(btnL), .ibtnR(btnR), .ibtnU(btnU), .ibtnD(btnD),
        .iPixCLK(PixCLK), .iCLK(CLK), .iPS2Clk(PS2Clk), .iPS2Data(PS2Data),
        .oRED(bulletRED), .oGREEN(bulletGREEN), .oBLUE(bulletBLUE));
        
    assign h_main = ((x > 20) & (y >  40) & (x < 220) & (y < 70)) ? 1 : 0;
    assign h_main_box = (((y > 40) &(y < 70)) & ((x > 15) & (x <= 20) | ((x >= 220) & (x < 225)))) | ((x>20 & x < 220) & ((y<=40 & y>35) | (y >= 70 & y < 75) ) ) ? 1:0;
    assign h_mon1 = ((x > 580) & (y >  40) & (x < 780) & (y < 70)) ? 1 : 0;
    assign h_mon1_box = (((y > 40) &(y < 70)) & ((x > 575) & (x <= 580) | ((x >= 780) & (x < 785)))) | ((x > 580 & x < 780) & ((y<=40 & y>35) | (y >= 70 & y < 75) ) ) ? 1:0;
    assign h_mon2 = ((x > 580) & (y >  90) & (x < 780) & (y < 120)) ? 1 : 0;
    assign h_mon2_box = (((y > 90) &(y < 120)) & ((x > 575) & (x <= 580) | ((x >= 780) & (x < 785)))) | ((x > 580 & x < 780) & ((y<=90 & y>85) | (y >= 120 & y < 125) ) ) ? 1:0;
    assign h_mon3 = ((x > 580) & (y >  140) & (x < 780) & (y < 170)) ? 1 : 0;
    assign h_mon3_box = (((y > 140) &(y < 170)) & ((x > 575) & (x <= 580) | ((x >= 780) & (x < 785)))) | ((x > 580 & x < 780) & ((y<=140 & y>135) | (y >= 170 & y < 175) ) ) ? 1:0;
        
    // draw on the active area of the screen
    always @ (posedge PixCLK)
    begin
        case(state)
            1: 
                begin
                    RED <= bulletRED | {4{h_main}} | {4{h_main_box}} | {4{h_mon1_box}} | {4{h_mon2_box}} | {4{h_mon3_box}} ;
                    GREEN <= bulletGREEN | {4{h_mon1}} | {4{h_mon2}} | {4{h_mon3}} | {4{h_main_box}} | {4{h_mon1_box}} | {4{h_mon2_box}} | {4{h_mon3_box}};
                    BLUE <= bulletBLUE | {4{h_main_box}} | {4{h_mon1_box}} | {4{h_mon2_box}} | {4{h_mon3_box}} ;
                end
            default:
                begin
                    RED <= 0;
                    GREEN <= 0;
                    BLUE <= 0;
                end
        endcase
    end
endmodule