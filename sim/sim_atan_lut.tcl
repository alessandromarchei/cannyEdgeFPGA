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
    lut_atan.sv
    sobel_magnitude.sv
}

#Compile each adder file
foreach file $rtl {
    vlog -work work "$src_dir/$file"
}


#compile the testbench
vlog -work work "$tb_dir/tb_lut_atan.sv"

# Load the testbench
vsim -voptargs="+acc" work.tb_lut_atan


add wave *
# add wave -color white sim:/tb_conv_sobel/uut/i_clk
# add wave -color green -radix unsigned sim:/tb_conv_sobel/uut/i_data
# add wave -color white sim:/tb_conv_sobel/uut/i_data_valid
# add wave -color blue -radix decimal sim:/tb_conv_sobel/uut/gx
# add wave -color red -radix decimal sim:/tb_conv_sobel/uut/gy

set runTime 2000ns

# Run simulation
run $runTime

