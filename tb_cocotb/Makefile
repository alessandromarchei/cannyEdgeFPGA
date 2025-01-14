PROJ_DIR = $(PWD)/../

TOPLEVEL_LANG = verilog
TOPLEVEL      = conv_block      # The name of your Verilog module
MODULE        = test_conv # Name of the Cocotb testbench Python file (without .py)

# Paths to your simulator and source files
VERILOG_SOURCES = ${PROJ_DIR}/src/conv_block.sv
SIM             = modelsim      # Specify the simulator (ModelSim)
WAVES           = 1             # Enable waveform dump (optional)

# Include Cocotb's makefile
include $(shell cocotb-config --makefiles)/Makefile.sim
