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
    conv_block_gaussian.sv
    conv_block_sobel.sv
}

#Compile each adder file
foreach file $rtl {
    vlog -work work "$src_dir/$file"
}


#compile the testbench
vlog -work work "$tb_dir/tb_conv_gaussian.sv"
vlog -work work "$tb_dir/tb_conv_sobel.sv"

# Load the testbench
vsim -voptargs="+acc" work.tb_conv_gaussian


add wave -color white sim:/tb_conv_gaussian/uut/i_clk
add wave -color red -radix unsigned sim:/tb_conv_gaussian/uut/i_data
add wave sim:/tb_conv_gaussian/uut/i_data_valid
add wave -color blue -radix unsigned sim:/tb_conv_gaussian/uut/i_kernel
add wave sim:/tb_conv_gaussian/uut/i_kernel_valid
add wave -color green -radix unsigned sim:/tb_conv_gaussian/uut/o_pixel
add wave -color yellow -radix unsigned sim:/tb_conv_gaussian/uut/out_mul_extended
add wave -radix unsigned -radix unsigned sim:/tb_conv_gaussian/uut/tree_adder/data_in
add wave -color purple -radix unsigned sim:/tb_conv_gaussian/uut/tree_adder/sums 
add wave -radix unsigned -color blue sim:/tb_conv_gaussian/uut/sum_extended
add wave -color orange -radix unsigned sim:/tb_conv_gaussian/uut/flattened_out_mul_extended 

set runTime 2000ns

# Run simulation
run $runTime

