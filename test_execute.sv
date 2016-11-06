//`timescale 10 ns / 1 ps
`include "debug.sv"

class execute;
	
	virtual executeInterface execute_Interface;

function new (virtual executeInterface e);
	execute_Interface = e;
endfunction : new

//ALU Inputs
logic [15:0] ALU1;
logic [15:0] ALU2;

//Extensions
logic [15:0] imm5;
logic [15:0] offset6;
logic [15:0] offset9;
logic [15:0] offset11;

//MUX select inputs
logic [1:0] pcselect1;
logic [1:0] alu_control;
logic [15:0] pcselect1_out;
logic [15:0] pcselect2_out;
logic pcselect2;
logic op2select;
logic [15:0] op2select_out;


task execute_goldenref();

imm5 =  { {11{execute_Interface.IR[4]}} , execute_Interface.IR[4:0]};
offset6 = { {10{execute_Interface.IR[5]}} , execute_Interface.IR[5:0]};
offset9 = { {7{execute_Interface.IR[8]}} , execute_Interface.IR[8:0]};
offset11 = { {5{execute_Interface.IR[10]}} , execute_Interface.IR[10:0]};

pcselect1 = execute_Interface.E_Control[3:2];
alu_control = execute_Interface.E_Control[5:4];
pcselect2 = execute_Interface.E_Control[1];
op2select = execute_Interface.E_Control[0];

case(pcselect1)
3: pcselect1_out = 0;
2: pcselect1_out = offset6;
1: pcselect1_out = offset9;
0: pcselect1_out = offset11;
endcase

case(pcselect2)
1: pcselect2_out = execute_Interface.npc;
0: pcselect2_out = execute_Interface.VSR1;
endcase

case(op2select)
1: op2select_out = execute_Interface.VSR2;
0: op2select_out = imm5;
endcase

if (execute_Interface.reset == 1)
begin
	execute_Interface.check_aluout = 0; execute_Interface.check_pcout = 0; execute_Interface.check_dr = 0; execute_Interface.check_sr1 = 0; execute_Interface.check_sr2 = 0;
	execute_Interface.check_NZP = 0; execute_Interface.check_M_Data = 0; execute_Interface.check_IR_Exec = 0; execute_Interface.check_Mem_Control_out = 0; execute_Interface.check_W_Control_out = 0;
end

else if (execute_Interface.reset != 1)
begin

//sr1
	execute_Interface.check_sr1 = execute_Interface.IR[8:6];

//sr2
execute_Interface.check_sr2 = 3'b0;
//For ALU instructions.
if ( execute_Interface.IR[15:12] == AND || execute_Interface.IR[15:12] == ADD || execute_Interface.IR[15:12] == NOT )
	execute_Interface.check_sr2 = execute_Interface.IR[2:0];
//For stores.
else if ( execute_Interface.IR[15:12] == ST || execute_Interface.IR[15:12] == STR || execute_Interface.IR[15:12] == STI)
	execute_Interface.check_sr2 = execute_Interface.IR[11:9];
end

if ( !execute_Interface.reset && execute_Interface.enable_execute == 1 )
begin

//W_Control_out
execute_Interface.check_W_Control_out = execute_Interface.W_Control_in;
//Mem_Control_out
execute_Interface.check_Mem_Control_out = execute_Interface.Mem_Control_in;

//aluout : Check for bypass conditions from ALU and memory.
//1. ADD

ALU1 = execute_Interface.VSR1;

//Two conditions for VSR2
if (execute_Interface.IR[5] == MODE0)
	ALU2 = execute_Interface.VSR2;
else
	ALU2 = imm5;

if (execute_Interface.bypass_mem_1 == 1)
	ALU1 = execute_Interface.Mem_Bypass_Val;
if (execute_Interface.bypass_mem_2 == 1)
	ALU2 = execute_Interface.Mem_Bypass_Val;	

if (execute_Interface.bypass_alu_1 == 1)
	ALU1 = execute_Interface.aluout;	
if (execute_Interface.bypass_alu_2 == 1)
	ALU2 = execute_Interface.aluout; 							

//ALU ops
if (execute_Interface.IR[15:12] == AND || execute_Interface.IR[15:12] == ADD || execute_Interface.IR[15:12] == NOT)
	begin

	// computing Aluout based on the values of AlU1, AlU2 and E_control[5:4]
	if (execute_Interface.E_Control[5:4] == 2'b00)
		execute_Interface.check_aluout = ALU1 + ALU2;
	else if (execute_Interface.E_Control[5:4] == 2'b01)
		execute_Interface.check_aluout = ALU1 & ALU2;
	else if (execute_Interface.E_Control[5:4] == 2'b10)
		execute_Interface.check_aluout = ~ALU1;

	execute_Interface.check_pcout = execute_Interface.check_aluout;

	end

if ( execute_Interface.IR[15:12] == LD || execute_Interface.IR[15:12] == LDR || execute_Interface.IR[15:12] == LDI || execute_Interface.IR[15:12] == JMP || 
execute_Interface.IR[15:12] == ST || execute_Interface.IR[15:12] == STR || execute_Interface.IR[15:12] == STI || execute_Interface.IR[15:12] == BR || execute_Interface.IR[15:12] == LEA)
begin

	//check_pcout

	if (execute_Interface.E_Control[3:1] == 3'b000)

		execute_Interface.check_pcout = ALU1 + offset11;    

	if (execute_Interface.E_Control[3:1] == 3'b001)

		execute_Interface.check_pcout = execute_Interface.npc + offset11;

	if (execute_Interface.E_Control[3:1] == 3'b010)

		execute_Interface.check_pcout = ALU1 + offset9;

	if (execute_Interface.E_Control[3:1] == 3'b011)

		execute_Interface.check_pcout = execute_Interface.npc + offset9;

	if (execute_Interface.E_Control[3:1] == 3'b100)

		execute_Interface.check_pcout = ALU1 + offset6;

	if (execute_Interface.E_Control[3:1] == 3'b101)

		execute_Interface.check_pcout = execute_Interface.npc + offset6;

	if (execute_Interface.E_Control[3:1] == 3'b110)

		execute_Interface.check_pcout = ALU1;

	if (execute_Interface.E_Control[3:1] == 3'b111)

		execute_Interface.check_pcout = execute_Interface.npc;

	if ( execute_Interface.IR[15:12] == LD || execute_Interface.IR[15:12] == LEA || execute_Interface.IR[15:12] == ST || execute_Interface.IR[15:12] == STI || 
	execute_Interface.IR[15:12] == BR  || execute_Interface.IR[15:12] == LDI ) 	
		execute_Interface.check_pcout = execute_Interface.check_pcout - 1;

		execute_Interface.check_aluout = execute_Interface.check_pcout;
end

//dr
execute_Interface.check_dr = 3'b0;
if ( execute_Interface.IR[15:12] == AND || execute_Interface.IR[15:12] == ADD || execute_Interface.IR[15:12] == NOT ||
  execute_Interface.IR[15:12] == LD || execute_Interface.IR[15:12] == LDI || execute_Interface.IR[15:12] == LDR || execute_Interface.IR[15:12] == LEA )
	execute_Interface.check_dr = execute_Interface.IR[11:9];

//M_Data

execute_Interface.check_M_Data = execute_Interface.VSR2;
if (execute_Interface.bypass_alu_2 == 1)
begin
	execute_Interface.check_M_Data = ALU2;		
end

//IR_Exec
	execute_Interface.check_IR_Exec = execute_Interface.IR;

//NZP
execute_Interface.check_NZP = 3'b000;
if (execute_Interface.IR[15:12] == BR)
	execute_Interface.check_NZP = execute_Interface.IR[11:9];
else if (execute_Interface.IR[15:12] == JMP)
	execute_Interface.check_NZP = 3'b111;

end
else if (!execute_Interface.reset && execute_Interface.enable_execute != 1)
	execute_Interface.check_NZP = 3'b000;

endtask : execute_goldenref

task execute_checker_syn();

`ifdef EXECUTE_DEBUG
	if (execute_Interface.W_Control_out != execute_Interface.check_W_Control_out)
		$display($time, " Error in Execute stage W_Control!");
	// else
	// 	$display($time, " PASS in Execute stage W_Control!");

	if (execute_Interface.Mem_Control_out != execute_Interface.check_Mem_Control_out)
		$display($time, " Error in Execute stage Mem_Control!");
	// else
	// 	$display($time, " PASS in Execute stage Mem_Control_out!");

	if (execute_Interface.aluout != execute_Interface.check_aluout)
		$display($time, " Error in Execute stage aluout!");
	// else
	// 	$display($time, " PASS in Execute stage aluout!");

	if (execute_Interface.M_Data != execute_Interface.check_M_Data)
		$display($time, " Error in Execute stage M_Data!");
	// else
	// 	$display($time, " PASS in Execute M_Data!");

	if (execute_Interface.dr != execute_Interface.check_dr)
		$display($time, " Error in Execute stage dr!");
	// else
	// 	$display($time, " PASS in Execute stage dr!");

	if (execute_Interface.NZP != execute_Interface.check_NZP)
		$display($time, " Error in Execute stage NZP!");
	// else
	// 	$display($time, " PASS in Execute stage NZP!");

	if (execute_Interface.IR_Exec != execute_Interface.check_IR_Exec)
		$display($time, " Error in Execute stage IR_Exec!");
	// else
	// 	$display($time, " PASS in Execute stage IR_Exec!");

	if (execute_Interface.pcout != execute_Interface.check_pcout)
		$display($time, " Error in Execute stage pcout!");
	// else
	// 	$display($time, " PASS in Execute stage pcout!");

     if (execute_Interface.reset == 1 )
     begin
	if (execute_Interface.sr1 != execute_Interface.check_sr1)
		$display($time, " Error in Execute stage sr1!");
	// else
	// 	$display($time, " PASS in Execute stage sr1!");

	if (execute_Interface.sr2 != execute_Interface.check_sr2)
		$display($time, " Error in Execute stage sr2!");
	// else
	// 	$display($time, " PASS in Execute stage sr2!");
    end
`endif
	
endtask : execute_checker_syn

task execute_checker_asyn();

`ifdef EXECUTE_DEBUG
     if (execute_Interface.reset != 1 )
     begin
	if (execute_Interface.sr1 != execute_Interface.check_sr1)
		$display($time, " Error in Execute stage sr1!");
	// else
	// 	$display($time, " PASS in Execute stage sr1!");

	if (execute_Interface.sr2 != execute_Interface.check_sr2)
		$display($time, " Error in Execute stage sr2!");
	// else
	// 	$display($time, " PASS in Execute stage sr2!");
     end
`endif

endtask : execute_checker_asyn


endclass : execute
