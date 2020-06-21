`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file(
	input clk,
	input rst,
	input [`ADDR_WIDTH - 1:0] waddr,
	input [`ADDR_WIDTH - 1:0] raddr1,
	input [`ADDR_WIDTH - 1:0] raddr2,
	input wen,
	input [`DATA_WIDTH - 1:0] wdata,
	output [`DATA_WIDTH - 1:0] rdata1,
	output [`DATA_WIDTH - 1:0] rdata2
);

//do not have r[0]
	reg [31:0] r[31:1];
	
	always @(posedge clk)
		if(rst) begin
			r[ 1] <= 32'b0;
			r[ 2] <= 32'b0;
			r[ 3] <= 32'b0;
			r[ 4] <= 32'b0;
			r[ 5] <= 32'b0;
			r[ 6] <= 32'b0;
			r[ 7] <= 32'b0;
			r[ 8] <= 32'b0;
			r[ 9] <= 32'b0;
			r[10] <= 32'b0;
			r[11] <= 32'b0;
			r[12] <= 32'b0;
			r[13] <= 32'b0;
			r[14] <= 32'b0;
			r[15] <= 32'b0;
			r[16] <= 32'b0;
			r[17] <= 32'b0;
			r[18] <= 32'b0;
			r[19] <= 32'b0;
			r[20] <= 32'b0;
			r[21] <= 32'b0;
			r[22] <= 32'b0;
			r[23] <= 32'b0;
			r[24] <= 32'b0;
			r[25] <= 32'b0;
			r[26] <= 32'b0;
			r[27] <= 32'b0;
			r[28] <= 32'b0;
			r[29] <= 32'b0;
			r[30] <= 32'b0;
			r[31] <= 32'b0;
		end
		else if(wen && waddr)
			r[waddr] <= wdata;


//if address is 0, directly return 0;
	assign rdata1 = (raddr1==5'b0)? 32'b0:r[raddr1];
	assign rdata2 = (raddr2==5'b0)? 32'b0:r[raddr2];

endmodule
