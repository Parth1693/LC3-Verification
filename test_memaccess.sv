// `timescale 10 ns / 1 ps
//`include "debug.sv"

class memaccess;

virtual memaccessInterface memaccess_Interface;

function new(virtual memaccessInterface m);
begin
	memaccess_Interface = m;
end
endfunction : new

task memaccess_goldenref();
	
	begin
	memaccess_Interface.check_memout = memaccess_Interface.Data_dout;
	if( memaccess_Interface.mem_state == 0)
	begin
		memaccess_Interface.check_data_rd = 1'b1;
		memaccess_Interface.check_data_din =1'b0;
		if (memaccess_Interface.M_Control ==1)
			memaccess_Interface.check_data_addr = memaccess_Interface.Data_dout;
		else
			memaccess_Interface.check_data_addr = memaccess_Interface.M_Addr;
	end
	else if(memaccess_Interface.mem_state == 1)
	begin
		memaccess_Interface.check_data_rd = 1'b1;
		memaccess_Interface.check_data_din =1'b0;
		memaccess_Interface.check_data_addr = memaccess_Interface.M_Addr;
	end
	else if (memaccess_Interface.mem_state == 2)
	begin 
		memaccess_Interface.check_data_rd = 1'b0;
		memaccess_Interface.check_data_din =memaccess_Interface.M_Data;
		if(memaccess_Interface.M_Control==1)
			memaccess_Interface.check_data_addr = memaccess_Interface.Data_dout;
		else
			memaccess_Interface.check_data_addr = memaccess_Interface.M_Addr;       // Please check here with TA!
		end
	end

endtask : memaccess_goldenref

task memaccess_checker_asyn();

`ifdef MEMACCESS_DEBUG
begin
	if(memaccess_Interface.check_data_rd != memaccess_Interface.Data_rd)
		$display($time, " Error in Mem Access stage data_read!");
	// else
	// 	$display($time, " PASS in Mem Access stage data_read!");

	if(memaccess_Interface.check_data_din != memaccess_Interface.Data_din )
		$display($time," Error in Mem Access stage data_din!");
	// else
	// 	$display($time, " PASS in Mem Access stage data_din!");

	if(memaccess_Interface.check_data_addr != memaccess_Interface.Data_addr)
		$display($time," Error in Mem Access stage data_addr!" );
	// else
	// 	$display($time, " PASS in Mem Access stage data_addr!");

	if(memaccess_Interface.check_memout != memaccess_Interface.memout)
		$display($time," Error in Mem Access stage memout!" );
	// else
	// 	$display($time, " PASS in Mem Access stage memout!");
end
`endif

endtask : memaccess_checker_asyn

endclass : memaccess
