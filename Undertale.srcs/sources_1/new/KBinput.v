`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2020 01:07:54 AM
// Design Name: 
// Module Name: KBinput
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module KBinput(
    input clk,
    input kclk,
    input kdata,
    output reg [7:0] dataOut,
    output reg oflag
    );
    
    wire kclkf, kdataf;
    reg [7:0]datacur=0;
    reg [7:0]dataprev=0;
    reg [3:0]cnt=0;
    reg flag=0;
    reg pflag=0;
    reg CLK50MHZ=0;
    initial
        begin
            cnt<=4'h1;
            flag<=1'b0;
            datacur<=8'hf0;
            dataprev<=8'hf0;
            dataOut<=8'hf0;
        end 
        
    always @(posedge(clk))begin
        CLK50MHZ<=~CLK50MHZ;
    end
    
    
    debouncer #(
        .COUNT_MAX(19),
        .COUNT_WIDTH(5)
    )db_clk(
        .clk(CLK50MHZ),
        .I(kclk),
        .O(kclkf)
    );
    debouncer #(
        .COUNT_MAX(19),
        .COUNT_WIDTH(5)
    ) db_data(
        .clk(CLK50MHZ),
        .I(kdata),
        .O(kdataf)
    );
    
    always@(negedge(kclkf))begin
        case(cnt)
        0:;//Start bit
        1:datacur[0]<=kdataf;
        2:datacur[1]<=kdataf;
        3:datacur[2]<=kdataf;
        4:datacur[3]<=kdataf;
        5:datacur[4]<=kdataf;
        6:datacur[5]<=kdataf;
        7:datacur[6]<=kdataf;
        8:datacur[7]<=kdataf;
        9:flag<=1'b1;
        10:flag<=1'b0;
    
    endcase
        if(cnt<=9) cnt<=cnt+1;
        else if(cnt==10) cnt<=0;
    end
    
    
    always@(posedge flag) begin
        dataOut <= datacur;
        /*if (flag == 1'b1 && pflag == 1'b0) begin
            dataOut <= datacur;
            oflag <= 1'b1;
            dataprev <= datacur;
        end else
            oflag <= 'b0;
        pflag <= flag;*/
    end
    
    
endmodule
