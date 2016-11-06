//Top level file

`include "interfaces_all.sv"
`include "def_params.sv"
`include "debug.sv"
`include "test_fetch.sv"
`include "test_controller.sv"
`include "test_decode.sv"
`include "test_execute.sv"
`include "test_writeback.sv"
`include "test_memaccess.sv"
`include "driver.sv"

program automatic LC3_Test(topInterface LC3Interface, fetchInterface fetch_Interface, decodeInterface decode_Interface, executeInterface execute_Interface,
							writebackInterface writeback_Interface, memaccessInterface memaccess_Interface, controlInterface control_Interface);
	
// Covergroup for ALU instructions.	
covergroup ALU_OPR();	

	// To cover all ALU operations.
	Cov_alu_opcode : coverpoint execute_Interface.IR_Exec[15:12]
	{
		bins ADD = {ADD};
		bins AND = {AND};	
		bins NOT = {NOT};
	}

	Cov_alu_opcode1 : coverpoint execute_Interface.IR_Exec[15:12]
	{
		bins ADD = {ADD};
		bins AND = {AND};	
	}

	// To cover immediate instructions.
	Cov_imm_en :coverpoint execute_Interface.IR_Exec[5] iff(execute_Interface.IR_Exec[15:12] == AND || execute_Interface.IR_Exec[15:12] == ADD );
	
	// To cover all possible values of SR1, SR2 and DR 

	Cov_SR1 : coverpoint execute_Interface.IR_Exec[8:6] iff(execute_Interface.IR_Exec[15:12] == ADD || execute_Interface.IR_Exec[15:12] == NOT || execute_Interface.IR_Exec[15:12] == AND );

	Cov_SR2 : coverpoint execute_Interface.IR_Exec[2:0] iff((execute_Interface.IR_Exec[5]==1'b0) && (execute_Interface.IR_Exec[15:12] == ADD || execute_Interface.IR_Exec[15:12] == AND )); 

	Cov_DR : coverpoint execute_Interface.IR_Exec[11:9] iff(execute_Interface.IR_Exec[15:12] == ADD || execute_Interface.IR_Exec[15:12] == NOT || execute_Interface.IR_Exec[15:12] == AND );

	// To cover all possible values of imm5
	Cov_imm5 : coverpoint execute_Interface.IR_Exec[4:0] iff(execute_Interface.IR_Exec[5] == 1'b1);

	// To cross cover ALU opcode and immediate operation
	Xc_opcode_imm_en : cross Cov_alu_opcode, Cov_imm_en	
	{
		ignore_bins illegal1 = binsof(Cov_alu_opcode) intersect {NOT};
	//	bins cross1 = !binsof(Cov_alu_opcode) intersect {NOT};

	}

	// To cross cover ALU opcode, DR and imm5 for immediate operations
	Xc_opcode_dr_sr1_imm5 : cross Cov_alu_opcode,Cov_DR,Cov_SR1, Cov_imm5 iff(execute_Interface.IR_Exec[5] == 1'b1)
	{
	
		ignore_bins illegal2 = binsof(Cov_alu_opcode) intersect {NOT};		
	
	}

	// To cross cover ALU opcode, SR1, SR2 and DR 
	Xc_opcode_dr_sr1_sr2 : cross Cov_alu_opcode,Cov_DR,Cov_SR1,Cov_SR2 iff(execute_Interface.IR_Exec[5] == 1'b0)
	{	
		ignore_bins illegal3 = binsof(Cov_alu_opcode) intersect {NOT};		
	}

	// To cover different values of ALU1 in the execute stage
	Cov_aluin1 : coverpoint EX.ALU1 iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND )	
	{
		option.auto_bin_max=8;	
	}

	Cov_aluin1_corner : coverpoint EX.ALU1 iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND )              	
	{
		bins allzeros = {16'b0};
		bins allones ={16'hFFFF};
		bins alt0 = {16'hAAAA};
		bins alt1 ={16'h5555};
	}
	
	// To cover different values of ALU1 in the execute stage
	Cov_aluin2: coverpoint EX.ALU2 iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND )	
	{
		option.auto_bin_max=8;	
	}
	
	Cov_aluin2_corner: coverpoint EX.ALU2 iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND )	
	{
		bins allzeros = {16'b0};
		bins allones ={16'hFFFF};
		bins alt0 = {16'hAAAA};
		bins alt1 ={16'h5555};
	}
	
	Xc_opcode_aluin1 : cross Cov_alu_opcode,Cov_aluin1_corner iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND );

	Xc_opcode_aluin2 : cross Cov_alu_opcode1,Cov_aluin2_corner iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == AND );

	Cov_opr_aluin1_zero : coverpoint EX.ALU1 iff(execute_Interface.IR[15:12] == ADD || execute_Interface.IR[15:12] == NOT || execute_Interface.IR[15:12] == AND )	
	{
		bins aluin1_zero = {16'h0000};
	}
	
	Cov_opr_aluin2_zero : coverpoint EX.ALU2 iff(execute_Interface.IR[15:12] == ADD || execute_Interface.IR[15:12] == NOT || execute_Interface.IR[15:12] == AND )	
	{
		bins aluin2_zero = {16'h0000};
	}

	Cov_opr_aluin1_all1 : coverpoint EX.ALU1 iff(execute_Interface.IR[15:12] == ADD || execute_Interface.IR[15:12] == NOT || execute_Interface.IR[15:12] == AND )	
	{
		bins aluin1_all1 = {16'hffff};
	}

	Cov_opr_aluin2_all1 : coverpoint EX.ALU2 iff(execute_Interface.IR[15:12] == ADD || execute_Interface.IR[15:12] == NOT || execute_Interface.IR[15:12] == AND )	
	{
		bins aluin2_all1 = {16'hffff};
	}

	
	Cov_opr_zero_zero : cross Cov_opr_aluin1_zero,Cov_opr_aluin2_zero 
	{
		bins zero_zero = binsof(Cov_opr_aluin1_zero) && binsof(Cov_opr_aluin2_zero);
	}

	Cov_opr_zero_all1: cross Cov_opr_aluin1_zero,Cov_opr_aluin2_all1 
	{
		bins zero_all1 = binsof(Cov_opr_aluin1_zero) && binsof(Cov_opr_aluin2_all1);		
	}

	Cov_opr_all1_zero : cross Cov_opr_aluin1_all1,Cov_opr_aluin2_zero 
	{
		bins all1_zero = binsof(Cov_opr_aluin1_all1) && binsof(Cov_opr_aluin2_zero);
	}

	Cov_opr_all1_all1 : cross Cov_opr_aluin1_all1,Cov_opr_aluin2_all1
	{
		bins all1_all1 = binsof(Cov_opr_aluin1_all1) && binsof(Cov_opr_aluin2_all1);
	}

	// Needs directed test case.
	Cov_opr_aluin1_01 : coverpoint EX.ALU1 iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND )
	{
		bins aluin1_01 = {16'b0101010101010101};		
	}
	
	// Needs directed test case.
	Cov_opr_aluin2_01 : coverpoint EX.ALU2 iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND )
	{
		bins aluin2_01 = {16'b0101010101010101};
	}

	// Needs directed test case.
	Cov_opr_aluin1_10 : coverpoint EX.ALU1 iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND )
	{
		bins aluin1_10 = {16'b1010101010101010};
	}

	// Needs directed test case.
	Cov_opr_aluin2_10 : coverpoint EX.ALU2 iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND )
	{
		bins aluin2_10 = {16'b1010101010101010};
	}
	
	// Needs directed test case.
	Cov_opr_alt01_alt01 : cross Cov_opr_aluin1_01,Cov_opr_aluin2_01 
	{
		bins alt01_alt01 = binsof(Cov_opr_aluin1_01) && binsof (Cov_opr_aluin2_01);	

	}

	// Needs directed test case.		
	Cov_opr_alt01_alt10 : cross Cov_opr_aluin1_01,Cov_opr_aluin2_10 
	{
		bins alt01_alt10 = binsof(Cov_opr_aluin1_01) && binsof (Cov_opr_aluin2_10);	

	}

	// Needs directed test case.
	Cov_opr_alt10_alt01 : cross Cov_opr_aluin1_10,Cov_opr_aluin2_01
	{

	bins alt10_alt01 = binsof(Cov_opr_aluin1_10) && binsof (Cov_opr_aluin2_01);	

	}

	// Needs directed test case.
	Cov_opr_alt10_alt10 : cross Cov_opr_aluin1_10, Cov_opr_aluin2_10 
	{
		bins alt10_alt10 = binsof(Cov_opr_aluin1_10) && binsof (Cov_opr_aluin2_10);	

	}
	
	Cov_opr_aluin1_pos : coverpoint EX.ALU1 [15] iff (execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND )
	{
		bins aluin1_pos = {1'b0};
	}
	
	Cov_opr_aluin2_pos : coverpoint EX.ALU2 [15] iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND )
	{
		bins aluin2_pos = {1'b1};
	}

	Cov_opr_aluin1_neg : coverpoint EX.ALU1 [15] iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND )
	{
		bins aluin1_neg = {1'b0};
	}

	Cov_opr_aluin2_neg : coverpoint EX.ALU2 [15] iff(execute_Interface.IR_Exec[15:12] == ADD ||execute_Interface.IR_Exec[15:12] == NOT ||execute_Interface.IR_Exec[15:12] == AND )
	{
		bins aluin2_neg = {1'b1};
	}

	Cov_opr_pos_pos : cross Cov_opr_aluin1_pos, Cov_opr_aluin2_pos 
	{
		bins pos_pos = binsof(Cov_opr_aluin1_pos) && binsof(Cov_opr_aluin2_pos);
	}

	Cov_opr_pos_neg : cross Cov_opr_aluin1_pos, Cov_opr_aluin2_neg
	{
		bins pos_neg = binsof(Cov_opr_aluin1_pos) && binsof(Cov_opr_aluin2_neg);
	}

	Cov_opr_neg_pos : cross Cov_opr_aluin1_neg, Cov_opr_aluin2_pos 
	{
		bins neg_pos = binsof(Cov_opr_aluin1_neg) && binsof(Cov_opr_aluin2_pos);
	}

	Cov_opr_neg_neg : cross Cov_opr_aluin1_neg, Cov_opr_aluin2_neg 
	{
		bins neg_neg = binsof(Cov_opr_aluin1_neg) && binsof(Cov_opr_aluin2_neg);
	}

endgroup

// Covergroup for Control operations

covergroup CTRL_OPR();
	
	// To cover all types of control instructions.
	Cov_ctrl_opcode :coverpoint control_Interface.IR_Exec[15:12]
	{
		bins BR = {4'b0000};
		bins JMP = {4'b1100};
	}
	
	// To cover all possible base register values
	Cov_baseR : coverpoint control_Interface.IR_Exec[8:6] iff(control_Interface.IR_Exec[15:12] == JMP);
	
	// To cover all values of NZP for branch 
	Cov_NZP : coverpoint control_Interface.NZP iff(control_Interface.IR_Exec[15:12] == BR)
	{
		bins N = {3'b100};
		bins Z = {3'b010};	
		bins P = {3'b001};	
	}

	// To cover all values of PSR for branch
	Cov_PSR : coverpoint control_Interface.psr iff(control_Interface.IR_Exec[15:12] == BR)
	{
		bins P = {3'b100};
		bins S = {3'b010};	
		bins R = {3'b001};	
	}

	// To cover all possible values of the PCoffset9
	Cov_PCoffset9 : coverpoint control_Interface.IR_Exec [8:0] iff(control_Interface.IR_Exec [15:12] == BR) 	
	{
		option.auto_bin_max=8;		
	}	

	// To cover corner value cases of the PCoffset9
	Cov_PCoffset9_c : coverpoint control_Interface.IR_Exec [8:0] iff(control_Interface.IR_Exec [15:12] == BR)	
	{
		bins allzeros = {9'b0};
		bins allones ={9'b111111111};
		bins alt0 = {9'b010101010};
		bins alt1 ={9'b101010101};	
	}	

	// To cross cover all values of NZP and PSR
	Xc_NZP_PSR : cross Cov_NZP, Cov_PSR ;

endgroup

	mailbox mb;
	generator gen;
	driver drv;
	ALU_OPR ALU;
	MEM_OPR MEMO;
	CTRL_OPR CTRL;
	OPR_SEQ SEQ;

	//Instantiate LC3 stage classes.	
	fetch FE = new(fetch_Interface);
	decode DE = new(decode_Interface);
	controller CO = new(control_Interface);
	execute EX = new(execute_Interface);
	writeback WB = new(writeback_Interface);
	memaccess MEM = new(memaccess_Interface);
	//begin

	Instruction instr;
	//end

	//Assertions
	property reset_property;
		@(posedge LC3Interface.clock)
			(LC3Interface.reset==1'b1) |-> (fetch_Interface.pc==16'h3000 && decode_Interface.IR==16'b0 && decode_Interface.npc_out==16'b0 && decode_Interface.E_Control==6'b0 && decode_Interface.W_Control== 2'b0 && decode_Interface.Mem_Control ==1'b0 && execute_Interface.W_Control_out==2'b00 && execute_Interface.Mem_Control_out==1'b0 && execute_Interface.aluout==16'h0000 && execute_Interface.pcout==16'b0 && execute_Interface.IR_Exec==16'b0 && execute_Interface.NZP==3'b000 && execute_Interface.M_Data==16'b0 && execute_Interface.dr==3'b000 && writeback_Interface.psr==3'b000);
	endproperty					
	reset : cover property (reset_property);
	
	property ctrl_br_taken;
		@(posedge LC3Interface.clock)
			|(execute_Interface.NZP)==1 |=> (control_Interface.br_taken ==1'b1);
	endproperty
	CTRL_br_taken_jmp : cover property (ctrl_br_taken);

	property controller_enable_decode1;
		@(posedge LC3Interface.clock)
			(control_Interface.IR_Exec[15:12]==LD || control_Interface.IR_Exec[15:12]==LDR || control_Interface.IR_Exec[15:12]==ST || control_Interface.IR_Exec[15:12]==STR) |-> control_Interface.enable_decode==1'b0; // LD LDR ST STR
	endproperty
	CTRL_enable_decode1 : cover property (controller_enable_decode1);

	property controller_enable_decode2;
		@(posedge LC3Interface.clock)
			(control_Interface.IR_Exec[15:12]==LD || control_Interface.IR_Exec[15:12]==LDR || control_Interface.IR_Exec[15:12]==ST || control_Interface.IR_Exec[15:12]==STR) |=> control_Interface.enable_decode==1'b1;      //LD LDR ST STR
	endproperty
	CTRL_enable_decode2 : cover property (controller_enable_decode2);

	property controller_enable_decode3;
		@(posedge LC3Interface.clock)
			(control_Interface.IR_Exec[15:12]==LDI || control_Interface.IR_Exec[15:12]==STI) |-> control_Interface.enable_decode==1'b0; //LDI STI
	endproperty
	CTRL_enable_decode3 : cover property (controller_enable_decode3);

	property controller_enable_decode4;
		@(posedge LC3Interface.clock)
			(control_Interface.IR_Exec[15:12]==LDI || control_Interface.IR_Exec[15:12]==STI) ##2 control_Interface.enable_decode==1'b1; //LDI STI
	endproperty
	CTRL_enable_decode4 : cover property (controller_enable_decode4);

	property controller_enable_fetch1;
		@(posedge LC3Interface.clock)
			(control_Interface.IR_Exec[15:12]==LD || control_Interface.IR_Exec[15:12]==LDR || control_Interface.IR_Exec[15:12]==ST || control_Interface.IR_Exec[15:12]==STR) |-> control_Interface.enable_fetch==1'b0;       //LD LDR ST STR
	endproperty
	CTRL_enable_fetch1 : cover property (controller_enable_fetch1);

	property controller_enable_fetch2;
		@(posedge LC3Interface.clock)
			(control_Interface.IR_Exec[15:12]==LD || control_Interface.IR_Exec[15:12]==LDR || control_Interface.IR_Exec[15:12]==ST || control_Interface.IR_Exec[15:12]==STR) |=> control_Interface.enable_fetch==1'b1;      //LD LDR ST STR
	endproperty
	CTRL_enable_fetch2 : cover property (controller_enable_fetch2);

	property controller_enable_fetch3;
		@(posedge LC3Interface.clock)
			(control_Interface.IR_Exec[15:12]==LDI || control_Interface.IR_Exec[15:12]==STI) |-> control_Interface.enable_fetch==1'b0;  //LDI STI
	endproperty
	CTRL_enable_fetch3 : cover property (controller_enable_fetch3);

	property controller_enable_fetch4;
		@(posedge LC3Interface.clock)
			(control_Interface.IR_Exec[15:12]==LDI || control_Interface.IR_Exec[15:12]==STI) ##2 control_Interface.enable_fetch==1'b1; //LDI STI
	endproperty
	CTRL_enable_fetch4 : cover property (controller_enable_fetch4);

	property controller_enable_mem_state_3;
		@(posedge LC3Interface.clock)
			(control_Interface.IR_Exec[15:12]==4'b0010 || control_Interface.IR_Exec[15:12]==4'b0110 || control_Interface.IR_Exec[15:12]==4'b0011 || control_Interface.IR_Exec[15:12]==4'b0111)|=> control_Interface.mem_state==2'b11;
	endproperty
	CTRL_enable_mem_state_3 : cover property (controller_enable_mem_state_3);

	property controller_bypass_alu_1_AA;
		@(posedge LC3Interface.clock)
			((control_Interface.IR_Exec[15:12]==4'b0001 || control_Interface.IR_Exec[15:12]==4'b0101 || control_Interface.IR_Exec[15:12]==4'b1001 || control_Interface.IR_Exec[15:12]==4'b1110) ##1 (control_Interface.IR[15:12]==4'b0001 || control_Interface.IR[15:12]==4'b0101 || control_Interface.IR[15:12]==4'b1001) && control_Interface.IR_Exec[11:9]==control_Interface.IR[8:6]) |-> control_Interface.bypass_alu_1==1'b1;
	endproperty
	CTRL_bypass_alu_1_AA : cover property (controller_bypass_alu_1_AA);
	
	property controller_bypass_alu_2_AA;
		@(posedge LC3Interface.clock)
			((control_Interface.IR_Exec[15:12]==4'b0001 || control_Interface.IR_Exec[15:12]==4'b0101 || control_Interface.IR_Exec[15:12]==4'b1001 || control_Interface.IR_Exec[15:12]==4'b1110) ##1 (control_Interface.IR[15:12]==4'b0001 || control_Interface.IR[15:12]==4'b0101 || control_Interface.IR[15:12]==4'b1001)  && ((control_Interface.IR_Exec[11:9]==control_Interface.IR[2:0]) && (control_Interface.IR[5]!=1'b1))) |-> control_Interface.bypass_alu_2==1'b1;
	endproperty
	CTRL_bypass_alu_2_AA : cover property (controller_bypass_alu_2_AA);	

	property controller_bypass_alu_1_AS;
		@(posedge LC3Interface.clock)
			((control_Interface.IR_Exec[15:12] == 4'b0001 || control_Interface.IR_Exec[15:12] == 4'b0101 || control_Interface.IR_Exec[15:12] == 4'b1001 || control_Interface.IR[15:12] == 4'b0011 || control_Interface.IR[15:12] == 4'b0111 || control_Interface.IR[15:12] == 4'b1011) && (control_Interface.IR_Exec[11:9] == control_Interface.IR[8:6])) |-> control_Interface.bypass_alu_1==1'b1;
	endproperty
	CTRL_bypass_alu_1_AS : cover property (controller_bypass_alu_1_AS);

	property controller_bypass_alu_2_AS;
		@(posedge LC3Interface.clock)
			((control_Interface.IR_Exec[15:12] == 4'b0001 || control_Interface.IR_Exec[15:12] == 4'b0101 || control_Interface.IR_Exec[15:12] == 4'b1001 || control_Interface.IR[15:12] == 4'b0011 || control_Interface.IR[15:12] == 4'b0111 || control_Interface.IR[15:12] == 4'b1011) && (control_Interface.IR_Exec[11:9] == control_Interface.IR[2:0])) |-> control_Interface.bypass_alu_2==1'b1;
	endproperty
	CTRL_bypass_alu_2_AS : cover property (controller_bypass_alu_2_AS);
	
	property controller_bypass_mem_1_LA;
		@(posedge LC3Interface.clock)
		((control_Interface.IR_Exec[15:12]==4'b0010 || control_Interface.IR_Exec[15:12]==4'b0110 || control_Interface.IR_Exec[15:12]==4'b1010) && (control_Interface.IR[15:12]==4'b0001 || control_Interface.IR[15:12]==4'b0101 || control_Interface.IR[15:12]==4'b1001) && (control_Interface.IR_Exec[11:9]==control_Interface.IR[8:6])) |-> control_Interface.bypass_mem_1==1'b1;
	endproperty
	CTRL_bypass_mem_1_LA : cover property (controller_bypass_mem_1_LA);

	property controller_bypass_mem_2_LA;
		@(posedge LC3Interface.clock)
		((control_Interface.IR_Exec[15:12]==4'b0010 || control_Interface.IR_Exec[15:12]==4'b0110 || control_Interface.IR_Exec[15:12]==4'b1010) && (control_Interface.IR[15:12]==4'b0001 || control_Interface.IR[15:12]==4'b0101 || control_Interface.IR[15:12]==4'b1001) && ((control_Interface.IR_Exec[11:9]==control_Interface.IR[2:0]) && (control_Interface.IR[5]!=1'b1))) |-> control_Interface.bypass_mem_2==1'b1;
	endproperty
	CTRL_bypass_mem_2_LA : cover property (controller_bypass_mem_2_LA);

	property controller_mem_state_3_1;
		@(posedge LC3Interface.clock)
		control_Interface.mem_state==2'b11 |=> control_Interface.mem_state==2'b01;  // LDI STI
	endproperty
	CTRL_mem_state_3_1 : cover property (controller_mem_state_3_1);
	
	property controller_mem_state_3_0;
		@(posedge LC3Interface.clock)
		control_Interface.mem_state==2'b11 |=> control_Interface.mem_state==2'b0;   // LD LDR
	endproperty
	CTRL_mem_state_3_0 : cover property (controller_mem_state_3_0);
	
	property controller_mem_state_3_2;
		@(posedge LC3Interface.clock)
		control_Interface.mem_state==2'b11 |=> control_Interface.mem_state==2'b10;  // ST STR
	endproperty
	CTRL_mem_state_3_2 : cover property (controller_mem_state_3_2);
	
	property controller_mem_state_2_3;
		@(posedge LC3Interface.clock)
		control_Interface.mem_state==2'b10 |=> control_Interface.mem_state==2'b11; // ST STR
	endproperty
	CTRL_mem_state_2_3 : cover property (controller_mem_state_2_3);
	
	property controller_mem_state_1_0;
		@(posedge LC3Interface.clock)
		control_Interface.mem_state==2'b01 |=> control_Interface.mem_state==2'b0;  // LDI
	endproperty
	CTRL_mem_state_1_0 : cover property (controller_mem_state_1_0);
	
	property controller_mem_state_1_2;
		@(posedge LC3Interface.clock)
		control_Interface.mem_state==2'b01 |=> control_Interface.mem_state==2'b10;   // STI
	endproperty
	CTRL_mem_state_1_2 : cover property (controller_mem_state_1_2);
	
	property controller_mem_state_0_3;
		@(posedge LC3Interface.clock)
		control_Interface.mem_state==2'b0 |=> control_Interface.mem_state==2'b11;  // LD LDR
	endproperty
	CTRL_mem_state_0_3 : cover property (controller_mem_state_0_3);
	
	property controller_mem_state_STI;
		@(posedge LC3Interface.clock)
		(control_Interface.IR_Exec[15:12]==4'b1011) |-> control_Interface.mem_state==2'b01 ##1 control_Interface.mem_state==2'b10 ##1 control_Interface.mem_state==2'b11;
	endproperty
	CTRL_mem_state_STI : cover property (controller_mem_state_STI);
	
	property controller_mem_state_LDI;
		@(posedge LC3Interface.clock)
		(control_Interface.IR_Exec[15:12]==4'b1010) |-> control_Interface.mem_state==2'b01 ##1 control_Interface.mem_state==2'b0 ##1 control_Interface.mem_state==2'b11;
	endproperty
	CTRL_mem_state_LDI : cover property (controller_mem_state_LDI);
	
	
	property controller_enable_wb_ST1;
		@(posedge LC3Interface.clock)
		(control_Interface.IR_Exec[15:12]==4'b0111 || control_Interface.IR_Exec[15:12]==4'b0011 || control_Interface.IR_Exec[15:12]==4'b1011) |-> control_Interface.enable_writeback==1'b0;
	endproperty
	CTRL_enable_wb_ST1 : cover property (controller_enable_wb_ST1);
	
	property controller_enable_wb_ST2;
		@(posedge LC3Interface.clock)
		(control_Interface.IR_Exec[15:12]==4'b0111 || control_Interface.IR_Exec[15:12]==4'b0011) ##2 control_Interface.enable_writeback==1'b1;
	endproperty
	CTRL_enable_wb_ST2 : cover property (controller_enable_wb_ST2);
	
	property controller_enable_wb_ST3;
		@(posedge LC3Interface.clock)
		(control_Interface.IR_Exec[15:12]==4'b1011) ##3 control_Interface.enable_writeback==1'b1;
	endproperty
	CTRL_enable_wb_ST3 : cover property (controller_enable_wb_ST3);
	
	
	property controller_enable_wb_LD1;
		@(posedge LC3Interface.clock)
		(control_Interface.IR_Exec[15:12]==4'b0010 || control_Interface.IR_Exec[15:12]==4'b0110 || control_Interface.IR_Exec[15:12]==4'b1010) |-> control_Interface.enable_writeback==1'b0;
	endproperty
	CTRL_enable_wb_LD1 : cover property (controller_enable_wb_LD1);
	
	property controller_enable_wb_LD2;
		@(posedge LC3Interface.clock)
		(control_Interface.IR_Exec[15:12]==4'b0010 || control_Interface.IR_Exec[15:12]==4'b0110) |=> control_Interface.enable_writeback==1'b1;
	endproperty
	CTRL_enable_wb_LD2 : cover property (controller_enable_wb_LD2);
	
	property controller_enable_wb_LD3;
		@(posedge LC3Interface.clock)
		(control_Interface.IR_Exec[15:12]==4'b1010) |=> control_Interface.enable_writeback==1'b0 |=> control_Interface.enable_writeback==1'b1;
	endproperty
	CTRL_enable_wb_LD3 : cover property (controller_enable_wb_LD3);

	initial 
	begin 	//Drive the inputs

		mb = new();
		gen = new(mb,LC3Interface);
		drv = new(mb,LC3Interface);
		ALU = new();
		MEMO = new(gen.ip.instr);
		CTRL = new();
		SEQ = new(gen.ip.instr);

		repeat(6)
		begin
			LC3Interface.reset = 1;
			LC3Interface.complete_instr = 1;
			LC3Interface.complete_data = 1;
			#1;
			FE.fetch_goldenref();  FE.fetch_checker_asyn();//async checker
			DE.decode_goldenref();  
			EX.execute_goldenref();   EX.execute_checker_asyn();
			WB.writeback_goldenref();  WB.writeback_checker_asyn();	
			MEM.memaccess_goldenref();  MEM.memaccess_checker_asyn();
			CO.control_goldenref();   CO.control_checker_asyn();
			
			@(posedge LC3Interface.clock);

			#1;
			LC3Interface.reset = 0;
			FE.fetch_checker_syn();
			DE.decode_checker_syn();
			EX.execute_checker_syn();
			WB.writeback_checker_syn();
			CO.control_checker_syn();	
		end
		
		repeat(10000)
		begin
			#1;
			if (LC3Interface.instrmem_rd == 1)
			begin
				gen.run();
				drv.run();
			end
			
			#1;
			FE.fetch_goldenref();  FE.fetch_checker_asyn();
			DE.decode_goldenref();  
			EX.execute_goldenref();   EX.execute_checker_asyn();
			WB.writeback_goldenref();  WB.writeback_checker_asyn();	
			MEM.memaccess_goldenref();  MEM.memaccess_checker_asyn();
			CO.control_goldenref();   CO.control_checker_asyn();

			//Sample coverage points
			ALU.sample();
			MEMO.sample();
			CTRL.sample();
			SEQ.sample();
				
			@(posedge LC3Interface.clock);
			#1;
				//sync checker
				FE.fetch_checker_syn();
				DE.decode_checker_syn();
				EX.execute_checker_syn();
				WB.writeback_checker_syn();
				CO.control_checker_syn();	
		end


		repeat(6)
		begin
			LC3Interface.reset = 1;
			#1;
			FE.fetch_goldenref();  FE.fetch_checker_asyn(); //async checker
			DE.decode_goldenref();  
			EX.execute_goldenref();   EX.execute_checker_asyn();
			WB.writeback_goldenref();  WB.writeback_checker_asyn();	
			MEM.memaccess_goldenref();  MEM.memaccess_checker_asyn();
			CO.control_goldenref();   CO.control_checker_asyn();
			
			@(posedge LC3Interface.clock);

			#1;
			LC3Interface.reset = 0;
			FE.fetch_checker_syn();
			DE.decode_checker_syn();
			EX.execute_checker_syn();
			WB.writeback_checker_syn();
			CO.control_checker_syn();	
		end

		repeat(500000)
		begin
			#1;
			if (LC3Interface.instrmem_rd == 1)
			begin
				gen.run();
				drv.run();
			end
			
			#1;
			FE.fetch_goldenref();  FE.fetch_checker_asyn();
			DE.decode_goldenref();  
			EX.execute_goldenref();   EX.execute_checker_asyn();
			WB.writeback_goldenref();  WB.writeback_checker_asyn();	
			MEM.memaccess_goldenref();  MEM.memaccess_checker_asyn();
			CO.control_goldenref();   CO.control_checker_asyn();

			//Sample coverage points
			ALU.sample();
			MEMO.sample();
			CTRL.sample();
			SEQ.sample();
				
			@(posedge LC3Interface.clock);
			#1;
				//sync checker
				FE.fetch_checker_syn();
				DE.decode_checker_syn();
				EX.execute_checker_syn();
				WB.writeback_checker_syn();
				CO.control_checker_syn();	
		end

		$display("Final Statistics:");
		$display("ADD: %d", LC3Interface.addc);
		$display("AND: %d", LC3Interface.andc);
		$display("NOT: %d", LC3Interface.notc);
		$display("LEA: %d", LC3Interface.leac);

		$display("LD: %d", LC3Interface.ldc);
		$display("LDR: %d", LC3Interface.ldrc);
		$display("LDI: %d", LC3Interface.ldic);
		$display("ST: %d", LC3Interface.stc);
		$display("STR: %d", LC3Interface.strc);
		$display("STI: %d", LC3Interface.stic);

		$display("JMP: %d", LC3Interface.jmpc);
		$display("BR: %d", LC3Interface.brc);

		$display("Total ALU ops: %d", LC3Interface.addc + LC3Interface.andc + LC3Interface.notc + LC3Interface.notc + LC3Interface.leac);
		$display("Total memory ops: %d", LC3Interface.ldc + LC3Interface.ldrc + LC3Interface.ldic + LC3Interface.stc + LC3Interface.strc + LC3Interface.stic);
		$display("Total control ops: %d", LC3Interface.jmpc + LC3Interface.brc);
		#100;
		$finish;
	end

endprogram : LC3_Test

module Top();

	parameter simulation_cycle = 10;
	reg  SysClock;
	
	initial
	begin
		SysClock = 0;
		forever 
		begin
			#(simulation_cycle/2) SysClock = ~SysClock;
		end
	end

	topInterface LC3Interface(SysClock);  // Instantiate the top level interface of the testbench to be used for driving the LC3 and reading the LC3 outputs.

	// Instatiating the top-level DUT.
	LC3 DUT(
		.clock(LC3Interface.clock), 
		.reset(LC3Interface.reset), 
		.pc(LC3Interface.pc), 
		.instrmem_rd(LC3Interface.instrmem_rd), 
		.Instr_dout(LC3Interface.Instr_dout), 
		.Data_addr(LC3Interface.Data_addr), 
		.complete_instr(LC3Interface.complete_instr), 
		.complete_data(LC3Interface.complete_data),
		.Data_din(LC3Interface.Data_din),
		.Data_dout(LC3Interface.Data_dout),
		.Data_rd(LC3Interface.Data_rd)
		);
	
	// Instantiating and Connecting the probe signals for the Fetch block with the DUT fetch block signals using the "dut" instantation of LC3 below.
	fetchInterface fetch_Interface (
					.clock(DUT.Fetch.clock),
					.reset(DUT.Fetch.reset),	
					.enable_updatePC(DUT.Fetch.enable_updatePC), 
					.enable_fetch(DUT.Fetch.enable_fetch), 
					.pc(DUT.Fetch.pc), 
					.npc_out(DUT.Fetch.npc_out),
					.instrmem_rd(DUT.Fetch.instrmem_rd),
					.taddr(DUT.Fetch.taddr),
					.br_taken(DUT.Fetch.br_taken)
				);

	decodeInterface decode_Interface (
					.clock(LC3Interface.clock),
					.reset(LC3Interface.reset),
					.npc_in(DUT.Dec.npc_in),
					.enable_decode(DUT.Dec.enable_decode),
					.dout(DUT.Dec.dout),
					/*.psr(DUT.Dec.psr),*/
					.IR(DUT.Dec.IR),
					.E_Control(DUT.Dec.E_Control),
					.npc_out(DUT.Dec.npc_out),
					.Mem_Control(DUT.Dec.Mem_Control),
					.W_Control(DUT.Dec.W_Control)
					);
					
	controlInterface control_Interface (
					.clock(LC3Interface.clock),
					.reset(LC3Interface.reset),
					.complete_data(DUT.Ctrl.complete_data),
					.complete_instr(DUT.Ctrl.complete_instr),
					.br_taken(DUT.Ctrl.br_taken),
					.IR(DUT.Ctrl.IR),
					.IR_Exec(DUT.Ctrl.IR_Exec),
					.Instr_dout(DUT.Ctrl.Instr_dout),
					.psr(DUT.Ctrl.psr),
					.NZP(DUT.Ctrl.NZP),
					.bypass_alu_1(DUT.Ctrl.bypass_alu_1),
					.bypass_alu_2(DUT.Ctrl.bypass_alu_2),
					.bypass_mem_1(DUT.Ctrl.bypass_mem_1),
					.bypass_mem_2(DUT.Ctrl.bypass_mem_2),
					.enable_fetch(DUT.Ctrl.enable_fetch),
					.enable_decode(DUT.Ctrl.enable_decode),
					.enable_execute(DUT.Ctrl.enable_execute),
					.enable_writeback(DUT.Ctrl.enable_writeback),
					.enable_updatePC(DUT.Ctrl.enable_updatePC),
					.mem_state(DUT.Ctrl.mem_state)
					);
					
	executeInterface execute_Interface (
					.clock(LC3Interface.clock),
					.reset(LC3Interface.reset),
					.E_Control(DUT.Ex.E_Control),
					.bypass_alu_1(DUT.Ex.bypass_alu_1),
					.bypass_alu_2(DUT.Ex.bypass_alu_2),
					.IR(DUT.Ex.IR),
					.npc(DUT.Ex.npc),
					.W_Control_in(DUT.Ex.W_Control_in),
					.Mem_Control_in(DUT.Ex.Mem_Control_in),
					.VSR1(DUT.Ex.VSR1),
					.VSR2(DUT.Ex.VSR2),
					.bypass_mem_1(DUT.Ex.bypass_mem_1),
					.bypass_mem_2(DUT.Ex.bypass_mem_2),
					.Mem_Bypass_Val(DUT.Ex.Mem_Bypass_Val),
					.enable_execute(DUT.Ex.enable_execute),
					.W_Control_out(DUT.Ex.W_Control_out),
					.Mem_Control_out(DUT.Ex.Mem_Control_out),
					.aluout(DUT.Ex.aluout),
					.pcout(DUT.Ex.pcout),
					.sr1(DUT.Ex.sr1),
					.sr2(DUT.Ex.sr2),
					.dr(DUT.Ex.dr),
					.M_Data(DUT.Ex.M_Data),
					.NZP(DUT.Ex.NZP),
					.IR_Exec(DUT.Ex.IR_Exec)			
				);

	writebackInterface writeback_Interface (
					.clock(LC3Interface.clock),
					.reset(LC3Interface.reset),
					.enable_writeback(DUT.WB.enable_writeback),
					.aluout(DUT.WB.aluout),
					.memout(DUT.WB.memout),
					.pcout(DUT.WB.pcout),
					.npc(DUT.WB.npc),
					.d1(DUT.WB.d1),
					.d2(DUT.WB.d2),
					.sr1(DUT.WB.sr1),
					.sr2(DUT.WB.sr2),
					.dr(DUT.WB.dr),
					.psr(DUT.WB.psr),
					.W_Control(DUT.WB.W_Control)					
		);

	memaccessInterface memaccess_Interface (
				.mem_state(DUT.MemAccess.mem_state),
				.M_Control(DUT.MemAccess.M_Control),
				.Data_rd(DUT.MemAccess.Data_rd),
				.M_Data(DUT.MemAccess.M_Data),
				.M_Addr(DUT.MemAccess.M_Addr),
				.Data_dout(DUT.MemAccess.Data_dout),
				.Data_addr(DUT.MemAccess.Data_addr),
				.Data_din(DUT.MemAccess.Data_din),
				.memout(DUT.MemAccess.memout)
		);

	// Passing the top level interface and probe interface to the program block.
	LC3_Test TB(LC3Interface,fetch_Interface, decode_Interface, execute_Interface, writeback_Interface, memaccess_Interface, control_Interface); 

endmodule : Top

/*class Environment;
	
	function build;
		//Instantiate LC3 stage classes.	
		fetch FE = new(fetch_Interface);
		decode DE = new(decode_Interface);
		controller CO = new(control_Interface);
		execute EX = new(execute_Interface);
		writeback WB = new(writeback_Interface);
		memaccess MEM = new(memaccess_Interface);	

		mailbox mb = new();
		generator gen = new(mb,LC3Interface);
		driver drv = new(mb,LC3Interface);
	endfunction : build		

endclass : Environment*/

