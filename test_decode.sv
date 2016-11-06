// `timescale 10 ns / 1 ps
`include "interfaces_all.sv"

class decode;

	virtual decodeInterface decode_Interface;

function new (virtual decodeInterface d);
	decode_Interface = d;
endfunction : new

task decode_goldenref;
	logic [1:0] alu_control;
	logic [1:0] pcselect1;
	logic pcselect2;
	logic op2select;

	//E_Control
	alu_control = 2'b00;
	pcselect1 = 2'b00;
	pcselect2 = 1'b0;
	op2select = 1'b0;
	
begin
	if (decode_Interface.reset)
	begin
		decode_Interface.check_IR = 16'b0; decode_Interface.check_npc_out = 16'b0; decode_Interface.check_E_Control = 6'b0;
		decode_Interface.check_W_Control = 2'b0;	decode_Interface.check_Mem_Control = 1'b0;
	end

	else if ( decode_Interface.enable_decode == 1 )
	begin

	//IR
	decode_Interface.check_IR = decode_Interface.dout;

	//NPC
	decode_Interface.check_npc_out = decode_Interface.npc_in;

	//W_Control
	if ( decode_Interface.dout[15:12] == ADD || decode_Interface.dout[15:12] == AND || decode_Interface.dout[15:12] == NOT )
			decode_Interface.check_W_Control = 0;
	else if ( decode_Interface.dout[15:12] == BR || decode_Interface.dout[15:12] == JMP )
			decode_Interface.check_W_Control = 0;
	else if ( decode_Interface.dout[15:12] == ST ||  decode_Interface.dout[15:12] == STR ||  decode_Interface.dout[15:12] == STI )
			decode_Interface.check_W_Control = 0;
	else if ( decode_Interface.dout[15:12] == LD ||  decode_Interface.dout[15:12] == LDR ||  decode_Interface.dout[15:12] == LDI )
			decode_Interface.check_W_Control = 1;
	else if (  decode_Interface.dout[15:12] == LEA )
			decode_Interface.check_W_Control = 2;

	
	if( decode_Interface.dout[15:12] == ADD && decode_Interface.dout[5] == MODE0 )
		begin
			alu_control = 2'b0;
			op2select = 1'b1;
		end
	else if( decode_Interface.dout[15:12] == ADD && decode_Interface.dout[5] == MODE1 )
		begin
			alu_control = 2'b0;
			op2select = 1'b0;
		end
	else if( decode_Interface.dout[15:12] == AND && decode_Interface.dout[5] == MODE0 )
		begin
			alu_control = 2'b1;
			op2select = 1'b1;
		end
	else if( decode_Interface.dout[15:12] == AND && decode_Interface.dout[5] == MODE1 )
		begin
			alu_control = 2'b1;
			op2select = 1'b0;
		end
	else if( decode_Interface.dout[15:12] == NOT )
		begin
			alu_control = 2'h2; 
		end
	else if( decode_Interface.dout[15:12] == BR )
		begin
			pcselect1 = 2'b1;
			pcselect2 = 1'b1;
		end
	else if( decode_Interface.dout[15:12] == JMP )
		begin
			pcselect1 = 2'h3;
			pcselect2 = 1'b0;
		end
	else if( decode_Interface.dout[15:12] == LD )
		begin
			pcselect1 = 2'b1;
			pcselect2 = 1'b1;
		end
	else if( decode_Interface.dout[15:12] == LDR )
		begin
			pcselect1 = 2'h2;
			pcselect2 = 1'b0;
		end
	else if( decode_Interface.dout[15:12] == LDI )
		begin
			pcselect1 = 2'b1;
			pcselect2 = 1'b1;
		end
	else if( decode_Interface.dout[15:12] == LEA )
		begin
			pcselect1 = 2'b1;
			pcselect2 = 1'b1;
		end
	else if( decode_Interface.dout[15:12] == ST )
		begin
			pcselect1 = 2'b1;
			pcselect2 = 1'b1;
		end
	else if( decode_Interface.dout[15:12] == STR )
		begin
			pcselect1 = 2'h2;
			pcselect2 = 1'b0;
		end
	else if( decode_Interface.dout[15:12] == STI )
		begin
			pcselect1 = 2'b1;
			pcselect2 = 1'b1;
		end
	decode_Interface.check_E_Control = {alu_control, pcselect1, pcselect2, op2select};

	//Mem_Control
	decode_Interface.check_Mem_Control = 1'b0;

	if ( decode_Interface.dout[15:12] == LDI || decode_Interface.dout[15:12] == STI )
		decode_Interface.check_Mem_Control = 1'b1;
end
end
endtask : decode_goldenref

task decode_checker_syn();

`ifdef DECODE_DEBUG
	if (decode_Interface.IR != decode_Interface.check_IR)
		$display($time, " Error in Decode stage IR!");
	// else
	// 	$display($time, " PASS in Decode IR output !");

	if (decode_Interface.E_Control != decode_Interface.check_E_Control)
		$display($time, " Error in Decode stage E_Control!");
	// else
	// 	$display($time, " PASS in Decode stage E_Control!");

	if (decode_Interface.npc_out != decode_Interface.check_npc_out)
		$display($time, " Error in Decode stage npc_out!");
	// else
	// 	$display($time, " PASS in Decode stage npc_out!");

	if (decode_Interface.Mem_Control != decode_Interface.check_Mem_Control)
		$display($time, " Error in Decode stage Mem_Control!");
	// else
	// 	$display($time, " PASS in Decode stage Mem_Control!");
	
	if (decode_Interface.W_Control != decode_Interface.check_W_Control)
		$display($time, " Error in Decode stage W_Control!");
	// else
	// 	$display($time, " PASS in Decode stage W_Control!");

`endif
endtask : decode_checker_syn

endclass : decode

