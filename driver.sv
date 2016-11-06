//Driver module
`include "structs.sv"
`include "interfaces_all.sv"

// To cover different memory instrucitons

covergroup MEM_OPR(ref Instruction inst);
	
	//Cover all mem operations
	Cov_mem_opcode : coverpoint inst.instruction_all[15:12]	
	{
		bins LD = {LD};	
		bins LDR = {LDR};	
		bins LDI = {LDI};	
		bins LEA = {LEA};	
		bins ST = {ST};	
		bins STR = {STR};	
		bins STI = {STI};	
	}
	
	//Cover base registers for LDR and STR
	Cov_BaseR : coverpoint inst.instruction_all[8:6] iff(inst.instruction_all[15:12] == LDR || inst.instruction_all[15:12] == STR);
	
	//Cover base registers for ST, STR and STI
	Cov_SR :coverpoint inst.instruction_all[11:9] iff(inst.instruction_all[15:12] == ST || inst.instruction_all[15:12] == STR || inst.instruction_all[15:12] == STI);
	
	//Cover dest registers for LD, LDR, LDI and LEA
	Cov_DR : coverpoint inst.instruction_all[11:9] iff(inst.instruction_all[15:12] == LD || inst.instruction_all[15:12] == LDR || inst.instruction_all[15:12] == LDR || inst.instruction_all[15:12] == LEA);

	//Cover for different PCoffset9 values
	Cov_PCoffset9 : coverpoint inst.instruction_all[8:0]  iff(inst.instruction_all[15:12] == LD || inst.instruction_all[15:12] == LDI || inst.instruction_all[15:12] == LEA ||inst.instruction_all[15:12] == ST || inst.instruction_all[15:12] == STI)
	{
		option.auto_bin_max=8;		
	}	

	// To cover corner cases for PCoffset9 
	Cov_PCoffset9_c : coverpoint inst.instruction_all[8:0]  iff(inst.instruction_all[15:12] == LD || inst.instruction_all[15:12] == LDI || inst.instruction_all[15:12] == LEA || inst.instruction_all[15:12] == ST || inst.instruction_all[15:12] == STI)	
	{
		bins allzeros = {9'b0};
		bins allones =	{9'b111111111};
		bins alt0 = 	{9'b010101010};
		bins alt1 =	{9'b101010101};	
	}
	
	//Cover for different PCoffset6 values
	Cov_PCoffset6 : coverpoint inst.instruction_all[5:0]  iff(inst.instruction_all[15:12] == LDR || inst.instruction_all[15:12] == STR)
	{
		option.auto_bin_max=8;		
	}	

	// To cover corner cases for PCoffset9 
	Cov_PCoffset6_c : coverpoint inst.instruction_all[5:0]  iff(inst.instruction_all[15:12] == LDR || inst.instruction_all[15:12] == STR)
	{
		bins allzeros = {6'b0};
		bins allones ={6'b111111};
		bins alt0 = {6'b010101};
		bins alt1 ={6'b101010};
	}	

	// To cross cover for PCoffset6 values with SR and BaseR vales for LDR operations
	Xc_BaseR_SR_offset6 : cross Cov_PCoffset6, Cov_SR, Cov_BaseR iff(inst.instruction_all[15:12] == STR);

	// To cross cover for PCoffset6 values with DR and BaseR vales for STR operations
	Xc_BaseR_DR_offset6 : cross Cov_PCoffset6, Cov_DR, Cov_BaseR iff(inst.instruction_all[15:12] == LDR);	

endgroup

// To cover all possible sequence combination of different types of instructions - ALU, CTRL and MEM
covergroup OPR_SEQ(ref Instruction inst);

	// To cover different sequences of instructions.
	Cov_ALU : coverpoint inst.instruction_all [15:12]
	{	
		bins ALU_ALU = (ADD , AND, NOT, LEA => ADD , AND, NOT, LEA);
		bins ALU_MEM = (ADD , AND, NOT, LEA=> LD, LDR , LDI, ST, STR, STI);
		bins ALU_CTRL = (ADD, AND, NOT, LEA => BR, JMP);
	}

	// To cover MEM to ALU instruction transitions
	// +Parth : Consider LEA as an ALU operation.
	Cov_MEM : coverpoint inst.instruction_all[15:12]
	{
		bins MEM_ALU = (LD, LDR , LDI, LEA, ST, STR, STI => ADD , AND, NOT, LEA);
	}

	// To cover CNTRL to ALU instruction transitions
	// +Parth : Consider LEA as an ALU operation.
	Cov_CTRL : coverpoint inst.instruction_all[15:12]
	{
	
		bins CTRL_ALU = ( BR, JMP => ADD , AND, NOT, LEA);			
	}

endgroup


class generator;

	//rand 
	Instruction instr;
	LC3_input ip;
	mailbox mbx;
	virtual topInterface ti;
	int count;
	int counter;
	int flag;
	int r;
	logic [2:0] sr1;
	logic [2:0] sr2;
	logic [2:0] dr;
	logic [4:0] imm5;
	logic [8:0] pcoffset9;

	function new (mailbox m, virtual topInterface t);
		ti = t;
		mbx = m;
		count = 0;
		counter = 0;
		flag = 0;
		this.instr = new();
		this.ip = new();
	endfunction : new

	task run;
	begin
		
		count = count + 1;
		if(count <= 8)
		begin
			//$display($time, "Generate instr call!");
			generateInstr();
		end
		//Directed test cases
// AND coverage
		// 1. ALU input = 0000
		else if (count == 9)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'h0000;	//All zeros in SR1 = 1;
		end
		else if (count > 9 && count < 16)
		begin
			this.ip.instr.instruction_all = 16'h5000;
			this.ip.Data_dout = 16'h0000;
		end
		else if (count == 16 )
		begin
			this.ip.instr.instruction_all = 16'h2400;
			this.ip.Data_dout = 16'h0000;	//All zeros in SR2 = 2;
		end
		else if (count > 16 && count < 23)
		begin
			this.ip.instr.instruction_all = 16'h5042;  //AND with SR1 = 1 & SR2 = 2;
			this.ip.Data_dout = 16'h0000;
		end

		// 2. ALU input = FFFF
		else if (count == 23)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'hFFFF;	//All ones in SR1 = 1;
		end
		else if (count > 23 && count < 30)
		begin
			this.ip.instr.instruction_all = 16'h5000;
			this.ip.Data_dout = 16'hFFFF;
		end
		else if (count == 30 )
		begin
			this.ip.instr.instruction_all = 16'h2400;
			this.ip.Data_dout = 16'hFFFF;	//All ones in SR2 = 2;
		end
		else if (count > 30 && count < 37)
		begin
			this.ip.instr.instruction_all = 16'h5042;  //AND with SR1 = 1 & SR2 = 2;
			this.ip.Data_dout = 16'hFFFF;
		end

		// 3. ALU input = AAAA
		else if (count == 37)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'hAAAA;	//AAAA in SR1 = 1;
		end
		else if (count > 37 && count < 44)
		begin
			this.ip.instr.instruction_all = 16'h5000;
			this.ip.Data_dout = 16'hAAAA;
		end
		else if (count == 44 )
		begin
			this.ip.instr.instruction_all = 16'h2400;
			this.ip.Data_dout = 16'hAAAA;	//AAAA in SR2 = 2;
		end
		else if (count > 44 && count < 51)
		begin
			this.ip.instr.instruction_all = 16'h5042;  //AND with SR1 = 1 & SR2 = 2;
			this.ip.Data_dout = 16'hAAAA;
		end

		//4. ALU input = 5555
		else if (count == 51)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'h5555;	//5555 in SR1 = 1;
		end
		else if (count > 51 && count < 58)
		begin
			this.ip.instr.instruction_all = 16'h5000;
			this.ip.Data_dout = 16'h5555;
		end
		else if (count == 58 )
		begin
			this.ip.instr.instruction_all = 16'h2400;
			this.ip.Data_dout = 16'h5555;	//5555 in SR2 = 2;
		end
		else if (count > 58 && count < 65)
		begin
			this.ip.instr.instruction_all = 16'h5042;  //AND with SR1 = 1 & SR2 = 2;
			this.ip.Data_dout = 16'h5555;
		end
	
		//5. ALU1 = AAAA and ALU2 = 5555
		else if (count == 65)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'hAAAA;	//AAAA in SR1 = 1;
		end
		else if (count > 65 && count < 72)
		begin
			this.ip.instr.instruction_all = 16'h5000;
			this.ip.Data_dout = 16'hAAAA;
		end
		else if (count == 72 )
		begin
			this.ip.instr.instruction_all = 16'h2400;
			this.ip.Data_dout = 16'h5555;	//5555 in SR2 = 2;
		end
		else if (count > 72 && count < 79)
		begin
			this.ip.instr.instruction_all = 16'h5042;  //AND with SR1 = 1 & SR2 = 2;
			this.ip.Data_dout = 16'h5555;
		end

		//6. ALU1 = 5555 and ALU2 = AAAA
		else if (count == 79)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'h5555;	//5555 in SR1 = 1;
		end
		else if (count > 79 && count < 86)
		begin
			this.ip.instr.instruction_all = 16'h5000;
			this.ip.Data_dout = 16'h5555;
		end
		else if (count == 86 )
		begin
			this.ip.instr.instruction_all = 16'h2400;
			this.ip.Data_dout = 16'hAAAA;	//AAAA in SR2 = 2;
		end
		else if (count > 86 && count < 93)
		begin
			this.ip.instr.instruction_all = 16'h5042;  //AND with SR1 = 1 & SR2 = 2;
			this.ip.Data_dout = 16'hAAAA;
		end

// ADD coverage
		// 1. ALU input = 0000
		else if (count == 93)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'h0000;	//All zeros in SR1 = 1;
		end
		else if (count > 93 && count < 100)
		begin
			this.ip.instr.instruction_all = 16'h5000;
			this.ip.Data_dout = 16'h0000;
		end
		else if (count == 100 )
		begin
			this.ip.instr.instruction_all = 16'h2400;
			this.ip.Data_dout = 16'h0000;	//All zeros in SR2 = 2;
		end
		else if (count > 100 && count < 107)
		begin
			this.ip.instr.instruction_all = 16'h1A42;  //ADD with SR1 = 1 & SR2 = 2 & DR = 5;
			this.ip.Data_dout = 16'h0000;
		end

		// 2. ALU input = FFFF
		else if (count == 107)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'hFFFF;	//All ones in SR1 = 1;
		end
		else if (count > 107 && count < 114)
		begin
			this.ip.instr.instruction_all = 16'h5000;
			this.ip.Data_dout = 16'hFFFF;
		end
		else if (count == 114 )
		begin
			this.ip.instr.instruction_all = 16'h2400;
			this.ip.Data_dout = 16'hFFFF;	//All ones in SR2 = 2;
		end
		else if (count > 114 && count < 121)
		begin
			this.ip.instr.instruction_all = 16'h1A42;  //ADD with SR1 = 1 & SR2 = 2 & DR = 5;
			this.ip.Data_dout = 16'hFFFF;
		end

		// 3. ALU input = AAAA
		else if (count == 121)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'hAAAA;	//AAAA in SR1 = 1;
		end
		else if (count > 121 && count < 128)
		begin
			this.ip.instr.instruction_all = 16'h5000;
			this.ip.Data_dout = 16'hAAAA;
		end
		else if (count == 128 )
		begin
			this.ip.instr.instruction_all = 16'h2400;
			this.ip.Data_dout = 16'hAAAA;	//AAAA in SR2 = 2;
		end
		else if (count > 128 && count < 135)
		begin
			this.ip.instr.instruction_all = 16'h1A42;  //ADD with SR1 = 1 & SR2 = 2 & DR = 5;
			this.ip.Data_dout = 16'hAAAA;
		end

		//4. ALU input = 5555
		else if (count == 135)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'h5555;	//5555 in SR1 = 1;
		end
		else if (count > 135 && count < 142)
		begin
			this.ip.instr.instruction_all = 16'h5000;
			this.ip.Data_dout = 16'h5555;
		end
		else if (count == 142 )
		begin
			this.ip.instr.instruction_all = 16'h2400;
			this.ip.Data_dout = 16'h5555;	//5555 in SR2 = 2;
		end
		else if (count > 142 && count < 149)
		begin
			this.ip.instr.instruction_all = 16'h1A42;  //ADD with SR1 = 1 & SR2 = 2 & DR = 5;
			this.ip.Data_dout = 16'h5555;
		end
	
		//5. ALU1 = AAAA and ALU2 = 5555
		else if (count == 149)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'hAAAA;	//AAAA in SR1 = 1;
		end
		else if (count > 149 && count < 156)
		begin
			this.ip.instr.instruction_all = 16'h5000;
			this.ip.Data_dout = 16'hAAAA;
		end
		else if (count == 156)
		begin
			this.ip.instr.instruction_all = 16'h2400;
			this.ip.Data_dout = 16'h5555;	//5555 in SR2 = 2;
		end
		else if (count > 156 && count < 163)
		begin
			this.ip.instr.instruction_all = 16'h1A42;  //ADD with SR1 = 1 & SR2 = 2 & DR = 5;
			this.ip.Data_dout = 16'h5555;
		end

		//6. ALU1 = 5555 and ALU2 = AAAA
		else if (count == 163)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'h5555;	//5555 in SR1 = 1;
		end
		else if (count > 163 && count < 170)
		begin
			this.ip.instr.instruction_all = 16'h5000;
			this.ip.Data_dout = 16'h5555;
		end
		else if (count == 170 )
		begin
			this.ip.instr.instruction_all = 16'h2400;
			this.ip.Data_dout = 16'hAAAA;	//AAAA in SR2 = 2;
		end
		else if (count > 170 && count < 177)
		begin
			this.ip.instr.instruction_all = 16'h1A42;  //ADD with SR1 = 1 & SR2 = 2 & DR = 5;
			this.ip.Data_dout = 16'hAAAA;
		end

//NOT coverage
		// 1. ALU input = 0000
		else if (count == 177)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'h0000;	//All zeros in SR1 = 1;
		end
		else if (count > 177 && count < 184)
		begin
			this.ip.instr.instruction_all = 16'h9A7F; //NOT with DR = 5 & SR = 1;	
			this.ip.Data_dout = 16'h0000;
		end

		// 2. ALU input = FFFF
		else if (count == 184)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'hFFFF;	//All ones in SR1 = 1;
		end
		else if (count > 184 && count < 191)
		begin
			this.ip.instr.instruction_all = 16'h9A7F;  //NOT with DR = 5 & SR = 1;
			this.ip.Data_dout = 16'hFFFF;
		end

		// 3. ALU input = AAAA
		else if (count == 191)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'hAAAA;	//AAAA in SR1 = 1;
		end
		else if (count > 191 && count < 198)
		begin
			this.ip.instr.instruction_all = 16'h9A7F;  //NOT with DR = 5 & SR = 1;
			this.ip.Data_dout = 16'hAAAA;
		end

		//4. ALU input = 5555
		else if (count == 198)
		begin
			this.ip.instr.instruction_all = 16'h2200;
			this.ip.Data_dout = 16'h5555;	//5555 in SR1 = 1;
		end
		else if (count > 198 && count < 205)
		begin
			this.ip.instr.instruction_all = 16'h9A7F;  //NOT with DR = 5 & SR = 1;;
			this.ip.Data_dout = 16'h5555;
		end

		//Directed test cases end.

		else
			begin
			if(flag == 0)
				begin
				if(instr.randomize())
				begin
					if(instr.instruction_all[15:12]==LD ||instr.instruction_all[15:12]==LDR ||instr.instruction_all[15:12]==LDI ||instr.instruction_all[15:12]==ST ||instr.instruction_all[15:12]==STR || instr.instruction_all[15:12]==STI || instr.instruction_all[15:12]==BR ||instr.instruction_all[15:12]==JMP)
						begin
							counter = 6;
							flag = 1;
						end
				end
				end
			else						//flag = 1;
				begin
					counter = counter -1;
					//instr.instruction_all = 16'h5c00;
					
					r = $urandom_range(0, 5);
					sr1 = $urandom_range(0, 7);
					sr2 = $urandom_range(0, 7);
					dr = $urandom_range(0, 7);
					imm5 = $urandom_range(0, 31);
					pcoffset9 = $urandom_range(0, 511);
					
					case(r)
					0: instr.instruction_all = {4'h1,dr,sr1,1'b0,1'b0,1'b0,sr2};    	//AND 
					1: instr.instruction_all = {4'h1,dr,sr1,1'b1,imm5};			//AND with imm5
					2: instr.instruction_all = {4'h5,dr,sr1,1'b0,1'b0,1'b0,sr2};		//ADD
					3: instr.instruction_all = {4'h5,dr,sr1,1'b1,imm5};			//ADD with imm5
					4: instr.instruction_all = {4'h9,dr,sr1,{6{1'b1}}};		//NOT
					5: instr.instruction_all = {4'hE,dr,pcoffset9};			//LEA
					endcase
					
					if(counter == 0)
						flag = 0;
				end
		
			end
	if ( count <= 8 || count >=205 )
	begin
		this.ip.instr.instruction_all = this.instr.instruction_all;
		this.ip.Data_dout =  $urandom_range(0, 65536);
	end
		this.ip.complete_instr = 1;
		this.ip.complete_data = 1;

		mbx.put(ip);		
	end
	endtask : run


	task generateInstr;
	begin
	 	instr.instruction_all[15:12] = 4'b0101;
		this.instr.instruction_all[4:0] = 5'b0;   //imm5 for AND
		this.instr.instruction_all[5] = 1'b1;     //mode for AND     
	
		if(count == 1)
		begin 
			instr.instruction_all[11:9] = 0;   //dr for ALU
			instr.instruction_all[8:6] = 0;    // Sr1 for ALU
		end
		else
		begin
		instr.instruction_all[11:9] = instr.instruction_all[11:9] + 1;
		instr.instruction_all[8:6] = instr.instruction_all[8:6] + 1;
		end
	end
	endtask : generateInstr
	
endclass : generator


class driver;

	LC3_input ip;
	virtual topInterface LC3Interface;
	mailbox mbx;

	function new (mailbox m,virtual topInterface ti);
		begin
			mbx = m;
			LC3Interface = ti;
			this.ip = new();
		end
	endfunction : new

	task run;
	begin
		mbx.get(ip);

		case(ip.instr.instruction_all[15:12])
			ADD: LC3Interface.addc = LC3Interface.addc + 1;
			AND: LC3Interface.andc = LC3Interface.andc + 1;	
			NOT: LC3Interface.notc = LC3Interface.notc + 1;
			LEA: LC3Interface.leac = LC3Interface.leac + 1;
			LD: LC3Interface.ldc = LC3Interface.ldc + 1;
			LDI: LC3Interface.ldic = LC3Interface.ldic + 1;
			LDR: LC3Interface.ldrc = LC3Interface.ldrc + 1;
			ST: LC3Interface.stc = LC3Interface.stc + 1;
			STI: LC3Interface.stic = LC3Interface.stic + 1;
			STR: LC3Interface.strc = LC3Interface.strc + 1;
			JMP: LC3Interface.jmpc = LC3Interface.jmpc + 1;
			BR: LC3Interface.brc = LC3Interface.brc + 1;
		endcase

		LC3Interface.complete_data = ip.complete_data;
		LC3Interface.complete_instr = ip.complete_instr;
		LC3Interface.Data_dout = ip.Data_dout;

		LC3Interface.Instr_dout = ip.instr.instruction_all;
	end
	endtask : run

endclass : driver

