`timescale 10 ns / 1 ns

module alu(
	input [31:0] A,
	input [31:0] B,
	input [4:0] ALUop,
	output Overflow,
	output CarryOut,
	output Zero,
	output [31:0] Result
);

//decode
	wire Add_op, Sub_op,
         Slt_op, Sltu_op, Sne_op, Se_op, Sge_op, Sgeu_op,
         Sll_op, Srl_op, Sra_op,
         And_op, Or_op, Xor_op, Nor_op,
         Bypass_op,
         Jlink_op;

	assign Add_op    = ALUop==5'b00000;
	assign Sub_op    = ALUop==5'b00001;
	wire Add_Sub_op;
	assign Add_Sub_op = Add_op || Sub_op;

	assign Slt_op    = ALUop==5'b01000;
	assign Sltu_op   = ALUop==5'b01001;
	assign Sne_op    = ALUop==5'b01010;
	assign Se_op     = ALUop==5'b01011;
	assign Sge_op   = ALUop==5'b01100;
	assign Sgeu_op   = ALUop==5'b01101;
	wire Comp_op;
	assign Comp_op   = Slt_op || Sltu_op || Sne_op || Se_op || Sge_op || Sgeu_op;

	assign Sll_op    = ALUop==5'b10000;
	assign Srl_op    = ALUop==5'b10001;
	assign Sra_op    = ALUop==5'b10010;
	wire Shift_op;
	assign Shift_op  = Sll_op || Srl_op || Sra_op;

	assign And_op    = ALUop==5'b10100;
	assign Or_op     = ALUop==5'b10101;
	assign Xor_op    = ALUop==5'b10110;
	assign Nor_op    = ALUop==5'b10111;
	wire Logic_op;
	assign Logic_op  = And_op || Or_op || Xor_op || Nor_op;

	assign Bypass_op = ALUop==5'b11000;

	assign Jlink_op  = ALUop==5'b11001;

//selet the result by the option
	wire [31:0] Result_add_sub, Result_comp, Result_shift, Result_logic, Result_bypass, Result_jlink;
	assign Result = {32{Add_Sub_op}} & Result_add_sub
	              | {32{   Comp_op}} & Result_comp
	              | {32{  Shift_op}} & Result_shift
	              | {32{  Logic_op}} & Result_logic
	              | {32{ Bypass_op}} & Result_bypass
	              | {32{  Jlink_op}} & Result_jlink;

//zero
	assign Zero = Result==32'b0;


//adder
	wire [31:0] B_to_adder, Result_from_adder;
	wire        extr, cin;
	assign B_to_adder = Jlink_op? 32'b100:
	                    Add_op?         B:
	                                   ~B;
	assign cin = Sub_op || Slt_op || Sltu_op || Sne_op || Se_op || Sge_op || Sgeu_op;
	assign {extr, Result_from_adder} = A + B_to_adder + cin;

	assign CarryOut = Add_op? extr: ~extr;                      
	assign Overflow = ~A[31] && (~B[31]^cin) &&  Result_add_sub[31]
                   ||  A[31] && ( B[31]^cin) && ~Result_add_sub[31];


//add, sub option
	assign Result_add_sub = Result_from_adder;

//compare option
	wire Result_slt, Result_sltu, Result_sne, Result_se, Result_Sge, Result_Sgeu;
	assign Result_slt  =  A[31] && ~B[31]	//A is -, B is +
                     || ~(A[31]  ^  B[31]) && Result_from_adder[31];
    assign Result_sltu =  CarryOut;
    assign Result_sne  = !Result_se;
    assign Result_se   =  Result_from_adder==32'b0;
    assign Result_Sge  = !Result_slt;
    assign Result_Sgeu = !Result_sltu;
    assign Result_comp = {31'b0, Slt_op  & Result_slt
                               | Sltu_op & Result_sltu
	                           | Sne_op  & Result_sne
	                           | Se_op   & Result_se
	                           | Sge_op  & Result_Sge
	                           | Sgeu_op & Result_Sgeu};

//shift option
	shift shift(
		.x(A),
		.shamt(B[4:0]),
		.y(Result_shift),

		.SLL(Sll_op),
		.SRL(Srl_op),
		.SRA(Sra_op)
	);

//logic option
	wire [31:0] Result_and, Result_or, Result_xor, Result_nor;
	assign Result_and = A & B;
	assign Result_or  = A | B;
	assign Result_xor = A ^ B;
	assign Result_nor = ~Result_or;
	assign Result_logic = {32{And_op}} & Result_and
	                    | {32{ Or_op}} & Result_or
	                    | {32{Xor_op}} & Result_xor
	                    | {32{Nor_op}} & Result_nor;

//bypass option
	assign Result_bypass = B;

//jlink option
	assign Result_jlink = Result_from_adder;

endmodule


module shift(
	input  [31:0] x,
	input  [ 4:0] shamt,
	output [31:0] y,

	input SLL,
	input SRL,
	input SRA
);
	wire [31:0] x_s;
	wire [31:0] mask;
	assign x_s = x>>shamt;
	assign mask = {32{x[31]}} & ~(32'hffffffff>>shamt);
	assign y = SLL? (x<<shamt):
               SRL? (x_s):
                    (x_s|mask);

endmodule








