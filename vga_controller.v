module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
							 up1,
							 down1,
							 up2,
							 down2,
							 sw
							 );

	
input iRST_n;
input iVGA_CLK;
input up1, down1, up2, down2;
input sw;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
///////// ////                     
reg [18:0] ADDR;
reg [23:0] bgr_data;
reg [9:0] current_x,current_y;
reg [31:0] counter;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;
////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     ADDR <= 19'd0;
  else if (cHS == 1'b0 && cVS == 1'b0)
     ADDR <= 19'd0;
  else if (cBLANK_n==1'b1)
     ADDR <= ADDR+1;
current_x <= ADDR % 640;
current_y <= ADDR / 640;
end
//////////////////////////
//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;
img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index )
	);
	
/////////////////////////
//////Add switch-input logic here
	
//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	
//////
//////latch valid data at falling edge;
//always@(posedge VGA_CLK_n) 
//begin
//  
//end
assign b_data = bgr_data[23:16];
assign g_data = bgr_data[15:8];
assign r_data = bgr_data[7:0]; 
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

//variable for paddles
reg [9:0] p1x = 10'd220;
reg [9:0] p1y = 10'd280;
reg [9:0] p2x = 10'd400;
reg [9:0] p2y = 10'd280;

//variable for player scores
reg [3:0] p1score = 3'd0;
reg [3:0] p2score = 3'd0;

//varibale for the ball
reg [9:0] ball_x = 10'd340;
reg [9:0] ball_y = 10'd280;
reg [1:0] mv = 0;

//temp variable for new ball
reg [9:0] btemp_x = 10'd340;
reg [9:0] btemp_y = 10'd280;

//radius of the ball
parameter r = 10'd7;

//two clocks
reg [20:0] slow_count = 20'd0;
reg [20:0] fast_count = 20'd0;
wire slow_clock;
wire fast_clock;

//Generate customized clock
//assign slow_clock = slow_count[20];
//always@ (posedge VGA_CLK_n)
//begin
//		slow_count <= slow_count + 1;
//end

//assign fast_clock = fast_count[10];
//always@ (posedge VGA_CLK_n)
//begin
//	fast_count <= fast_count + 1;
//end

//movement of player1's paddle
always@(posedge VGA_CLK_n) 
begin
	//if switch is eaqual to 0, the game has already begun
  if(sw == 1'b0)
    begin 
	 if (counter%400000 == 0)
	   if(up1 == 1'b0 && down1 == 1'b0)
			p1y <= p1y;
		else if (up1 == 1'b0) begin
			if (p1y < 80)
				p1y <= 80;
			else
				p1y <= p1y - 1;
			end
		else if (down1 == 1'b0) begin
			if (p1y + 80 > 450)
				p1y <= 370;
			else
				p1y <= p1y + 1;
			end
	 end
	else
		p1y <= 280;
end
	
//movement of player2's paddle
always@(posedge VGA_CLK_n) 
begin
	//if switch is eaqual to 0, the game has already begun
  if(sw == 1'b0)
    begin 
	 if (counter%400000 == 0)
	   if(up2 == 1'b0 && down2 == 1'b0)
			p2y <= p2y;
		else if (up2 == 1'b0) begin
			if (p2y < 80)
				p2y <= 80;
			else
				p2y <= p2y - 1;
			end
		else if (down2 == 1'b0) begin
			if (p2y + 80 > 450)
				p2y <= 370;
			else
				p2y <= p2y + 1;
			end
	 end
	else
		p2y <= 280;
end

//movement of ball and generation of new ball
always@(posedge VGA_CLK_n)
begin
	if(sw == 1'b0)
		begin
			if((current_x>ball_x -r && current_x<ball_x + r && current_y>ball_y -r && current_y < ball_y + r )
			 || (current_x>p2x && current_x<p2x + 20 && current_y>p2y && current_y < p2y + 80)
			 || (current_x>p1x && current_x<p1x + 20 && current_y>p1y && current_y < p1y + 80))
			 bgr_data <= 24'haf5555;
			else
			 bgr_data <= bgr_data_raw;
			 
			 
			 if (counter >= 1000000)
			 counter <= 0;
			 else
			 counter <= counter + 1;
			 
			 if (counter == 0) 
			case(mv)
				//SW direction
				0: begin
						ball_x <= ball_x - 1;
						ball_y <= ball_y + 1;
					end
				//SE direction
				1: begin
						ball_x <= ball_x + 1;
						ball_y <= ball_y + 1;
					end
				//NW direction
				2: begin
						ball_x <= ball_x - 1;
						ball_y <= ball_y - 1;
					end
				//NE direction
				3: begin
						ball_x <= ball_x + 1;
						ball_y <= ball_y - 1;
					end
			endcase
			//top and bottom bound
			if(ball_y - r< 80 && mv == 3)
				mv = 2;
			else if (ball_y - r < 80 && mv == 2)
				mv = 0;
			else if (ball_y + r > 450 && mv == 0)
				mv = 2;
			else if (ball_y + r > 450 && mv == 1)
				mv = 3;
			//left and right paddle
			else if (ball_x -r < p1x + 20 && ball_y > p1y && ball_y < p1y + 80 &&  mv == 0)
				mv = 1;
			else if (ball_x -r < p1x + 20 && ball_y > p1y && ball_y < p1y + 80 &&  mv == 2)
				mv = 3;
			else if (ball_x +r > p2x && ball_y > p2y && ball_y < p2y + 80 &&  mv == 1)
				mv = 0;
			else if (ball_x +r > p2x && ball_y > p2y && ball_y < p2y + 80 &&  mv == 3)
				mv = 2;
			//player2 score
			else if (ball_x - r < 238) begin
				p2score = p2score + 1;
				//reset ball
				ball_x <= 340;
				ball_y <= 280;
//				ball_x <= btemp_x - p2score;
//				ball_y <= btemp_y - p2score * 2;
//				btemp_x <= ball_x;
//				btemp_y <= ball_y;
//				if( ball_x < 247 || ball_x > 393 || ball_y > 443 || ball_y < 87)begin
//					ball_x <= 320;
//					ball_y <= 280;
//					btemp_x <= ball_x;
//					btemp_y <= ball_y;
//					end
				end
			//player1 score
			else if (ball_x + r >= 402)begin
				p1score = p1score + 1;
				//reset ball
				ball_x <= 340;
				ball_y <= 280;
//				ball_x <= btemp_x + p1score;
//				ball_y <= btemp_y + p1score * 2;
//				btemp_x <= ball_x;
//				btemp_y <= ball_y;
//				if( ball_x < 247 || ball_x > 393 || ball_y > 443 || ball_y < 87)begin
//					ball_x <= 320;
//					ball_y <= 280;
//					btemp_x <= ball_x;
//					btemp_y <= ball_y;
//					end
				end
		
			if(p1score == 11 || p2score == 11) begin
				p1score <= 0;
				p2score <= 0;
				end
		end

	else
		begin
		ball_x <= 340;
		ball_y <= 280;
		p1score <= 0;
		p2score <= 0;
		end
	
	end


endmodule
 	















