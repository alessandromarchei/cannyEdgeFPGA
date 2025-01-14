# Set the working directory
set work_dir "work"
set src_dir "../src"
set tb_dir "../tb"

# Create the work library if it does not exist
if {[file exists $work_dir]} {
    vdel -lib $work_dir -all
}
vlib $work_dir

# Compile the design files
vmap work $work_dir

set rtl {
    reduction_tree.sv
    params.sv
    lineBuffer.sv
    conv_block.sv
}

#Compile each adder file
foreach file $rtl {
    vlog -work work "$src_dir/$file"
}


#compile the testbench
vlog -work work "$tb_dir/tb_conv.sv"

# Load the testbench
vsim -voptargs="+acc" work.tb_conv


# #set all the waves in decimal view
# add wave -color white sim:/tb_dlx/Clock
# add wave -color white sim:/tb_dlx/Reset
# add wave -color yellow -radix decimal sim:/tb_dlx/DRAM_IN
# add wave -color blue -radix decimal sim:/tb_dlx/DRAM_OUT
# add wave -color green -radix hex sim:/tb_dlx/DRAM_ADDR
# add wave -color yellow -radix hex sim:/tb_dlx/IRAM_DATA
# add wave -color green -radix hex sim:/tb_dlx/IRAM_ADDR
# add wave -color purple -radix decimal sim:/tb_dlx/DRAM_DATA
# add wave -color white sim:/tb_dlx/MEM_WR_t
# add wave -color white sim:/tb_dlx/MEM_RD_t

add wave -color white sim:/tb_conv/uut/i_clk
add wave -color red -radix unsigned sim:/tb_conv/uut/i_data
add wave sim:/tb_conv/uut/i_data_valid
add wave -color blue -radix unsigned sim:/tb_conv/uut/i_kernel
add wave sim:/tb_conv/uut/i_kernel_valid
add wave -color green -radix unsigned sim:/tb_conv/uut/o_pixel
add wave -color yellow -radix unsigned sim:/tb_conv/uut/out_mul_extended
add wave -radix unsigned -radix unsigned sim:/tb_conv/uut/tree_adder/data_in
add wave -radix unsigned -color blue sim:/tb_conv/uut/sum_extended
add wave -color orange -radix unsigned sim:/tb_conv/uut/flattened_out_mul_extended 

set runTime 220ns

# Run simulation
run $runTime
