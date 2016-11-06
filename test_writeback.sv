//`timescale 10 ns / 1 ps

class writeback;

virtual writebackInterface writeback_Interface;

//RegFile
logic [15:0] RegFile [0:7];

function new (virtual writebackInterface w);
	writeback_Interface = w;
endfunction

task writeback_goldenref();

writeback_Interface.check_VSR1 = RegFile[writeback_Interface.sr1];

//VSR2
//Note: VSR2 is read only for instrs. which have a second source operand.
writeback_Interface.check_VSR2 = RegFile[writeback_Interface.sr2];
	
//Writeback RegFile updation
if (writeback_Interface.enable_writeback == 1)
	begin	
	if ( writeback_Interface.W_Control == 2'b00 )
		RegFile[writeback_Interface.dr] = writeback_Interface.aluout;
	else if ( writeback_Interface.W_Control == 2'b01 )
		RegFile[writeback_Interface.dr] = writeback_Interface.memout;
	else if ( writeback_Interface.W_Control == 2'b10 )
		RegFile[writeback_Interface.dr] = writeback_Interface.pcout;

	//VSR1
		
	//PSR Update //	
	if ( writeback_Interface.W_Control == 2'b00 )
	begin
		if ( writeback_Interface.aluout[15] == 1 )
			writeback_Interface.check_psr = 3'b100;
		else if ( (writeback_Interface.aluout[15]== 0) && (|writeback_Interface.aluout[15:0]==1))
			writeback_Interface.check_psr = 3'b001;
	 
		//else if ( writeback_Interface.aluout[15] == 0 )
		else
			writeback_Interface.check_psr = 3'b010;
	end

	else if ( writeback_Interface.W_Control == 2'b01 )
	begin	
		if ( writeback_Interface.memout[15] == 1 )
			writeback_Interface.check_psr = 3'b100;
		else if ( (writeback_Interface.memout[15]== 0) && (|writeback_Interface.memout[15:0]==1))
			writeback_Interface.check_psr = 3'b001;
	 
		//else if ( writeback_Interface.aluout[15] == 0 )
		else
			writeback_Interface.check_psr = 3'b010;
	end

	else if ( writeback_Interface.W_Control == 2'b10 )
	begin
		if ( writeback_Interface.pcout[15] == 1 )
			writeback_Interface.check_psr = 3'b100;
		else if ( (writeback_Interface.pcout[15]== 0) && (|writeback_Interface.pcout[15:0]==1))
			writeback_Interface.check_psr = 3'b001;
	 
		//else if ( writeback_Interface.aluout[15] == 0 )
		else
			writeback_Interface.check_psr = 3'b010;
	end // if ( writeback_Interface.W_Control == 2'b10 )
		   
		
	end // if (writeback_Interface.enable_writeback == 1)
	
if ( writeback_Interface.reset)
begin
	writeback_Interface.check_psr = 3'b0;
end
   
   
endtask : writeback_goldenref

task writeback_checker_syn();

`ifdef WRITEBACK_DEBUG

	if(writeback_Interface.psr != writeback_Interface.check_psr)
		$display($time," Error in Writeback stage psr!");
	// else
	// 	$display($time, " PASS in Writeback stage psr!");
`endif

endtask : writeback_checker_syn


task writeback_checker_asyn();

`ifdef WRITEBACK_DEBUG

	if(writeback_Interface.d1 != writeback_Interface.check_VSR1)
		$display($time, " Error in Writeback stage VSR1!");
	// else
	// 	$display($time, " PASS in Writeback VSR1!");

	if(writeback_Interface.d2 != writeback_Interface.check_VSR2)
		$display($time," Error in Writeback stage VSR2!");
	// else
	// 	$display($time, " PASS in Writeback stage VSR2!");
	
`endif

endtask : writeback_checker_asyn

endclass

