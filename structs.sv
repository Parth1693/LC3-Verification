
class Instruction;

	rand bit [15:0] instruction_all;
	
	function new();
		instruction_all = 16'b0;
	endfunction : new
	
	constraint c {
					instruction_all[15:12] dist {AND:=5, ADD:=5, NOT:=3, LEA:=2, LD:=3, LDR:=2, LDI:=2, ST:=3, STR:=2, STI:=2, JMP:=3, BR:=3};
					if ((instruction_all[5]==0) && (instruction_all[15:12]==ADD || instruction_all[15:12]==AND))
							instruction_all[4:3]==0;
					if(instruction_all[15:12] == NOT)
							instruction_all[5:0] ==6'b111111;
					if(instruction_all[15:12]== JMP)
						{
							instruction_all[11:9] == 7;
							instruction_all[5:0] == 0;
						}
					if(instruction_all[15:12] == BR)
						instruction_all[11:9] inside {1,2,4};
					}
					
endclass

class LC3_input;
 
	Instruction instr;
	bit [15:0] Data_dout;
	bit complete_instr;
	bit complete_data;
	bit reset;
		
	function new();
		this.instr = new();
		Data_dout = 16'b0;
		complete_data = 0;
		complete_instr = 0;
		reset = 0;
	endfunction : new

endclass
