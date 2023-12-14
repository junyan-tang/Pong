module PS2_Interface(inclock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, last_data_received);

	input 			inclock, resetn;
	inout 			ps2_clock, ps2_data;
	output 			ps2_key_pressed;
	output 	[7:0] 	ps2_key_data;
	output 	[7:0] 	last_data_received;

	// Internal Registers
	reg			[7:0]	last_data_received;	
	
	always @(posedge inclock)
	begin
		if (resetn == 1'b0)
			last_data_received <= 8'h00;
		else if (ps2_key_pressed == 1'b1) begin
//		   if(ps2_key_data == 8'h1D)  //up1
//			   last_data_received <=8'h00
//			if (ps2_key_data == 8'h1C)
//				last_data_received <= ps2_key_data + 8'h25;
//			else if (ps2_key_data == 8'h32)
//				last_data_received <= ps2_key_data + 8'h10;
//			else if (ps2_key_data == 8'h21)
//				last_data_received <= ps2_key_data + 8'h22;
//			else if (ps2_key_data == 8'h23)
//				last_data_received <= ps2_key_data + 8'h21;
//			else
				last_data_received <= ps2_key_data;
				end
//		else if (ps2_key_pressed == 1'b0)begin
//		  last_data_received <= 8'h00;
//		end
	end
	
	PS2_Controller PS2 (.CLOCK_50 			(inclock),
						.reset 				(~resetn),
						.PS2_CLK			(ps2_clock),
						.PS2_DAT			(ps2_data),		
						.received_data		(ps2_key_data),
						.received_data_en	(ps2_key_pressed)
						);

endmodule
