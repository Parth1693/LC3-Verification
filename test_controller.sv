//controller

//`timescale 10 ns / 1 ps
`include "interfaces_all.sv"

class controller;
// int control_Interface.next_state;
int br_flg;
virtual controlInterface control_Interface;

function new (virtual controlInterface c);
	control_Interface = c;
	
endfunction : new

task control_goldenref();

	begin
		if(control_Interface.reset)
			begin
			control_Interface.check_bypass_alu_1 = 0; 
			control_Interface.check_bypass_alu_2 = 0; 
			control_Interface.check_bypass_mem_1 = 0; 
			control_Interface.check_bypass_mem_2 = 0;
			control_Interface.check_enable_fetch = 1; 
			control_Interface.check_enable_decode = 0; 
			control_Interface.check_enable_execute = 0; 
			control_Interface.check_enable_writeback = 0;
			control_Interface.check_enable_updatePC = 1;
			control_Interface.check_br_taken = 0;
			control_Interface.check_mem_state = 2'h3;
			control_Interface.next_state = 0; 	// 13
			br_flg = 0;
			
			//control_Interface.enable_decode = 1;
					//	control_Interface.enable_execute = 1;
			
			//control_Interface.enable_writeback = 1;
			end
		else
		begin
			
			//Step 1. Setting bypass of ALU and MEM
			
			control_Interface.check_bypass_alu_1 = 0; 
			control_Interface.check_bypass_alu_2 = 0; 
			control_Interface.check_bypass_mem_1 = 0; 
			control_Interface.check_bypass_mem_2 = 0;
			control_Interface.check_br_taken = 0;
			//checking IR of decode stage
			if(control_Interface.IR[15:12] == ADD || control_Interface.IR[15:12] == AND || control_Interface.IR[15:12] == NOT)
				begin
				//checking IR_Exec of execute stage
				if(control_Interface.IR_Exec[15:12] == ADD || control_Interface.IR_Exec[15:12] == AND || control_Interface.IR_Exec[15:12] == NOT || control_Interface.IR_Exec[15:12] == LEA)
					begin
					if(control_Interface.IR_Exec[11:9] == control_Interface.IR[8:6])
						control_Interface.check_bypass_alu_1 = 1;
					if(control_Interface.IR[5] == 0)
						if(control_Interface.IR_Exec[11:9] == control_Interface.IR[2:0])
							control_Interface.check_bypass_alu_2 = 1;
					end
				if(control_Interface.IR_Exec[15:12] == LD || control_Interface.IR_Exec[15:12] == LDR || control_Interface.IR_Exec[15:12] == LDI)
					begin
					if(control_Interface.IR_Exec[11:9] == control_Interface.IR[8:6])
						control_Interface.check_bypass_mem_1 = 1;
					if(control_Interface.IR[5] == 0)
						if(control_Interface.IR_Exec[11:9] == control_Interface.IR[2:0])
							control_Interface.check_bypass_mem_2 = 1;					
					end
				end
			if(control_Interface.IR[15:12] == LDR)
				begin
				if(control_Interface.IR_Exec[15:12] == ADD || control_Interface.IR_Exec[15:12] == AND || control_Interface.IR_Exec[15:12] == NOT || control_Interface.IR_Exec[15:12] == LEA) //Should we include LEA?
					if(control_Interface.IR_Exec[11:9] == control_Interface.IR[8:6])
						control_Interface.check_bypass_alu_1 = 1;
				end
			if(control_Interface.IR[15:12] == STR)
				begin
				if(control_Interface.IR_Exec[15:12] == ADD || control_Interface.IR_Exec[15:12] == AND || control_Interface.IR_Exec[15:12] == NOT || control_Interface.IR_Exec[15:12] == LEA) //Should we include LEA?
					begin
					if(control_Interface.IR_Exec[11:9] == control_Interface.IR[8:6])
						control_Interface.check_bypass_alu_1 = 1;
					if(control_Interface.IR_Exec[11:9] == control_Interface.IR[11:9])
						control_Interface.check_bypass_alu_2 = 1;					
					end
				end
			if(control_Interface.IR[15:12] == ST || control_Interface.IR[15:12] == STI)
				if(control_Interface.IR_Exec[15:12] == ADD || control_Interface.IR_Exec[15:12] == AND || control_Interface.IR_Exec[15:12] == NOT || control_Interface.IR_Exec[15:12] == LEA) //Should we include LEA?
					if(control_Interface.IR_Exec[11:9] == control_Interface.IR[11:9])
						control_Interface.check_bypass_alu_2 = 1;	
			if(control_Interface.IR[15:12] == JMP)
				if(control_Interface.IR_Exec[15:12] == ADD || control_Interface.IR_Exec[15:12] == AND || control_Interface.IR_Exec[15:12] == NOT || control_Interface.IR_Exec[15:12] == LEA) //Should we include LEA?
					if(control_Interface.IR_Exec[11:9] == control_Interface.IR[8:6])
						control_Interface.check_bypass_alu_1 = 1;	

			//Step 2. Setting mem_state values
			
				//mem_state
	//1: for LDI STI,  0: LD, LDR  1: ST, STR  3: no memop state
	if(control_Interface.check_mem_state==2'b10)   // 2
	begin 
		control_Interface.check_mem_state = 2'b11;	//go to 3	

	end
	
	else if(control_Interface.check_mem_state==2'b0)  //0
	begin 
		control_Interface.check_mem_state = 2'b11;		//go to 3

	end

	else if((control_Interface.check_mem_state==2'b01) && (/*control_Interface.IR_Exec[15:12] == 4'b0011 || control_Interface.IR_Exec[15:12] == 4'b0111||*/ control_Interface.IR_Exec[15:12] == 4'b1011))    // 1 and store STI
	begin 
		control_Interface.check_mem_state = 2'b10;	//go to 2	

	end
	
	else if((control_Interface.check_mem_state==2'b01) && (/*control_Interface.IR_Exec[15:12] == 4'b0010 || control_Interface.IR_Exec[15:12] == 4'b0110||*/ control_Interface.IR_Exec[15:12] == 4'b1010))    // 1 and load LDI
	begin 
		control_Interface.check_mem_state = 2'b0;		// go to 0

	end

	else if(control_Interface.check_mem_state == 2'b11)  // 3
	begin
		if(control_Interface.IR_Exec[15:12] == 4'b0010 || control_Interface.IR_Exec[15:12] == 4'b0110)    // ld,ldr
			control_Interface.check_mem_state = 2'b0; //go to 0

		else if(control_Interface.IR_Exec[15:12] == 4'b0011 || control_Interface.IR_Exec[15:12] == 4'b0111)    // st, str
			control_Interface.check_mem_state = 2'b10; // go to 2

		else if(control_Interface.IR_Exec[15:12] == 4'b1010 || control_Interface.IR_Exec[15:12] == 4'b1011)    // sti, ldi
			control_Interface.check_mem_state = 2'b01; // go to 1

		else
			control_Interface.check_mem_state = 2'b11;
	end
	
	//Step 3. enable signals !!

	if(control_Interface.next_state == 0)
	begin
		//$display("I have entered here");
		control_Interface.check_enable_updatePC = 1;
		control_Interface.check_enable_fetch = 1;
		control_Interface.next_state = 1;
	end
	
	else if (control_Interface.next_state == 1)
	begin
		control_Interface.check_enable_decode = 1;
		control_Interface.next_state = 2;
		//check jmp, br
		if(control_Interface.Instr_dout[15:12] == JMP || control_Interface.Instr_dout[15:12] == BR)
		begin
		control_Interface.check_enable_updatePC = 0;
		control_Interface.check_enable_fetch = 0;
		control_Interface.next_state = 9;			
		end
		
	end
	
	else if (control_Interface.next_state == 2)
	begin
		control_Interface.check_enable_execute = 1;
		control_Interface.next_state = 3;
	end
	
	else if (control_Interface.next_state == 3)
	begin
		control_Interface.check_enable_writeback = 1;
		control_Interface.next_state = 3;
		if(control_Interface.IR_Exec[15:12] == LD || control_Interface.IR_Exec[15:12] == LDR)
			begin
			control_Interface.check_enable_fetch = 0;
			control_Interface.check_enable_decode = 0; 
			control_Interface.check_enable_execute = 0; 
			control_Interface.check_enable_writeback = 0;
			control_Interface.check_enable_updatePC = 0;
			control_Interface.next_state = 4;
			end
		else if(control_Interface.IR_Exec[15:12] == ST || control_Interface.IR_Exec[15:12] == STR)
			begin
			control_Interface.check_enable_fetch = 0;
			control_Interface.check_enable_decode = 0; 
			control_Interface.check_enable_execute = 0; 
			control_Interface.check_enable_writeback = 0;
			control_Interface.check_enable_updatePC = 0;
			control_Interface.next_state = 5;
			end	
		else if(control_Interface.IR_Exec[15:12] == LDI)
		begin
			control_Interface.check_enable_fetch = 0;
			control_Interface.check_enable_decode = 0; 
			control_Interface.check_enable_execute = 0; 
			control_Interface.check_enable_writeback = 0;
			control_Interface.check_enable_updatePC = 0;
			control_Interface.next_state = 7;			
		end
		else if(control_Interface.IR_Exec[15:12] == STI)
		begin
			control_Interface.check_enable_fetch = 0;
			control_Interface.check_enable_decode = 0; 
			control_Interface.check_enable_execute = 0; 
			control_Interface.check_enable_writeback = 0;
			control_Interface.check_enable_updatePC = 0;
			control_Interface.next_state = 8;			
		end
		else if((control_Interface.Instr_dout[15:12]==JMP || control_Interface.Instr_dout[15:12]==BR) && br_flg==0)
		begin
			control_Interface.check_enable_updatePC = 0;
			control_Interface.check_enable_fetch = 0;
			br_flg = 1;
			control_Interface.next_state = 9;
		end
		else if((control_Interface.Instr_dout[15:12]==JMP || control_Interface.Instr_dout[15:12]==BR) && br_flg==1)
		begin
			br_flg = 1;
			control_Interface.next_state = 12;
		end
		
	end
	
	else if(control_Interface.next_state == 4)
	begin
	control_Interface.check_enable_fetch = 1;
	control_Interface.check_enable_decode = 1; 
	control_Interface.check_enable_execute = 1; 
	control_Interface.check_enable_writeback = 1;
	control_Interface.check_enable_updatePC = 1;
	control_Interface.next_state = 3;		
	end
	
	else if(control_Interface.next_state == 5)
	begin
	control_Interface.check_enable_fetch = 1;
	control_Interface.check_enable_decode = 1; 
	control_Interface.check_enable_execute = 1; 
	//control_Interface.check_enable_writeback = 0;
	control_Interface.check_enable_updatePC = 1;
	control_Interface.next_state = 6;		
	end
	
	else if(control_Interface.next_state == 6)  ///can i directly go to 3?????
	begin
	control_Interface.check_enable_writeback = 1;
	control_Interface.next_state = 3;
	end
	
	else if(control_Interface.next_state == 7)
	begin
	control_Interface.next_state = 4;
	end
	
	else if(control_Interface.next_state == 8)
	begin
	control_Interface.next_state = 5;
	end
	
	else if(control_Interface.next_state == 9)
	begin
		control_Interface.check_enable_decode = 0;
		control_Interface.check_enable_execute = 1;
		control_Interface.check_enable_updatePC = 0;
		control_Interface.next_state = 10;
	end
	
	else if(control_Interface.next_state == 10)
	begin
		control_Interface.check_enable_execute = 0;
		control_Interface.check_enable_writeback = 0;
		//control_Interface.check_br_taken = 1;
		control_Interface.check_enable_updatePC = 0;
		control_Interface.next_state = 11;
	end
	
	else if(control_Interface.next_state == 11)
	begin
		control_Interface.check_enable_fetch = 1;
		control_Interface.check_enable_updatePC = 1;
		//control_Interface.check_br_taken = 0;
		control_Interface.next_state = 1;
	end
	
	else if(control_Interface.next_state == 12)
	begin
		control_Interface.check_enable_updatePC = 0;
		control_Interface.check_enable_fetch = 0;		
		control_Interface.next_state = 9;
	end

	//Step 4. br_taken Signal

	if(control_Interface.enable_updatePC == 1)
		control_Interface.check_br_taken = (|(control_Interface.NZP & control_Interface.psr));
	
	if(control_Interface.check_br_taken == 1)
		control_Interface.check_enable_updatePC = 1;
		
	end
	end

endtask

task control_checker_syn();
`ifdef CONTROLLER_DEBUG
	if (control_Interface.reset == 1)
	begin

	if(control_Interface.check_enable_decode != control_Interface.enable_decode)
		$display($time, " Error in Controller stage enable_decode!");
	// else
	// 	$display($time, " PASS in Controller stage enable_decode!");	
		
	if(control_Interface.check_enable_execute != control_Interface.enable_execute)
		$display($time, " Error in Controller stage enable_execute!");
	// else
	// 	$display($time, " PASS in Controller stage enable_execute!");		
	if(control_Interface.check_enable_writeback != control_Interface.enable_writeback)
		$display($time, " Error in Controller stage enable_writeback!");
	// else
	// 	$display($time, " PASS in Controller stage enable_writeback!");	
	if(control_Interface.check_enable_updatePC != control_Interface.enable_updatePC)
		$display($time, " Error in Controller stage enable_updatePC!");
	if(control_Interface.check_enable_fetch != control_Interface.enable_fetch)
		$display($time, " Error in Controller stage enable_fetch!");
	// else
	// 	$display($time, " PASS in Controller stage enable_updatePC!");	
	end
`endif
endtask
	

task control_checker_asyn();
`ifdef CONTROLLER_DEBUG
	if(control_Interface.check_br_taken != control_Interface.br_taken)
		$display($time, " Error in Controller stage br_taken!");
	//else
	//	$display($time, " PASS in Controller stage br_taken!");
		
	if(control_Interface.check_bypass_alu_1 != control_Interface.bypass_alu_1)
		$display($time, " Error in Controller stage bypass_alu_1!");
	// else
	// 	$display($time, " PASS in Controller stage bypass_alu_1!");	
		
	if(control_Interface.check_bypass_alu_2 != control_Interface.bypass_alu_2)
		$display($time, " Error in Controller stage bypass_alu_2!");
	// else
	// 	$display($time, " PASS in Controller stage bypass_alu_2!");
		
	if(control_Interface.check_bypass_mem_1 != control_Interface.bypass_mem_1)
		$display($time, " Error in Controller stage bypass_mem_1!");
	// else
	// 	$display($time, " PASS in Controller stage bypass_mem_1!");	
		
	if(control_Interface.check_bypass_mem_2 != control_Interface.bypass_mem_2)
		$display($time, " Error in Controller stage bypass_mem_2!");
	// else
	// 	$display($time, " PASS in Controller stage bypass_mem_2!");

	if(control_Interface.check_mem_state != control_Interface.mem_state)
		$display($time, " Error in Controller stage mem_state!");
	// else
	// 	$display($time, " PASS in Controller stage mem_state!");	
		
	
	// else
	// 	$display($time, " PASS in Controller stage enable_fetch!");
		

	if (control_Interface.reset != 1)
	begin

	if(control_Interface.check_enable_decode != control_Interface.enable_decode)
		$display($time, " Error in Controller stage enable_decode!");
	// else
	// 	$display($time, " PASS in Controller stage enable_decode!");	
		
	if(control_Interface.check_enable_execute != control_Interface.enable_execute)
		$display($time, " Error in Controller stage enable_execute!");
	// else
	// 	$display($time, " PASS in Controller stage enable_execute!");		
	if(control_Interface.check_enable_writeback != control_Interface.enable_writeback)
		$display($time, " Error in Controller stage enable_writeback!");
	// else
	// 	$display($time, " PASS in Controller stage enable_writeback!");	
	if(control_Interface.check_enable_updatePC != control_Interface.enable_updatePC)
		$display($time, " Error in Controller stage enable_updatePC!");
	// else
	// 	$display($time, " PASS in Controller stage enable_updatePC!");	
	if(control_Interface.check_enable_fetch != control_Interface.enable_fetch)
		$display($time, " Error in Controller stage enable_fetch!");
	end	
			
`endif
endtask

endclass
