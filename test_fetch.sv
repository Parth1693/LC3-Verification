// `timescale 10 ns / 1 ps 
 //`include "debug.sv"
//`include "interfaces_all.sv"

class fetch;

virtual fetchInterface fetch_Interface;

function new (virtual fetchInterface f);
begin
	fetch_Interface = f;
end
endfunction : new

task fetch_goldenref();
	
	if(fetch_Interface.enable_fetch==1)
		begin
			fetch_Interface.check_instrmem_rd = 1'b1;  		// updating instrmem_rd
		end
	else
			fetch_Interface.check_instrmem_rd = 1'b0;
	


	if(fetch_Interface.reset)					//condition for reset
		begin
		fetch_Interface.check_pc = 16'h3000;
		fetch_Interface.check_npc = 16'h3001;
		end
	if((!fetch_Interface.reset) && (fetch_Interface.enable_updatePC==1))		// condition for when enable_updatePC is 1
		begin
			if(fetch_Interface.br_taken ==1)
				begin
					fetch_Interface.check_pc = fetch_Interface.taddr;
				end
			else
				begin
					fetch_Interface.check_pc = fetch_Interface.check_pc + 16'b1;
				end
		end
	else if ((!fetch_Interface.reset) && (fetch_Interface.enable_updatePC==0))
		begin 
			fetch_Interface.check_pc = fetch_Interface.check_pc;						//pc stays the same when enable_updatePC = 0
		end

	fetch_Interface.check_npc = fetch_Interface.check_pc + 16'b1 ;					// updating npc

endtask
	
task fetch_checker_syn();

`ifdef FETCH_DEBUG

	if(fetch_Interface.check_npc != fetch_Interface.npc_out)
		$display($time," Error in FETCH stage npc_out!");
	// else
	// 	$display($time," PASS in FETCH stage npc_out!");
	
	if(fetch_Interface.check_pc != fetch_Interface.pc)
		$display($time," Error in FETCH stage pc!");
	// else
	// 	$display($time," PASS in FETCH stage pc!");
`endif

endtask : fetch_checker_syn

task fetch_checker_asyn();

`ifdef FETCH_DEBUG
	if(fetch_Interface.check_instrmem_rd != fetch_Interface.instrmem_rd)
		$display($time," Error in FETCH stage Instrmem_rd!");
	// else
	// 	$display($time," PASS in FETCH stage Instrmem_rd!");
`endif

endtask : fetch_checker_asyn

endclass

