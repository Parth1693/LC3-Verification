#Compilation file for Project

vlog -sv *.vp *.v
vlog -sv top.sv
vsim -novopt Top
coverage save cov.ucdb
run -all

