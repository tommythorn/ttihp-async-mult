test:
	iverilog -DSIM -o project project.v tokenflow.v
	./project

lint:
	verilator --lint-only --timing --top-module tt_um_tommythorn_experiments project.v tokenflow.v
