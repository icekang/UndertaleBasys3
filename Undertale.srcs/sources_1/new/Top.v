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
    
    reg [3:0] state = 0;
    wire [3:0] nextState;
    wire rst = 0;       // Setup Reset button

    // instantiate vga640x480 code
    wire [9:0] x;           // pixel x position: 10-bit value: 0-1023 : only need 800
    wire [9:0] y;           // pixel y position: 10-bit value: 0-1023 : only need 525
    wire active;            // high during active pixel drawing
    wire PixCLK;            // 25MHz pixel clock
    vga800x600 display (.i_clk(CLK),.i_rst(rst),.o_hsync(HSYNC), 
                        .o_vsync(VSYNC),.o_x(x),.o_y(y),.o_active(active),
                        .pix_clk(PixCLK));
    integer hp_main = 100;
    wire [6:0] hp_main_temp;
    integer hp_main_check;
    integer hp_mon1 = 100;
    wire [10:0] o_hp_mon1;
    integer hp_mon1_check ;
    integer hp_mon2 = 100;
    wire [10:0] o_hp_mon2;
    integer hp_mon2_prev = 100;
    integer hp_mon2_check ;
    wire [10:0] o_hp_mon3;
    integer hp_mon3 = 100;
    integer hp_mon3_check;
                        
    wire [3:0] bulletRED;
    wire [3:0] bulletGREEN;
    wire [3:0] bulletBLUE;
    BulletScene bulletScene (.ix(x), .iy(y), .iactive(active),
        .ibtnL(btnL), .ibtnR(btnR), .ibtnU(btnU), .ibtnD(btnD),
        .iPixCLK(PixCLK), .iCLK(CLK), .iPS2Clk(PS2Clk), .iPS2Data(PS2Data), .hp(hp_main),
        .state(state),.noksel(noksel),
        .oRED(bulletRED), .oGREEN(bulletGREEN), .oBLUE(bulletBLUE), .hpO(hp_main_temp));
    
    wire h_main, h_mon1,  h_mon2, h_mon3, h_main_box, h_mon2_box, h_mon3_box, h_mon1_box;
    assign h_main_box = (((y > 40) &(y < 70)) & ((x > 15) & (x <= 20) | ((x >= 220) & (x < 225)))) | ((x>20 & x < 220) & ((y<=40 & y>35) | (y >= 70 & y < 75) ) ) ? 1:0;
    assign h_mon1_box = (((y > 40) &(y < 70)) & ((x > 575) & (x <= 580) | ((x >= 780) & (x < 785)))) | ((x > 580 & x < 780) & ((y<=40 & y>35) | (y >= 70 & y < 75) ) ) ? 1:0;
    assign h_mon2_box = (((y > 90) &(y < 120)) & ((x > 575) & (x <= 580) | ((x >= 780) & (x < 785)))) | ((x > 580 & x < 780) & ((y<=90 & y>85) | (y >= 120 & y < 125) ) ) ? 1:0;
    assign h_mon3_box = (((y > 140) &(y < 170)) & ((x > 575) & (x <= 580) | ((x >= 780) & (x < 785)))) | ((x > 580 & x < 780) & ((y<=140 & y>135) | (y >= 170 & y < 175) ) ) ? 1:0;
        
    assign h_main = ((x > 20) & (y >  40) & (x < hp_main_check) & (y < 70)) ? 1 : 0;
    assign h_mon1 = ((x > 580) & (y >  40) & (x < hp_mon1_check ) & (y < 70)) ? 1 : 0;
    assign h_mon2 = ((x > 580) & (y >  90) & (x < hp_mon2_check) & (y < 120)) ? 1 : 0;
    assign h_mon3 = ((x > 580) & (y >  140) & (x < hp_mon3_check) & (y < 170)) ? 1 : 0;       
    wire [3:0] titleRED;
    wire [3:0] titleGREEN;
    wire [3:0] titleBLUE;
    wire [3:0] state0_nextState;
    TitleScene titleScene (.ix(x), .iy(y), .iactive(active),
        .ibtnC(btnC),
        .iPixCLK(PixCLK), .iCLK(CLK), .iPS2Clk(PS2Clk), .iPS2Data(PS2Data),
        .oRED(titleRED), .oGREEN(titleGREEN), .oBLUE(titleBLUE),
        .state(state), .nextState(state0_nextState));

    wire [3:0] barRED;
    wire [3:0] barGREEN;
    wire [3:0] barBLUE;
//    wire [10:0] nextHealth;
    wire isEnding;
    wire [1:0] noksel;
    wire [3:0] state2_nextState;
    
    BarScene barScene (.xx(x), .yy(y), .aactive(active),
    .Pclk(PixCLK),
    .Reset(0), .ibtnX(btnC),
    .oRED(barRED), .oGREEN(barGREEN), .oBLUE(barBLUE),
    .isEnding(isEnding),
    .iCLK(CLK), .iPS2Clk(PS2Clk), .iPS2Data(PS2Data),
    .noksel(noksel),
    .hp_mon1(hp_mon1), .hp_mon2(hp_mon2), .hp_mon3(hp_mon3),
    .o_hp_mon1(o_hp_mon1), .o_hp_mon2(o_hp_mon2), .o_hp_mon3(o_hp_mon3),
    .state(state),.nextState(state2_nextState)
    );

    wire [3:0] menuRED;
    wire [3:0] menuGREEN;
    wire [3:0] menuBLUE;
    wire [1:0] state3_nextState;
    
    MenuScene menuScene (.ix(x), .iy(y), .iactive(active),
        .ibtnC(btnC), .ibtnL(btnL), .ibtnR(btnR), .ibtnU(btnU), .ibtnD(btnD),
        .iPixCLK(PixCLK), .iCLK(CLK), .iPS2Clk(PS2Clk), .iPS2Data(PS2Data),
        .oRED(menuRED), .oGREEN(menuGREEN), .oBLUE(menuBLUE),
        
        .state(state),.nextState(state3_nextState),.noksel(noksel)
        );

    reg reset_count;
    integer ms_count = 0;
    //reg sec_pulse;
    //always @ (posedge CLK && state == 1)
//    begin
//            ms_count <= ms_count+1;
//            if (reset_count == 1)
//                 begin
//                        ms_count <= 0;
//                        reset_count <= 0;
//                //sec_pulse <= 1;
////                hp_mon2 <= hp_mon2 - 1; 
////                if(hp_mon2 <= 0)
////                    hp_mon2 <= 0;
////                hp_mon2_prev <= hp_mon2;
//                    end
//    end

    // draw on the active area of the screen
    always @ (posedge PixCLK)
    begin
        if (ms_count == 199999999 & state == 1)
            begin
                state <= 3;
                ms_count = 0;
            end
        if(state == 1)
            begin
                ms_count <= ms_count + 1;
                hp_main = hp_main_temp;
                hp_main = hp_main_temp;
                hp_mon1 = o_hp_mon1;
                hp_mon2 = o_hp_mon2;
                hp_mon3 = o_hp_mon3;
        
            end
          
        if(hp_main <= 0 & state != 0)
        begin
            hp_main <= 0;
            state <= 0;
        end
        
        if(state == 0)
        begin
            hp_main = 100;
            hp_mon1 = 100;
            hp_mon2 = 100;
            hp_mon3 = 100;
        end
            
        hp_main_check <= hp_main * 2 + 20;
        hp_mon1_check <= hp_mon1 * 2 + 580;
        hp_mon2_check <= hp_mon2 * 2 + 580;
        hp_mon3_check <= hp_mon3 * 2 + 580;
        
        
        
        case(state)
            0: 
                begin
                    RED <= titleRED;
                    GREEN <= titleGREEN;
                    BLUE <= titleBLUE;
                    state <= state0_nextState;
                end
            1: 
                begin
                    RED <= bulletRED | {4{h_main}} | {4{h_main_box}} | {4{h_mon1_box}} | {4{h_mon2_box}} | {4{h_mon3_box}} ;
                    GREEN <= bulletGREEN | {4{h_mon1}} | {4{h_mon2}} | {4{h_mon3}} | {4{h_main_box}} | {4{h_mon1_box}} | {4{h_mon2_box}} | {4{h_mon3_box}};
                    BLUE <= bulletBLUE | {4{h_main_box}} | {4{h_mon1_box}} | {4{h_mon2_box}} | {4{h_mon3_box}} ;
                    
                end
            2: 
                begin
                    RED <= barRED | {4{h_main}} | {4{h_main_box}} | {4{h_mon1_box}} | {4{h_mon2_box}} | {4{h_mon3_box}};
                    GREEN <= barGREEN | {4{h_mon1}} | {4{h_mon2}} | {4{h_mon3}} | {4{h_main_box}} | {4{h_mon1_box}} | {4{h_mon2_box}} | {4{h_mon3_box}};
                    BLUE <= barBLUE | {4{h_main_box}} | {4{h_mon1_box}} | {4{h_mon2_box}} | {4{h_mon3_box}};
                    state <= state2_nextState;
                end
            3: 
                begin
                    RED <= menuRED;
                    GREEN <= menuGREEN;
                    BLUE <= menuBLUE;
                    state <= state3_nextState;
                    
                end
            default:
                begin
                    RED <= 1;
                    GREEN <= 1;
                    BLUE <= 1;
                end
        endcase
    end
endmodule