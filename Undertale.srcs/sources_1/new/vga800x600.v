//--------------------------------------------------
// vga640x480 Module : Digilent Basys 3               
// BeeInvaders Tutorial 4 : Onboard clock 100MHz
// VGA Resolution 640x480 @ 60Hz : Pixel Clock 25MHz
//--------------------------------------------------
`timescale 1ns / 1ps

// Setup vga640x480 Module
module vga800x600(
    input wire i_clk,       // 100MHz onboard clock
    input wire i_rst,       // reset
    output wire o_hsync,    // horizontal sync
    output wire o_vsync,    // vertical sync
    output wire [10:0] o_x,  // current pixel x position
    output wire [10:0] o_y,  // current pixel y position
    output wire o_active,   // high during active pixel drawing
    output reg pix_clk      // 25MHz pixel clock
    );
	
    // VGA 640x480 Horizontal Timing (line)
	localparam HACTIVE     = 800;                      // horizontal visible area
	localparam HBACKPORCH  = 88;                       // horizontal back porch
	localparam HFRONTPORCH = 40;                       // horizontal front porch
	localparam HSYNC       = 128;                       // horizontal sync pulse
	localparam HSYNCSTART  = HACTIVE + HFRONTPORCH;                 // horizontal sync start
	localparam HSYNCEND    = HACTIVE + HFRONTPORCH + HSYNC - 1;        // horizontal sync end
	localparam LINEEND     = HACTIVE + HBACKPORCH + HFRONTPORCH + HSYNC - 1;   // horizontal line end
	reg [10:0] H_SCAN;                                  // horizontal line position
	
	// VGA 640x480 Vertical timing (frame)
	localparam VACTIVE     = 600;                      // vertical visible area
	localparam VBACKPORCH  = 23;                       // vertical back porch
	localparam VFRONTPORCH = 1;                       // vertical front porch
	localparam VSYNC       = 4;                        // vertical sync pulse
    localparam VSYNCSTART  = VACTIVE + VBACKPORCH;                 // vertical sync start
	localparam VSYNCEND    = VACTIVE + VBACKPORCH + VSYNC - 1;         // vertical sync end
	localparam SCREENEND   = VACTIVE + VFRONTPORCH + VBACKPORCH + VSYNC - 1;    // vertical screen end
	reg [10:0] V_SCAN;                                  // vertical screen position
	
    // set sync signals to low (active) or high (inactive)
    assign o_hsync = H_SCAN >= HSYNCSTART && H_SCAN <= HSYNCEND;
    assign o_vsync = V_SCAN >= VSYNCSTART && V_SCAN <= VSYNCEND;
    
    // set x and y values
    assign o_x = H_SCAN;
    assign o_y = V_SCAN;
    
    // set active high during active area
    assign o_active = ~(H_SCAN > HACTIVE) | (V_SCAN > VACTIVE);
  
    // generate 25MHz pixel clock using a "Fractional Clock Divider"
    reg [15:0] counter1;
    always @(posedge i_clk)
        // divide 100MHz by 4 = 25MHz : (2^16)/4 = 16384 decimal or 4000 hex
	    {pix_clk, counter1} <= counter1 + 16'h6666;
	    
	// check for reset / create frame loop
    always @(posedge i_clk)
		begin
		  if (i_rst)
            begin
                H_SCAN <= 0;
                V_SCAN <= 0;
            end
          if (pix_clk)  
            begin
		          if (H_SCAN == LINEEND)
		              begin
		                  H_SCAN <= 0;
		                  V_SCAN <= V_SCAN + 1;
		              end
		          else
		              H_SCAN <= H_SCAN + 1;
		          if (V_SCAN == SCREENEND)
		              V_SCAN <= 0;	
            end	      
		end
endmodule