`include "structs.sv"

class generator;

	//rand 
	Instruction instr;
	LC3_input ip;
	mailbox mbx;
	
	//instr.sr1 = 0;
	//instr.dr = 0;

	function new (mailbox m);
		mbx = m;
	endfunction : new

	task run;
	repeat(10)
	begin
		generateInstr();
		ip.instr = this.instr;
		ip.Data_dout =  $urandom_range(0, 65536);
		ip.complete_instr = 1;
		ip.complete_data = 1;
		mbx.put(ip);
	end
	endtask : run

	//Write constraints here.
	/*constraint opcode { 
		instr.opcode inside {ADD, AND, NOT, LEA, LD, LDR, LDI, ST, STR, STI, BR, JMP};
	}*/
		
		
	task generateInstr;
	 	instr.opcode = 4'b0101;
		instr.imm5 = 5'b0;
		instr.mode = 1'b1;
		//instr.opcode = ;
		
		instr.dr = instr.dr + 1;
		instr.sr1 = instr.sr1 + 1;
		
	endtask : generateInstr
	
endclass : generator
