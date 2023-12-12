module number_display();
reg [10:0] addr_reg;
always @(posedge clk)

always @*
	case (addr_reg)
		