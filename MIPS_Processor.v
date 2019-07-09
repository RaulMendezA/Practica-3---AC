/******************************************************************
* Description
*	This is the top-level of a MIPS processor
* This processor is written Verilog-HDL. Also, it is synthesizable into hardware.
* Parameter MEMORY_DEPTH configures the program memory to allocate the program to
* be execute. If the size of the program changes, thus, MEMORY_DEPTH must change.
* This processor was made for computer organization class at ITESO.
******************************************************************/


module MIPS_Processor
#(
	parameter MEMORY_DEPTH = 64 //increased, agumnent even more in case of prgram not running
)

(
	// Inputs
	input clk,
	input reset,
	input [7:0] PortIn,
	// Output
	output [31:0] ALUResultOut,
	output [31:0] PortOut
);
//******************************************************************/
//******************************************************************/
// moved to bottom (just in case): assign  PortOut = PC_wire; //modified output

//******************************************************************/
//******************************************************************/
// Data types to connect modules
wire BranchNE_wire;
wire BranchEQ_wire;
wire RegDst_wire;
wire NotZeroANDBrachNE;
wire ZeroANDBrachEQ;
wire ORForBranch;
wire ALUSrc_wire;
wire RegWrite_wire;
wire Zero_wire;
wire Jump_wire; // new wires control
wire MemRead_wire;
wire MemtoReg_wire;
wire MemWrite_wire;
wire Jr_wire;
wire Jal_wire; //
wire [2:0] ALUOp_wire;
wire [3:0] ALUOperation_wire;
wire [4:0] WriteRegister_wire;
wire [4:0] MUX_ForRTypeAndIType_wire; //missing pc tutorial and mux wires
wire [31:0] MUX_PC_wire; 
wire [31:0]	PC_wire; //
wire [31:0] Instruction_wire;
wire [31:0] ReadData1_wire;
wire [31:0] ReadData2_wire;
wire [31:0] InmmediateExtend_wire;
wire [31:0] PC_InmmediateExtend_wire; //
wire [31:0] MUX_PC_InmmediateExtend_wire; //
wire [31:0] ReadData2OrInmmediate_wire;
wire [31:0] ALUResult_wire;
wire [31:0] PC_4_wire;
wire [31:0] PC_8_wire; //for branch
wire [31:0] InmmediateExtendAnded_wire; //unused for branch
wire [31:0] PCtoBranch_wire;
wire [31:0] ReadData_wire;
wire [31:0] MUX_RegisterFile_wire;
wire [31:0] MUX_WriteData_wire;
wire [31:0] MUX_Jump_wire;//


wire [31:0] MUX_Jr_wire;
wire [31:0] ReadDataOut_wire;
wire MemToReg_wire;
wire [31:0] Jump_PC_wire;
wire [31:0] MUX_FinalPC_wire;
wire [31:0] MUX_FinalWriteData_wire;
wire [4:0] 	MUX_WriteRegister_wire;


integer ALUStatus;

//New pipe wires:
//Pipeline IF to ID
wire [31:0] IF_PC_4_wire_ID;
wire [31:0] IF_Instruction_wire_ID;

//Pipeline ID to EX
wire ID_Jump_wire_EX;//1
wire ID_Jal_wire_EX;//1
wire ID_RegDst_wire_EX;//1
wire ID_BranchNE_wire_EX;//1
wire ID_BramchEQ_wire_EX;//1
wire ID_ALUSrc_wire_EX;
wire ID_RegWrite_wire_EX;
wire ID_MemWrite_wire_EX;
wire ID_MemRead_wire_EX; 
wire ID_MemtoReg_wire_EX;
wire [2:0]	ID_ALUOp_wire_EX;
wire [31:0] ID_PC_4_wire_EX;
wire [31:0] ID_ReadData1_wire_EX;
wire [31:0] ID_ReadData2_wire_EX;
wire [31:0] ID_Instruction_wire_Ex;
wire [31:0] ID_InmmediateExtend_wire_EX;

//Pipeline Ex to to MEM
wire EX_BranchNE_wire_MEM; //1
wire EX_BramchEQ_wire_MEM;//1
wire EX_MemtoReg_wire_MEM;			
wire EX_Zero_wire_MEM;				
wire EX_RegWrite_wire_MEM;	
wire EX_MemRead_wire_MEM;
wire [4:0] 	EX_MUX_ForRTypeAndIType_wire_MEM;			
wire [31:0]	EX_PC_InmmediateExtend_wire_MEM;			
wire [31:0] EX_ALUResult_wire_MEM;			
wire [31:0] EX_ReadData2_wire_MEM;			

//Pipeline MEM to WB
wire MEM_RegWrite_wire_WB;
wire MEM_MemtoReg_wire_WB;		
wire [4:0]  MEM_MUX_ForRTypeAndIType_wire_WB;  
wire [31:0] MEM_ReadData_wire_WB;
wire [31:0] MEM_ALUResult_wire_WB; 		

//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/

//New pipe regs instantiation
Pipeline //according to new pipe type
#(
	.N(64)
)
IF_Pipeline_ID
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({
					PC_4_wire,
					Instruction_wire
					}),
	.DataOutput({
					IF_PC_4_wire_ID, 
					IF_Instruction_wire_ID
					})
);	

Pipeline
#(
	.N(170)
)
ID_Pipeline_EX
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({
					RegDst_wire,					
					ALUOp_wire,						
					ALUSrc_wire,					
					RegWrite_wire,					
					MemWrite_wire,					
					MemRead_wire,					
					MemToReg_wire,					
					IF_PC_4_wire_ID, 				 
					ReadData1_wire,				
					ReadData2_wire,				
					InmmediateExtend_wire,		
					IF_Instruction_wire_ID		
					}),
	.DataOutput({
					ID_RegDst_wire_EX,					
					ID_ALUOp_wire_EX,						 
					ID_ALUSrc_wire_EX,					
					ID_RegWrite_wire_EX,					
					ID_MemWrite_wire_EX,					
					ID_MemRead_wire_EX,					
					ID_MemtoReg_wire_EX,					
					ID_PC_4_wire_EX, 					   
					ID_ReadData1_wire_EX,				
					ID_ReadData2_wire_EX,				
					ID_InmmediateExtend_wire_EX,		
					ID_Instruction_wire_Ex  		
	})	
);	


Pipeline
#(
	.N(106)
)
EX_Pipeline_MEM
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({	
					ID_RegWrite_wire_EX,
					ID_MemWrite_wire_EX,
					ID_MemRead_wire_EX,	
					ID_MemtoReg_wire_EX,
					PC_InmmediateExtend_wire,
					Zero_wire,
					ALUResult_wire,
					ID_ReadData2_wire_EX,
					MUX_WriteRegister_wire
					}),
	.DataOutput({
					EX_RegWrite_wire_MEM,
					EX_MemWrite_wire_MEM,
					EX_MemRead_wire_MEM,	
					EX_MemtoReg_wire_MEM,
					EX_PC_InmmediateExtend_wire_MEM,
					EX_Zero_wire_MEM,
					EX_ALUResult_wire_MEM,
					EX_ReadData2_wire_MEM,
					EX_MUX_ForRTypeAndIType_wire_MEM	
					}) 
);	

Pipeline
	#(
		.N(71)
	)
MEM_Pipeline_WB
(
		.clk(clk),
		.reset(reset),
		.enable(1),
		.DataInput({
					EX_RegWrite_wire_MEM,	
					EX_MemtoReg_wire_MEM,	
					ReadDataOut_wire,			
					EX_ALUResult_wire_MEM, 
					EX_MUX_ForRTypeAndIType_wire_MEM  
					}),
		.DataOutput({
					MEM_RegWrite_wire_WB,	
					MEM_MemtoReg_wire_WB,	
					MEM_ReadData_wire_WB,	
					MEM_ALUResult_wire_WB, 
					MEM_MUX_ForRTypeAndIType_wire_WB
		})   
	);	
	
Control
ControlUnit
(
	.OP(IF_Instruction_wire_ID[31:26]), //	.OP(Instruction_wire[31:26]),
	
	.Jump(Jump_wire), //added bit wire
	.RegDst(RegDst_wire),
	.BranchNE(BranchNE_wire),
	.BranchEQ(BranchEQ_wire),
	.ALUOp(ALUOp_wire),
	.ALUSrc(ALUSrc_wire),
	.RegWrite(RegWrite_wire),
	.MemRead(MemRead_wire), //more control bit wires
	.MemWrite(MemWrite_wire),
	.MemtoReg(MemToReg_wire),
	.Jal(Jal_wire)//
);
PC_Register
#(
	.N(32)
)
program_counter
(
	.clk(clk),
	.reset(reset),
	.NewPC(MUX_FinalPC_wire), //.NewPC(MUX_PC_wire),
	.PCValue(PC_wire)
);



ProgramMemory
#(
	.MEMORY_DEPTH(MEMORY_DEPTH)
)
ROMProgramMemory
(
	.Address(PC_wire),
	.Instruction(Instruction_wire)
);

Adder32bits
PC_Puls_4
(
	.Data0(PC_wire),
	.Data1(4),
	
	.Result(PC_4_wire)
);

//previously unused
//Adder32bits //module for plus 8 on pc
//PC_Puls_8
//(
//	.Data0(PC_wire),
//	.Data1(8),
//	.Result(PC_8_wire)
//);

//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Multiplexer2to1
#(
	.NBits(5)
)
MUX_ForRTypeAndIType //rt rd
(
	.Selector(ID_RegDst_wire_EX), //.Selector(RegDst_wire),
	.MUX_Data0(ID_Instruction_wire_Ex[20:16]), //.MUX_Data0(Instruction_wire[20:16]),
	.MUX_Data1(ID_Instruction_wire_Ex[15:11]), //.MUX_Data1(Instruction_wire[15:11]),
	.MUX_Output(MUX_WriteRegister_wire) //.MUX_Output(MUX_ForRTypeAndIType_wire)

);

//unused
//Multiplexer2to1 //added mux for write reg
//#(
//	.NBits(5)
//)
//MUX_ForWriteRegister //
//(
//	.Selector(Jal_wire),
//	.MUX_Data0(MUX_ForRTypeAndIType_wire),
//	.MUX_Data1({5'b11111}),
//	.MUX_Output(WriteRegister_wire)
//);

//unuserd
//Multiplexer2to1 //added mux for write dat 
//#(
//	.NBits(32)
//)
//MUX_ForWriteData //
//(
//	.Selector(Jal_wire),
//	.MUX_Data0(MUX_WriteData_wire),
//	.MUX_Data1(PC_4_wire),
//	.MUX_Output(MUX_RegisterFile_wire)	
//);



RegisterFile
Register_File
(
	.clk(clk),
	.reset(reset),
	.RegWrite(MEM_RegWrite_wire_WB), //.RegWrite(RegWrite_wire),
	.WriteRegister(MEM_MUX_ForRTypeAndIType_wire_WB), //.WriteRegister(WriteRegister_wire),
	.ReadRegister1(IF_Instruction_wire_ID[25:21]), //.ReadRegister1(Instruction_wire[25:21]), //rs
	.ReadRegister2(IF_Instruction_wire_ID[20:16]), //.ReadRegister2(Instruction_wire[20:16]), //rt
	.WriteData(MUX_FinalWriteData_wire), //.WriteData(MUX_RegisterFile_wire), 
	.ReadData1(ReadData1_wire),
	.ReadData2(ReadData2_wire)

);

SignExtend
SignExtendForConstants
(   
	.DataInput(IF_Instruction_wire_ID[15:0]), //.DataInput(Instruction_wire[15:0]),
   .SignExtendOutput(InmmediateExtend_wire)
);



Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForReadDataAndInmediate
(
	.Selector(ID_ALUSrc_wire_EX),//.Selector(ALUSrc_wire),
	.MUX_Data0(ID_ReadData2_wire_EX),//.MUX_Data0(ReadData2_wire),
	.MUX_Data1(ID_InmmediateExtend_wire_EX),//.MUX_Data1(InmmediateExtend_wire),
	
	.MUX_Output(ReadData2OrInmmediate_wire)
	

);



//unused
//Multiplexer2to1 //added mux for jump reg
//#(
//	.NBits(32)
//)
//MUX_ForJr //
//(
//	.Selector(Jr_wire),
//	.MUX_Data0(MUX_Jump_wire),
//	.MUX_Data1(ReadData1_wire),
//	.MUX_Output(MUX_PC_wire)
//
//);
//



ALUControl
ArithmeticLogicUnitControl
(
	.ALUOp(ID_ALUOp_wire_EX),//.ALUOp(ALUOp_wire),
	.ALUFunction(ID_InmmediateExtend_wire_EX[5:0]),//.ALUFunction(Instruction_wire[5:0]),
	.ALUOperation(ALUOperation_wire)
	//.Jr(Jr_wire)//new wire for jump reg

);



ALU
Arithmetic_Logic_Unit 
(
	.ALUOperation(ALUOperation_wire),
	.A(ID_ReadData1_wire_EX),//.A(ReadData1_wire),
	.B(ReadData2OrInmmediate_wire),
	.Zero(Zero_wire),
	.ALUResult(ALUResult_wire),
	.Shamt(ID_InmmediateExtend_wire_EX[10:6])//.Shamt(Instruction_wire[10:6]) //instantiation for new Shamt
);

//unused
//Adder32bits // added for pc and extend 
//PC_Puls_InmmediateExtend_wire //
//(
//	.Data0(PC_4_wire),
//	.Data1({InmmediateExtend_wire[29:0],2'b00}),
//	
//	.Result(PC_InmmediateExtend_wire)
//);

//unused
//Multiplexer2to1 //added fpr pc add
//#(
//	.NBits(32)
//)
//MUX_ForAddress //
//(
//	.Selector(PCtoBranch_wire),
//	.MUX_Data0(PC_4_wire),
//	.MUX_Data1(PC_InmmediateExtend_wire),
//	.MUX_Output(MUX_PC_InmmediateExtend_wire)
//
//);

//unused
//Multiplexer2to1 //added for new jump
//#(
//	.NBits(32)
//)
//MUX_ForJump
//(
//	.Selector(Jump_wire),
//	.MUX_Data0(MUX_PC_InmmediateExtend_wire),
//	.MUX_Data1({PC_4_wire[31:28],InmmediateExtend_wire[25:0],2'b00}),
//	.MUX_Output(MUX_Jump_wire)
//);

DataMemory //aded for memory mod
#(	 .DATA_WIDTH(32),		//has to be 32
	 .MEMORY_DEPTH(1024)
)
RAM//RAM_Memory
(
	.WriteData(EX_ReadData2_wire_MEM),//.WriteData(ReadData2_wire),
	.Address(EX_ALUResult_wire_MEM),//.Address(ALUResult_wire),
	.MemWrite(EX_MemWrite_wire_MEM),//.MemWrite(MemWrite_wire),
	.MemRead(EX_MemRead_wire_MEM),//.MemRead(MemRead_wire),
	.clk(clk),
	.ReadData(ReadDataOut_wire)//.ReadData(ReadData_wire)
);

Multiplexer2to1 //new mod for pipe
#(
	.NBits(32)
)
MUX_NextToRam
(
	.Selector(MEM_MemtoReg_wire_WB),
	.MUX_Data0(MEM_ALUResult_wire_WB),
	.MUX_Data1(MEM_ReadData_wire_WB),
	
	.MUX_Output(MUX_WriteData_wire)
);

Adder32bits //new mod for pipe
AddertoJump
(
	.Data0(ID_PC_4_wire_EX),
	.Data1({ID_InmmediateExtend_wire_EX[30:0],2'b00}),
	
	.Result(PC_InmmediateExtend_wire)
);
	
Multiplexer2to1 //instead of for jump
#(
	.NBits(32)
)
MUX_To_Jump	
(
	.Selector(Jump_wire),
	.MUX_Data0(Jump_PC_wire),
	.MUX_Data1({ PC_4_wire[31:28],  InmmediateExtend_wire[25:0],2'b00}),
	
	.MUX_Output(MUX_Jump_wire)
);

Multiplexer2to1 //suple a jr
#(
	.NBits(32)
)
MUX_Jr		
(
	.Selector(Jr_wire),
	.MUX_Data0(MUX_Jump_wire),
	.MUX_Data1(ReadData1_wire),
	
	.MUX_Output(MUX_Jr_wire)
);

Multiplexer2to1 //new mod supple a Jal
#(
	.NBits(5)
)
MUX_Jal		
(
	.Selector(Jal_wire),
	.MUX_Data0(MUX_WriteRegister_wire ),
	.MUX_Data1({5'b11111}),
	.MUX_Output(WriteRegister_wire)
);

Multiplexer2to1 //
#(
	.NBits(32)
)
MUX2_Jal		
(
	.Selector(Jal_wire),
	.MUX_Data0(MUX_WriteData_wire),
	.MUX_Data1(PC_4_wire),
	
	.MUX_Output(MUX_FinalWriteData_wire)
);


	
	Multiplexer2to1 //
#(
	.NBits(32)
)
MUX_Left_to_PC		
(
	.Selector(PCtoBranch_wire),
	.MUX_Data0(PC_4_wire),
	.MUX_Data1(EX_ALUResult_wire_MEM),
	
	.MUX_Output(MUX_FinalPC_wire)
);
	
//unused
//Multiplexer2to1 //added for write data mod
//#(
//	.NBits(32)
//)
//MUX_WriteData
//(
//	.Selector(MemtoReg_wire),
//	.MUX_Data0(ALUResult_wire),
//	.MUX_Data1(ReadData_wire),
//	.MUX_Output(MUX_WriteData_wire)
//
//);



assign ALUResultOut = ALUResult_wire;
assign PCtoBranch_wire = (Zero_wire & BranchEQ_wire) | (~Zero_wire & BranchNE_wire);
assign  PortOut = PC_wire;
endmodule

