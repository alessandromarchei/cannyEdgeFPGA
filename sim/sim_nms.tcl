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
    params.sv
    lineBuffer.sv
    conv_block_sobel.sv
    conv_block_gaussian.sv
    reduction_tree.sv
    sobel_arctan.sv
    sobel_magnitude.sv
    nms.sv
}

#Compile each adder file
foreach file $rtl {
    vlog -work work "$src_dir/$file"
}


#compile the testbench
vlog -work work "$tb_dir/tb_nms.sv"

# Load the testbench
vsim -voptargs="+acc" -batch work.tb_nms

add wave -color white sim:/tb_nms/clk
add wave -color white sim:/tb_nms/reset
add wave -color green -radix unsigned sim:/tb_nms/image_memory
add wave -color blue -radix unsigned sim:/tb_nms/gaussian_output
add wave -color yellow -radix decimal sim:/tb_nms/gx
add wave -color purple -radix decimal sim:/tb_nms/gy
add wave -color orange -radix unsigned sim:/tb_nms/gradient_magnitude
add wave -color brown -radix binary sim:/tb_nms/gradient_direction
add wave -color cyan -radix unsigned sim:/tb_nms/nms_output
add wave -color blue -radix unsigned sim:/tb_nms/i_kernel


set runTime 60ns

# Run simulation
run $runTime

