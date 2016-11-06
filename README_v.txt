Following steps are to be followed for running the verification folder:

1. Run following commands:

	tcsh
	add modelsim10.3b
	setenv MODELSIM modelsim.ini
	vlib mti_lib
	vlib work
	vlog -sv *.vp *.v make sure that the .vp and .v files are in the same folder as the sv files. 
	vlog -sv top.sv

2. Launch the Modelsim GUI using the 'vsim &' command

3. Once Modelsim is launched, run the compile.do file on the 'vsim >' console - do compile.do, making sure the vp and v files are in the same folder as the sv files.  
This will compile all the testbench source files along with the DUT files and run the simulation.

4. Errors in the DUT are printed as the name of the module of the error 
and the name of the signal along with the simulation time. 
