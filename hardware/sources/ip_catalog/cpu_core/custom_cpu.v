`timescale 10ns / 1ns

module custom_cpu(
	input  rst,
	input  clk,

	//Instruction request channel
	output reg [31:0] PC,
	output Inst_Req_Valid,
	input Inst_Req_Ack,

	//Instruction response channel
	input  [31:0] Instruction,
	input Inst_Valid,
	output Inst_Ack,

	//Memory request channel
	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,
	output MemRead,
	input Mem_Req_Ack,

	//Memory data response channel
	input  [31:0] Read_data,
	input Read_data_Valid,
	output Read_data_Ack,

    output [31:0]	cpu_perf_cnt_0,
    output [31:0]	cpu_perf_cnt_1,
    output [31:0]	cpu_perf_cnt_2,
    output [31:0]	cpu_perf_cnt_3,
    output [31:0]	cpu_perf_cnt_4,
    output [31:0]	cpu_perf_cnt_5,
    output [31:0]	cpu_perf_cnt_6,
    output [31:0]	cpu_perf_cnt_7,
    output [31:0]	cpu_perf_cnt_8,
    output [31:0]	cpu_perf_cnt_9,
    output [31:0]	cpu_perf_cnt_10,
    output [31:0]	cpu_perf_cnt_11,
    output [31:0]	cpu_perf_cnt_12,
    output [31:0]	cpu_perf_cnt_13,
    output [31:0]	cpu_perf_cnt_14,
    output [31:0]	cpu_perf_cnt_15
);


	wire        PC_Stall, MEM_Stall, WB_Stall, 
	            BJ_NotLink_Submit, MEM_Write_Submit, WB_Submit,
	            MemtoReg;
	wire [31:0] Instruction_From_Reg, Read_data_From_Reg;

MEM_Control MEM_Control(
	.clk(clk),
	.rst(rst),

//Instruction request channel
	.Inst_Req_Valid(Inst_Req_Valid),
	.Inst_Req_Ack(Inst_Req_Ack),

//Instruction response channel
	.Instruction(Instruction),
	.Inst_Valid(Inst_Valid),
	.Inst_Ack(Inst_Ack),

//Memory request channel
	.Mem_Req_Ack(Mem_Req_Ack),

//Memory data response channel
	.Read_data_Valid(Read_data_Valid),
	.Read_data_Ack(Read_data_Ack),
	.Read_data(Read_data),

//cpu process input
	.BJ_NotLink_Submit(BJ_NotLink_Submit),
	.MEM_Write_Submit(MEM_Write_Submit),
	.WB_Submit(WB_Submit),
	.MemtoReg(MemtoReg),

//cpu process control
	.Instruction_From_Reg(Instruction_From_Reg),
	.Read_data_From_Reg(Read_data_From_Reg),
	.PC_Stall(PC_Stall),
	.MEM_Stall(MEM_Stall),
	.WB_Stall(WB_Stall)
);
	
	wire [31:0] Next_PC;
	always @(posedge clk)
		if(rst)
			PC <= 32'b0;
		else if(~PC_Stall)
			PC <= Next_PC;
		else ;


	wire [ 4:0]		RF_waddr;
	wire [ 4:0]		RF_raddr1;
	wire [ 4:0]		RF_raddr2;
	wire			RF_wen;
	wire [31:0]		RF_wdata;
	wire [31:0]		RF_rdata1;
	wire [31:0]		RF_rdata2;
	reg_file reg_file(
		.clk(clk),
		.rst(rst),
		
		.waddr(RF_waddr),
		.raddr1(RF_raddr1),
		.raddr2(RF_raddr2),
		.wen(RF_wen),
		
		.wdata(RF_wdata),
		.rdata1(RF_rdata1),
		.rdata2(RF_rdata2)
	);


	wire [31:0] Control_Flow_IF_In;
	assign Control_Flow_IF_In = PC;

	wire [31:0] Control_Flow_IF_Out;
	wire [31:0] Data_Flow_IF_Out;
	IF IF(
		.Control_Flow_IF_In(Control_Flow_IF_In),
		.Control_Flow_IF_Out(Control_Flow_IF_Out),
		.Data_Flow_IF_Out(Data_Flow_IF_Out),

		.Instruction(Instruction_From_Reg)
	);


	wire [ 31:0] Control_Flow_ID_In;
	wire [ 31:0] Data_Flow_ID_In;
	assign Control_Flow_ID_In = Control_Flow_IF_Out;
	assign Data_Flow_ID_In    = Data_Flow_IF_Out;

	wire [ 52:0] Control_Flow_ID_Out;
	wire [100:0] Data_Flow_ID_Out;
	ID ID(
		.Control_Flow_ID_In(Control_Flow_ID_In),
		.Data_Flow_ID_In(Data_Flow_ID_In),
		.Control_Flow_ID_Out(Control_Flow_ID_Out),
		.Data_Flow_ID_Out(Data_Flow_ID_Out),

		.RF_raddr1(RF_raddr1),
		.RF_raddr2(RF_raddr2),
		.RF_rdata1(RF_rdata1),
		.RF_rdata2(RF_rdata2)
	);


	wire [ 52:0] Control_Flow_EX_In;
	wire [100:0] Data_Flow_EX_In;
	assign Control_Flow_EX_In = Control_Flow_ID_Out;
	assign Data_Flow_EX_In    = Data_Flow_ID_Out;

	wire [ 10:0] Control_Flow_EX_Out;
	wire [100:0] Data_Flow_EX_Out;
	EX EX(
		.clk(clk),
	
		.Control_Flow_EX_In(Control_Flow_EX_In),
		.Data_Flow_EX_In(Data_Flow_EX_In),
		.Control_Flow_EX_Out(Control_Flow_EX_Out),
		.Data_Flow_EX_Out(Data_Flow_EX_Out),

		.Next_PC(Next_PC),

		.BJ_NotLink_Submit(BJ_NotLink_Submit)
	);


	wire [ 10:0] Control_Flow_MEM_In;
	wire [100:0] Data_Flow_MEM_In;
	assign Control_Flow_MEM_In = Control_Flow_EX_Out;
	assign Data_Flow_MEM_In    = Data_Flow_EX_Out;

	wire [  8:0] Control_Flow_MEM_Out;
	wire [100:0] Data_Flow_MEM_Out;
	MEM MEM(
		.MEM_Stall(MEM_Stall),

		.Control_Flow_MEM_In(Control_Flow_MEM_In),
		.Data_Flow_MEM_In(Data_Flow_MEM_In),
		.Control_Flow_MEM_Out(Control_Flow_MEM_Out),
		.Data_Flow_MEM_Out(Data_Flow_MEM_Out),

		.Address(Address),
		.Write_data(Write_data),
		.MemWrite(MemWrite),
		.Write_strb(Write_strb),
		.MemRead(MemRead),
		.Read_data(Read_data_From_Reg),

		.MEM_Write_Submit(MEM_Write_Submit),
		.MemtoReg(MemtoReg)
	);

	wire [  8:0] Control_Flow_WB_In;
	wire [100:0] Data_Flow_WB_In;
	assign Control_Flow_WB_In = Control_Flow_MEM_Out;
	assign Data_Flow_WB_In    = Data_Flow_MEM_Out;
	WB WB(
		.WB_Stall(WB_Stall),

		.Control_Flow_WB_In(Control_Flow_WB_In),
		.Data_Flow_WB_In(Data_Flow_WB_In),

		.RF_wen(RF_wen),
		.RF_waddr(RF_waddr),
		.RF_wdata(RF_wdata),

		.WB_Submit(WB_Submit)
	);

endmodule

module IF(
	input  [31:0] Control_Flow_IF_In,
	output [31:0] Control_Flow_IF_Out,
	output [31:0] Data_Flow_IF_Out,

	output [31:0] PC,
	input  [31:0] Instruction
	);

//Flow In
	assign PC          = Control_Flow_IF_In;

//Flow Out
	assign Control_Flow_IF_Out = PC;
	assign Data_Flow_IF_Out    = Instruction;

endmodule

module ID(
	input  [ 31:0] Control_Flow_ID_In,
	input  [ 31:0] Data_Flow_ID_In,
	output [ 52:0] Control_Flow_ID_Out,
	output [100:0] Data_Flow_ID_Out,

	output [  4:0] RF_raddr1,
	output [  4:0] RF_raddr2,
	input  [ 31:0] RF_rdata1,
	input  [ 31:0] RF_rdata2
);

//Flow In
	wire [31:0] PC, Instruction;
	assign PC          = Control_Flow_ID_In;
	assign Instruction = Data_Flow_ID_In;

//divide resource, reg dest
	wire [ 4:0] rs1, rs2, rd;
	assign rs1 = Instruction[19:15];
	assign rs2 = Instruction[24:20];
	assign rd  = Instruction[11: 7];

//conrol decoder
	wire Branch, J, JR, MemtoReg, ALUSrc_A_PC, ALUSrc_B_Imm, RF_wen, mov_type;
	wire [ 3:0] MemRead_masker;
	wire [ 3:0] Write_strb_r;
	wire [ 4:0] ALUOp;
	wire [31:0] Imm;

	Control_Decoder Control_Decoder(
	.Instruction(Instruction),
	
	.Branch(Branch),
	.J(J),
	.JR(JR),
	.MemRead_masker(MemRead_masker),
	.MemtoReg(MemtoReg),
	.ALUOp(ALUOp),
	.Write_strb_r(Write_strb_r),
	.ALUSrc_A_PC(ALUSrc_A_PC),
	.ALUSrc_B_Imm(ALUSrc_B_Imm),
	.RF_wen(RF_wen),
	.mov_type(mov_type),
	.Imm(Imm)
	);

//RF
	wire [4:0] RF_waddr;
	assign RF_raddr1 = rs1;
	assign RF_raddr2 = rs2;
	assign RF_waddr  = rd;

	              
//Flow Out
	assign Control_Flow_ID_Out = {PC,
	                              Branch, J, JR, MemRead_masker, MemtoReg, ALUOp, Write_strb_r, ALUSrc_A_PC, ALUSrc_B_Imm, RF_wen, mov_type};
	assign Data_Flow_ID_Out    = {RF_rdata1, RF_rdata2, Imm, RF_waddr};

endmodule

module EX(
	input          clk,
	
	input  [ 52:0] Control_Flow_EX_In,
	input  [100:0] Data_Flow_EX_In,
	output [ 10:0] Control_Flow_EX_Out,
	output [100:0] Data_Flow_EX_Out,

	output [ 31:0] Next_PC,

	output         BJ_NotLink_Submit
	);

//Flow In
	wire [31:0] PC;
	wire        Branch, J, JR, MemtoReg, RF_wen, mov_type;
	wire        ALUSrc_A_PC, ALUSrc_B_Imm;
	wire [ 3:0] MemRead_masker;
	wire [ 3:0] Write_strb_r;
	wire [ 4:0] ALUOp;
	assign {PC,
	        Branch, J, JR, MemRead_masker, MemtoReg, ALUOp, Write_strb_r, ALUSrc_A_PC, ALUSrc_B_Imm, RF_wen, mov_type} 
	       = Control_Flow_EX_In;
	wire [31:0] RF_rdata1, RF_rdata2, Imm;
	wire [ 4:0] RF_waddr;
	assign {RF_rdata1, RF_rdata2, Imm, RF_waddr}
           = Data_Flow_EX_In;

//next pc
	wire [31:0] PC_4, PC_Base, PC_BJ;
	wire        Branch_Taken;
	wire        BJ_Taken;
	wire        Zero;
	assign PC_4         = PC + 4;
	assign PC_Base      = JR? RF_rdata1:
	                          PC;
	assign PC_BJ        = PC_Base + Imm;
	assign Branch_Taken = Branch && Zero;
	assign BJ_Taken     = Branch_Taken || J || JR;
	assign BJ_NotLink_Submit    = (Branch || J || JR) && !RF_wen;
	assign Next_PC = BJ_Taken? PC_BJ:
	                           PC_4;


//multi cycle to save PC+4 for link
	reg [31:0] Last_PC;
	always @(posedge clk)
		Last_PC <= PC;
		
//ALU_A, ALU_B
	wire [31:0] ALU_A, ALU_B;
	assign ALU_A = ALUSrc_A_PC? Last_PC:
	                            RF_rdata1;
	assign ALU_B = ALUSrc_B_Imm? Imm:
	                             RF_rdata2;

//ALU
	wire [31:0] ALU_Result;
	wire [31:0] ALU_Result_r;
	alu alu(
		.A(ALU_A),
		.B(ALU_B),
		.ALUop(ALUOp),

		.Zero(Zero),
		.Result(ALU_Result_r)
	);

//store b,h
	wire [ 3:0] Write_strb;
	wire [31:0] Write_data;
	assign ALU_Result[31:2] = ALU_Result_r[31:2];
	assign ALU_Result[ 1:0] = (Write_strb_r==4'b0001||Write_strb_r==4'b0011
	                        || Write_strb_r==4'b0111||Write_strb_r==4'b1110)? 2'b00:
	                                                                          ALU_Result_r[1:0];
	assign Write_data = {32{Write_strb_r==4'b0001}} & {4{RF_rdata2[ 7:0]}}
	                  | {32{Write_strb_r==4'b0011}} & {2{RF_rdata2[15:0]}}
	                  | {32{Write_strb_r==4'b0111}} & ({32{ALU_Result_r[1:0]==2'b00}} & {RF_rdata2[31: 0]       }
	                                                 | {32{ALU_Result_r[1:0]==2'b01}} & {RF_rdata2[23: 0],  8'b0}
	                                                 | {32{ALU_Result_r[1:0]==2'b10}} & {RF_rdata2[15: 0], 16'b0}
	                                                 | {32{ALU_Result_r[1:0]==2'b11}} & {RF_rdata2[ 7: 0], 24'b0})
	                  | {32{Write_strb_r==4'b1110}} & ({32{ALU_Result_r[1:0]==2'b00}} & {24'b0, RF_rdata2[31:24]}
	                                                 | {32{ALU_Result_r[1:0]==2'b01}} & {16'b0, RF_rdata2[31:16]}
	                                                 | {32{ALU_Result_r[1:0]==2'b10}} & { 8'b0, RF_rdata2[31: 8]}
	                                                 | {32{ALU_Result_r[1:0]==2'b11}} & {       RF_rdata2[31: 0]})
	                  | {32{Write_strb_r==4'b1111}} &    RF_rdata2;
	                     
	assign Write_strb = {4{Write_strb_r==4'b0001&&ALU_Result_r[1:0]==2'b00}} & 4'b0001
	                  | {4{Write_strb_r==4'b0001&&ALU_Result_r[1:0]==2'b01}} & 4'b0010
	                  | {4{Write_strb_r==4'b0001&&ALU_Result_r[1:0]==2'b10}} & 4'b0100
	                  | {4{Write_strb_r==4'b0001&&ALU_Result_r[1:0]==2'b11}} & 4'b1000
	                  | {4{Write_strb_r==4'b0011&&ALU_Result_r[1:0]==2'b00}} & 4'b0011
	                  | {4{Write_strb_r==4'b0011&&ALU_Result_r[1:0]==2'b10}} & 4'b1100
	                  | {4{Write_strb_r==4'b0111                          }} & ({4{ALU_Result_r[1:0]==2'b00}} & 4'b1111
	                                                                          | {4{ALU_Result_r[1:0]==2'b01}} & 4'b1110
	                                                                          | {4{ALU_Result_r[1:0]==2'b10}} & 4'b1100
	                                                                          | {4{ALU_Result_r[1:0]==2'b11}} & 4'b1000)
	                  | {4{Write_strb_r==4'b1110                          }} & ({4{ALU_Result_r[1:0]==2'b00}} & 4'b0001
	                                                                          | {4{ALU_Result_r[1:0]==2'b01}} & 4'b0011
	                                                                          | {4{ALU_Result_r[1:0]==2'b10}} & 4'b0111
	                                                                          | {4{ALU_Result_r[1:0]==2'b11}} & 4'b1111)
	                  | {4{Write_strb_r==4'b1111                          }} & 4'b1111;
	
//Flow Out
	assign Control_Flow_EX_Out = {MemRead_masker, MemtoReg, Write_strb, RF_wen, mov_type};
	assign Data_Flow_EX_Out    = {ALU_Result, RF_rdata2, RF_waddr, Write_data};

endmodule

module MEM(
	input          MEM_Stall,

	input  [ 10:0] Control_Flow_MEM_In,
	input  [100:0] Data_Flow_MEM_In,
	output [  8:0] Control_Flow_MEM_Out,
	output [100:0] Data_Flow_MEM_Out,

	output [31:0] Address,
	output [31:0] Write_data,
	output [ 3:0] Write_strb,
	output        MemWrite,
	output        MemRead,
	input  [31:0] Read_data,

	output        MEM_Write_Submit,
	output        MemtoReg
	);

//Flow In
	wire [3:0] MemRead_masker;
	wire       RF_wen, mov_type;
	assign {MemRead_masker, MemtoReg, Write_strb, RF_wen, mov_type}
	       = Control_Flow_MEM_In & {5'b11111, {4{~MEM_Stall}}, 2'b11};
	wire [31:0] ALU_Result, RF_rdata2;
	wire [ 4:0] RF_waddr;
	assign {ALU_Result, RF_rdata2, RF_waddr, Write_data}
	       = Data_Flow_MEM_In;

//output to dataram
	assign Address    = ALU_Result;
	assign MemWrite   = Write_strb[3]|Write_strb[2]|Write_strb[1]|Write_strb[0];
	assign MemRead    = MemtoReg & ~MEM_Stall;

//RF_for_merge
	wire [31:0] RF_for_merge;
	assign RF_for_merge = RF_rdata2;

//write submit
	assign MEM_Write_Submit = MemWrite;

//Flow Out
	assign Control_Flow_MEM_Out = {MemRead_masker, MemtoReg, RF_wen, Address[1:0], mov_type};
	assign Data_Flow_MEM_Out = {Read_data, ALU_Result, RF_waddr, RF_for_merge};

endmodule

module WB(
	input          WB_Stall,

	input  [  8:0] Control_Flow_WB_In,
	input  [100:0] Data_Flow_WB_In,

	output         RF_wen,
	output [  4:0] RF_waddr,
	output [ 31:0] RF_wdata,

	output         WB_Submit
	);

//Flow In
	wire        MemtoReg, mov_type;
	wire [ 3:0] MemRead_masker;
	wire [ 1:0] Offset;
	assign {MemRead_masker, MemtoReg, RF_wen, Offset, mov_type}
	       = Control_Flow_WB_In & {5'b11111, ~WB_Stall, 3'b111};
	wire [31:0] Read_data, ALU_Result;
	wire [31:0] RF_for_merge;
	assign {Read_data, ALU_Result, RF_waddr, RF_for_merge}
	       = Data_Flow_WB_In;

//RF
	wire [31:0] load_merge;
	wire [15:0] Read_data_align;
	wire [31:0] Read_data_unalign;
	assign RF_wdata   = MemtoReg? load_merge:
	                              ALU_Result;
	assign Read_data_align = {16{Offset==2'b00}} &    Read_data[15: 0]
	                       | {16{Offset==2'b01}} & {2{Read_data[15: 8]}}
	                       | {16{Offset==2'b10}} &    Read_data[31:16]
	                       | {16{Offset==2'b11}} & {2{Read_data[31:24]}};
	assign Read_data_unalign = {32{MemRead_masker==4'b1110}} & ({32{Offset==2'b00}} & {Read_data[ 7:0], RF_for_merge[23:0]}
	                                                          | {32{Offset==2'b01}} & {Read_data[15:0], RF_for_merge[15:0]}
	                                                          | {32{Offset==2'b10}} & {Read_data[23:0], RF_for_merge[ 7:0]}
	                                                          | {32{Offset==2'b11}} & {Read_data[31:0]                     })
	                         | {32{MemRead_masker==4'b0111}} & ({32{Offset==2'b00}} & {                     Read_data[31: 0]}
	                                                          | {32{Offset==2'b01}} & {RF_for_merge[31:24], Read_data[31: 8]}
	                                                          | {32{Offset==2'b10}} & {RF_for_merge[31:16], Read_data[31:16]}
	                                                          | {32{Offset==2'b11}} & {RF_for_merge[31: 8], Read_data[31:24]});
	assign load_merge = {32{MemRead_masker==4'b1001}} & {{24{Read_data_align[7]}},  Read_data_align[7:0]}
	                  | {32{MemRead_masker==4'b0001}} & { 24'b0,                    Read_data_align[7:0]}
	                  | {32{MemRead_masker==4'b1011}} & {{16{Read_data_align[15]}}, Read_data_align[15:0]}
	                  | {32{MemRead_masker==4'b0011}} & { 16'b0,                    Read_data_align[15:0]}
	                  | {32{MemRead_masker==4'b1111}} &                             Read_data
	                  | {32{MemRead_masker==4'b0111
	                      | MemRead_masker==4'b1110}} &                             Read_data_unalign;

//submit
	assign WB_Submit = RF_wen & ~MemtoReg | mov_type;
endmodule


module Control_Decoder(
	input  [31:0] Instruction,

	output        Branch,
	output        J,
	output        JR,
	output [ 3:0] MemRead_masker,
	output        MemtoReg,
	output [ 4:0] ALUOp,
	output [ 3:0] Write_strb_r,
	output        ALUSrc_A_PC,
	output        ALUSrc_B_Imm,
	output        RF_wen,
	output        mov_type,
	output [31:0] Imm
);

//divide the instruction
	wire [ 4:0] rs1, rs2, rd;
	wire [ 6:0] op;
	wire [ 2:0] funct3;
	wire [ 6:0] funct7;
	assign op     = Instruction[ 6: 0];
	assign funct3 = Instruction[14:12];
	assign funct7 = Instruction[31:25];
	assign rs1    = Instruction[19:15];
	assign rs2    = Instruction[24:20];
	assign rd     = Instruction[11: 7];



//op decode
	wire OP_R, OP_IMM, OP_LOAD, OP_STORE, OP_BRANCH,
	     OP_LUI, OP_AUIPC, OP_JAL, OP_JALR;
	assign OP_R      = op==7'b0110011;
	assign OP_IMM    = op==7'b0010011;
	assign OP_LOAD   = op==7'b0000011;
	assign OP_STORE  = op==7'b0100011;
	assign OP_BRANCH = op==7'b1100011;
	assign OP_LUI    = op==7'b0110111;
	assign OP_AUIPC  = op==7'b0010111;
	assign OP_JAL    = op==7'b1101111;
	assign OP_JALR   = op==7'b1100111;
	
//inst decode
	//add, sub
	wire inst_ADD, inst_ADDI, inst_SUB;
	assign inst_ADD  = OP_R   && funct3==3'b000 && funct7==7'b0000000;
	assign inst_ADDI = OP_IMM && funct3==3'b000;
	assign inst_SUB  = OP_R   && funct3==3'b000 && funct7==7'b0100000;

	//comparation
	wire inst_SLT, inst_SLTI, inst_SLTU, inst_SLTIU;
	assign inst_SLT   = OP_R   && funct3==3'b010 && funct7==7'b0000000;
	assign inst_SLTI  = OP_IMM && funct3==3'b010;
	assign inst_SLTU  = OP_R   && funct3==3'b011 && funct7==7'b0000000;
	assign inst_SLTIU = OP_IMM && funct3==3'b011;

	//shift
	wire inst_SLL, inst_SLLI, inst_SRL, inst_SRLI, inst_SRA, inst_SRAI;
	assign inst_SLL  = OP_R   && funct3==3'b001 && funct7==7'b0000000;
	assign inst_SLLI = OP_IMM && funct3==3'b001 && funct7==7'b0000000;
	assign inst_SRA  = OP_R   && funct3==3'b101 && funct7==7'b0100000;
	assign inst_SRAI = OP_IMM && funct3==3'b101 && funct7==7'b0100000;
	assign inst_SRL  = OP_R   && funct3==3'b101 && funct7==7'b0000000;
	assign inst_SRLI = OP_IMM && funct3==3'b101 && funct7==7'b0000000;

	//logic
	wire inst_AND, inst_ANDI, inst_OR, inst_ORI, inst_XOR, inst_XORI;
	assign inst_AND  = OP_R   && funct3==3'b111 && funct7==7'b0000000;
	assign inst_ANDI = OP_IMM && funct3==3'b111;
	assign inst_OR   = OP_R   && funct3==3'b110 && funct7==7'b0000000;
	assign inst_ORI  = OP_IMM && funct3==3'b110;
	assign inst_XOR  = OP_R   && funct3==3'b100 && funct7==7'b0000000;
	assign inst_XORI = OP_IMM && funct3==3'b100;
	

	//load
	wire inst_LB, inst_LBU, inst_LH, inst_LHU, inst_LW;
	assign inst_LB  = OP_LOAD && funct3==3'b000;
	assign inst_LBU = OP_LOAD && funct3==3'b100;
	assign inst_LH  = OP_LOAD && funct3==3'b001;
	assign inst_LHU = OP_LOAD && funct3==3'b101;
	assign inst_LW  = OP_LOAD && funct3==3'b010;

	//store
	wire inst_SB, inst_SH, inst_SW;
	assign inst_SB  = OP_STORE && funct3==3'b000;
	assign inst_SH  = OP_STORE && funct3==3'b001;
	assign inst_SW  = OP_STORE && funct3==3'b010;

	//branch
	wire inst_BEQ, inst_BNE, inst_BLT, inst_BGE, inst_BLTU, inst_BGEU;
	assign inst_BEQ  = OP_BRANCH && funct3==3'b000;
	assign inst_BNE  = OP_BRANCH && funct3==3'b001;
	assign inst_BLT  = OP_BRANCH && funct3==3'b100;
	assign inst_BGE  = OP_BRANCH && funct3==3'b101;
	assign inst_BLTU = OP_BRANCH && funct3==3'b110;
	assign inst_BGEU = OP_BRANCH && funct3==3'b111;

	//others
	wire inst_LUI, inst_AUIPC, inst_JAL, inst_JALR;
	assign inst_LUI   = OP_LUI;
	assign inst_AUIPC = OP_AUIPC;
	assign inst_JAL   = OP_JAL;
	assign inst_JALR  = OP_JALR && funct3==3'b000;

//Type
	wire R_type, I_type, S_type, B_type, U_type, J_type;
	assign R_type = inst_SLLI || inst_SRLI || inst_SRAI || OP_R;
	assign I_type = OP_IMM&&!inst_SLLI&&!inst_SRLI&&!inst_SRAI
	             || OP_LOAD || OP_JALR;
	assign S_type = OP_STORE;
	assign B_type = OP_BRANCH;
	assign U_type = OP_LUI || OP_AUIPC;
	assign J_type = OP_JAL;

//ALU option
	//add, sub
	wire Add_op, Sub_op;
	assign Add_op = inst_ADD || inst_ADDI || OP_LOAD || OP_STORE || OP_AUIPC;
	assign Sub_op = inst_SUB;

	//comparation
	wire Slt_op, Sltu_op, Sne_op, Se_op, Sge_op, Sgeu_op;
	assign Slt_op  = inst_SLT  || inst_SLTI  || inst_BGE;
	assign Sltu_op = inst_SLTU || inst_SLTIU || inst_BGEU;
	assign Sne_op  = inst_BEQ;
	assign Se_op   = inst_BNE;
	assign Sge_op  = inst_BLT;
	assign Sgeu_op = inst_BLTU;

	//shift
	wire Sll_op, Srl_op, Sra_op;
	assign Sll_op = inst_SLL || inst_SLLI;
	assign Srl_op = inst_SRL || inst_SRLI;
	assign Sra_op = inst_SRA || inst_SRAI;

	//logic
	wire And_op, Or_op, Xor_op;
	assign And_op = inst_AND || inst_ANDI;
	assign Or_op  = inst_OR  || inst_ORI;
	assign Xor_op = inst_XOR || inst_XORI;

	//bypass
	wire Bypass_op;
	assign Bypass_op = OP_LUI;

	wire Jlink_op;
	assign Jlink_op =  OP_JAL || OP_JALR;

//make control
	assign Branch   = OP_BRANCH;
	assign J        = OP_JAL;
	assign JR       = OP_JALR;
	assign MemRead_masker  = {4{ inst_LB}} & 4'b1001
	                       | {4{inst_LBU}} & 4'b0001
	                       | {4{ inst_LH}} & 4'b1011
	                       | {4{inst_LHU}} & 4'b0011
	                       | {4{ inst_LW}} & 4'b1111;

	assign MemtoReg = OP_LOAD;

	assign ALUOp    = {5{Add_op}}    & 5'b00000
	                | {5{Sub_op}}    & 5'b00001

	                | {5{Slt_op}}    & 5'b01000
	                | {5{Sltu_op}}   & 5'b01001
	                | {5{Sne_op}}    & 5'b01010
	                | {5{Se_op}}     & 5'b01011
	                | {5{Sge_op}}    & 5'b01100
	                | {5{Sgeu_op}}   & 5'b01101

	                | {5{Sll_op}}    & 5'b10000
	                | {5{Srl_op}}    & 5'b10001
	                | {5{Sra_op}}    & 5'b10010

	                | {5{And_op}}    & 5'b10100
	                | {5{Or_op}}     & 5'b10101
	                | {5{Xor_op}}    & 5'b10110

	                | {5{Bypass_op}} & 5'b11000
	                | {5{Jlink_op}}  & 5'b11001;

	assign Write_strb_r = {4{ inst_SB}}  & 4'b0001
	                    | {4{ inst_SH}}  & 4'b0011
	                    | {4{ inst_SW}}  & 4'b1111;

	assign ALUSrc_A_PC  = OP_JAL || OP_JALR  || OP_AUIPC;
	assign ALUSrc_B_Imm = OP_IMM || OP_STORE || OP_LOAD  || OP_LUI || OP_AUIPC;


	assign RF_wen = OP_LUI  || OP_AUIPC || OP_JAL || OP_JALR
	             || OP_LOAD || OP_IMM   || OP_R;

	assign mov_type = 1'b0;

//Imm
	wire [31:0] R_Imm, I_Imm, S_Imm, B_Imm, U_Imm, J_Imm;
	assign Imm   = {32{R_type}} & R_Imm
	             | {32{I_type}} & I_Imm
	             | {32{S_type}} & S_Imm
	             | {32{B_type}} & B_Imm
	             | {32{U_type}} & U_Imm
	             | {32{J_type}} & J_Imm;
	assign R_Imm = {27'b0, Instruction[24:20]};
	assign I_Imm = {{21{Instruction[31]}}, Instruction[30:20]};
	assign S_Imm = {{21{Instruction[31]}}, Instruction[30:25], Instruction[11:7]};
	assign B_Imm = {{20{Instruction[31]}}, Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
	assign U_Imm = {Instruction[31:12], 12'b0};
	assign J_Imm = {{12{Instruction[31]}}, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};
endmodule

`define RST 3'b000
`define IF  3'b001
`define IW  3'b010
`define ID  3'b011
`define EX  3'b100
`define ST_LD_WB 3'b101
`define RDW 3'b110
`define WB  3'b111

module MEM_Control(
	input clk,
	input rst,

//Instruction request channel
	output Inst_Req_Valid,
	input Inst_Req_Ack,

//Instruction response channel
	input  [31:0] Instruction,
	input Inst_Valid,
	output Inst_Ack,

//Memory request channel
	input Mem_Req_Ack,

//Memory data response channel
	input Read_data_Valid,
	output Read_data_Ack,
	input [31:0] Read_data,

//cpu process input
	input         BJ_NotLink_Submit,
	input         MEM_Write_Submit,
	input         WB_Submit,
	input         MemtoReg,

//cpu process control
	output [31:0] Instruction_From_Reg,
	output [31:0] Read_data_From_Reg,
	output        PC_Stall,
	output        MEM_Stall,
	output        WB_Stall
);
	reg  [ 2:0] Q;
	reg  [ 2:0] Next_Q;
	reg  [31:0] Instruction_R, Read_data_R;

	always @(posedge clk)
		if(rst)
			Q <= 3'b0;
		else 
		    Q <= Next_Q;
	
	always @(*)
		case(Q)
			`RST:
				Next_Q = `IF;
			`IF:
				if(Inst_Req_Ack)
					Next_Q = `IW;
				else
					Next_Q = `IF;
			`IW:
				if(Inst_Valid)
					Next_Q = `ID;
				else
					Next_Q = `IW;
			`ID:
				Next_Q = `EX;
			`EX:
				if(BJ_NotLink_Submit)
					Next_Q = `IF;
				else
					Next_Q = `ST_LD_WB;
			`ST_LD_WB:
				if(WB_Submit | MEM_Write_Submit&Mem_Req_Ack)
					Next_Q = `IF;
				else if(Mem_Req_Ack)
					Next_Q = `RDW;
				else
					Next_Q = `ST_LD_WB;
			`RDW:
				if(Read_data_Valid)
					Next_Q = `WB;
				else
					Next_Q = `RDW;
			`WB:
				Next_Q = `IF;
			default: ;
		endcase

/*	assign Next_Q = {3{Q==`RST}} & 3'b001
	              | {3{Q==`IF}} &  (Inst_Req_Ack? 3'b010:
	              	                                 3'b001)
	              | {3{Q==`IW}} &  (Inst_Valid? 3'b011:
	              	                               3'b010)
	              | {3{Q==`ID}} & 3'b100
	              | {3{Q==3'b100}} &  (BJ_NotLink_Submit? 3'b001:
	              	                                      3'b101)
	              | {3{Q==3'b101}} & ((WB_Submit | MEM_Write_Submit&Mem_Req_Ack)? 3'b001:
	              	                   Mem_Req_Ack?                               3'b110:
	              	                                                              3'b101)
	              | {3{Q==3'b110}} &  (Read_data_Valid? 3'b111:
	              	                                    3'b110)
	              | {3{Q==3'b111}} & 3'b001;
*/

	assign {Inst_Req_Valid, Inst_Ack, Read_data_Ack, PC_Stall, MEM_Stall, WB_Stall}
	              = {6{Q==`RST}} & 6'b011111
	              | {6{Q==`IF}}  & 6'b100111
	              | {6{Q==`IW}}  & 6'b010111
	              | {6{Q==`ID}}  & 6'b000111
	              | {6{Q==`EX}}  & 6'b000011
	              | {6{Q==`ST_LD_WB}} & (MemtoReg? 6'b000101:
	              	                            6'b000100)
	              | {6{Q==`RDW}} & 6'b001111
	              | {6{Q==`WB}}  & 6'b000110;

	always @(posedge clk)
		if(rst)
			Instruction_R <= 32'b0;
		else if(Q==`IW&Inst_Valid)
			Instruction_R <= Instruction;
	
	always @(posedge clk)
		if(rst)
			Read_data_R <= 32'b0;
		else if(Read_data_Valid)
			Read_data_R <= Read_data;

//forward instruction
	assign Instruction_From_Reg = (Q==`IW&Inst_Valid)? Instruction:
	                                                   Instruction_R;
	assign Read_data_From_Reg = Read_data_R;
		
endmodule














