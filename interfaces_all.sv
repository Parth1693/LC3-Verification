// `timescale 10 ns / 1 ps

interface fetchInterface (input logic clock, input logic reset, input logic enable_updatePC, input logic enable_fetch, input logic br_taken, input logic instrmem_rd,
						  input logic [15:0] taddr, input logic [15:0] pc, input logic [15:0] npc_out);
	logic check_instrmem_rd;
	logic [15:0] check_pc, check_npc;
				
endinterface

interface decodeInterface (input logic clock, input logic reset, input logic [15:0] npc_in , input logic enable_decode, 
						input logic [15:0] dout, /*input logic [2:0] psr,*/ input logic [15:0] IR, input logic [5:0] E_Control, 
						input logic [15:0] npc_out , input logic Mem_Control, input logic [1:0] W_Control );
	
	logic [15:0] check_IR;
	logic [5:0] check_E_Control;
	logic [1:0] check_W_Control;
	logic check_Mem_Control;
	logic [15:0] check_npc_out;
	
endinterface : decodeInterface

interface executeInterface (input logic clock, input logic reset, input logic [5:0] E_Control, input logic bypass_alu_1,
						input logic bypass_alu_2, input logic [15:0] IR, input logic [15:0] npc, input logic [1:0] W_Control_in, input logic Mem_Control_in,
						input logic [15:0] VSR1, input logic [15:0] VSR2, input logic bypass_mem_1, input logic bypass_mem_2, input logic [15:0] Mem_Bypass_Val,
						input logic enable_execute, input logic [1:0] W_Control_out, input logic Mem_Control_out, input logic [15:0] aluout, input logic [15:0] pcout,
						input logic [2:0] sr1, input logic [2:0] sr2, input logic [2:0] dr, input logic [15:0] M_Data, input logic [2:0] NZP, input logic [15:0] IR_Exec);

	logic [15:0] check_aluout;
	logic [1:0] check_W_Control_out;
	logic check_Mem_Control_out;
	logic [15:0] check_M_Data;
	logic [2:0] check_dr;
	logic [2:0] check_sr1;
	logic [2:0] check_sr2;
	logic [2:0] check_NZP;
	logic [15:0] check_IR_Exec;
	logic [15:0] check_pcout;

endinterface : executeInterface

interface writebackInterface (input logic clock, reset, enable_writeback, 
					input logic [15:0] aluout, memout, pcout, npc, d1, d2,
					input logic [2:0] sr1, sr2, dr, psr,
					input logic [1:0] W_Control);
			
	logic [15:0] check_VSR1;
	logic [15:0] check_VSR2;
	logic [2:0] check_psr;			
				
endinterface : writebackInterface

interface memaccessInterface(input logic [1:0] mem_state, 
							input logic M_Control, Data_rd ,
							input logic [15:0] M_Data, M_Addr, Data_dout, Data_addr, Data_din, memout );
	
	logic [15:0] check_data_addr, check_data_din, check_memout;
	logic check_data_rd;
	
endinterface : memaccessInterface

interface controlInterface(input logic clock, reset, complete_data, complete_instr, br_taken, 
							input logic [15:0] IR, IR_Exec, Instr_dout,
							input logic [2:0] psr, NZP, 
							input logic bypass_alu_1, bypass_alu_2, bypass_mem_1, bypass_mem_2, enable_fetch, enable_decode, enable_execute, enable_writeback, enable_updatePC,
							input logic [1:0] mem_state);
							
				logic check_bypass_alu_1, check_bypass_alu_2, check_bypass_mem_1, check_bypass_mem_2;
				logic check_enable_fetch, check_enable_decode, check_enable_execute, check_enable_writeback, check_enable_updatePC;
				logic check_br_taken;
				logic [1:0] check_mem_state;
				logic [3:0] next_state;

endinterface : controlInterface

interface topInterface(input bit clock);
  	
	logic reset, instrmem_rd, complete_instr, complete_data, Data_rd; 
	logic [15:0] pc, Instr_dout, Data_addr,  Data_dout, Data_din;

	int addc, andc, notc, ldc, ldrc, ldic, leac, stc, strc, stic, jmpc, brc;  	

  	clocking cb@(posedge clock);
 	default input #1 output #0;

		//Instruction memory side
		input	pc; 
   		input	instrmem_rd;  
   		output  Instr_dout;

		//Data memory side
		input Data_din;
		input Data_rd;
		input Data_addr;		
		output Data_dout;
		
  	endclocking : cb

  	modport TB(clocking cb, output reset, output complete_data, output complete_instr);
  	
endinterface : topInterface
