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
    reduction_tree.sv
    conv_block_gaussian.sv
    conv_block_sobel.sv
    lut_atan.sv
    sobel_magnitude.sv
    lut_log_quantizer.sv
    sobel_atan.sv
    nms.sv
    threshold.sv
}

#Compile each adder file
foreach file $rtl {
    vlog -work work "$src_dir/$file"
}


#compile the testbench
vlog -work work "$tb_dir/tb_lut_atan.sv"

# Load the testbench
vsim -voptargs="+acc" work.tb_lut_atan

add wave -color white sim:/tb_lut_atan/clk
add wave -color white sim:/tb_lut_atan/reset
add wave -color blue -radix unsigned sim:/tb_lut_atan/i_kernel
add wave -color green -radix unsigned sim:/tb_lut_atan/image_memory
add wave -color blue -radix unsigned sim:/tb_lut_atan/gaussian_output
add wave -color yellow -radix decimal sim:/tb_lut_atan/gx
add wave -color purple -radix decimal sim:/tb_lut_atan/gy
add wave -color orange -radix unsigned sim:/tb_lut_atan/gradient_magnitude
add wave -color brown -radix binary sim:/tb_lut_atan/gradient_direction
add wave -color cyan -radix unsigned sim:/tb_lut_atan/nms_output
add wave -color red -radix unsigned sim:/tb_lut_atan/threshold_output

add wave -label gx -COLOR yellow -radix decimal sim:/tb_lut_atan/arctan_row[0]/arctan_col[0]/sobel_dir/gx
add wave -label gy -COLOR purple -radix decimal sim:/tb_lut_atan/arctan_row[0]/arctan_col[0]/sobel_dir/gy
add wave -label abs_gx -COLOR yellow -radix unsigned sim:/tb_lut_atan/arctan_row[0]/arctan_col[0]/sobel_dir/abs_gx
add wave -label abs_gy -COLOR purple -radix unsigned sim:/tb_lut_atan/arctan_row[0]/arctan_col[0]/sobel_dir/abs_gy
add wave -label addr_x -COLOR blue -radix unsigned sim:/tb_lut_atan/arctan_row[0]/arctan_col[0]/sobel_dir/addr_x
add wave -label addr_y -COLOR red -radix unsigned sim:/tb_lut_atan/arctan_row[0]/arctan_col[0]/sobel_dir/addr_y

add wave -COLOR cyan -radix binary -label LUT_OUTPUT sim:/tb_lut_atan/arctan_row[0]/arctan_col[0]/sobel_dir/lut_output
add wave -COLOR green -radix binary -label DIRECTION sim:/tb_lut_atan/arctan_row[0]/arctan_col[0]/sobel_dir/o_direction


add wave -COLOR green -label LUT_X -radix unsigned sim:/tb_lut_atan/arctan_row[0]/arctan_col[0]/sobel_dir/LUT/x
add wave -COLOR yellow -label LUT_Y -radix unsigned sim:/tb_lut_atan/arctan_row[0]/arctan_col[0]/sobel_dir/LUT/y
add wave -COLOR orange -label LUT_module_output -radix binary sim:/tb_lut_atan/arctan_row[0]/arctan_col[0]/sobel_dir/LUT/direction
add wave -COLOR magenta -label 2D_ARRAY -radix binary sim:/tb_lut_atan/arctan_row[0]/arctan_col[0]/sobel_dir/LUT/lut


set runTime 75ns

# Run simulation
run $runTime

