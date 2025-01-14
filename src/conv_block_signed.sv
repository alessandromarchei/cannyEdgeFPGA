`include "params.sv"


//THIS MODULE IMPLEMENTS THE CONVOLUTIONAL BLOCKS for a GAUSSIAN filter, in FIXED POINT REPRESENTATION
//so every kernel is normalized and the notation is the Q1.FRAC_BITS, so that after the multiplication 
//with the pixel value, the result is restored.
//NOTE that due to the nature of the filter, an unsin
module conv_block #(
    parameter NBIT = 8,          // Define NBIT (bit-width)
    parameter KERNEL_SIZE = 3,    // Define KERNEL_SIZE (size of the kernel)
    parameter FRAC_BITS = 10        //FRACTIONAL BITS FOR THE FIXED POINT REPRESENTATION
)(
    input i_clk,                                   // Clock signal
    input signed[NBIT-1:0] i_data [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0],  // Pixels entering the convolution block
    input i_data_valid,                            // Indicating when to perform the MAC
    input signed [NBIT-1:0] i_kernel [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0], // Data for the kernel block
    input i_kernel_valid,                         // Indicating the new kernel to load
    output signed[NBIT+NBIT+$clog2(KERNEL_SIZE*KERNEL_SIZE)-1:0] o_pixel                 // Computed pixel at the output
);


//declare KERNEL_SIZE**2 signal data as output of the multipliers
wire signed[(NBIT)+(NBIT)-1:0] out_mul [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];

//separating the input data which is continuous, into KERNEL_SIZE**2 pixels

reg signed [NBIT-1:0] kernel_matrix [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
genvar i,j;

// Extend the pixel width by 1 bit for signed representation
wire signed [NBIT:0] pixel_matrix_signed [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];

generate
    for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : pixel_conversion
        for (j = 0; j < KERNEL_SIZE; j = j + 1) begin : pixel_conversion_inner
            assign pixel_matrix_signed[i][j] = $signed({1'b0, i_data[i][j]}); // Zero-extend and convert to signed
        end
    end
endgenerate


//in this module we need to perfor #MUL = KERNEL_SIZE*KERNEL_SIZE, and a #ADDS = KERNEL_SIZE*KERNEL_SIZE-1
// Perform each multiplication in parallel (combinational block)
generate
    for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : mul_loop_i
        for (j = 0; j < KERNEL_SIZE; j = j + 1) begin : mul_loop_j
            assign out_mul[i][j] = (kernel_matrix[i][j] * pixel_matrix_signed[i][j]) >> FRAC_BITS;      //restore the value after the fp
        end
    end
endgenerate

wire signed [(NBIT)+(NBIT)-1:0] flattened_out_mul [KERNEL_SIZE*KERNEL_SIZE-1:0];

//flattening the out_mul matrix of the multiplier results

generate
    for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : flat_mul_i
        for (j = 0; j < KERNEL_SIZE; j = j + 1) begin : flat_mul_j
            assign flattened_out_mul[i*KERNEL_SIZE + j] = out_mul[i][j];
        end
    end
endgenerate

//wire signed [NBIT+NBIT+$clog2(KERNEL_SIZE*KERNEL_SIZE)-1:0] conv_out;

//instantiate the reduction tree module
reduction_tree #(
    .NBIT(NBIT+NBIT),   //PARALLELISM is doubled since we are adding up some multiplier outputs 
    .NUM_ADDENDS(KERNEL_SIZE*KERNEL_SIZE)
) tree_adder(
    .data_in(flattened_out_mul),
    .result(o_pixel)       //output of the convolution, with full precision
);

//process for loading the kernel weigths into the matrix
always @(posedge i_clk) begin
    //BLOCKING-ASSIGNMENTS, so save on the next clock cycle
    if(i_kernel_valid)
    begin
        for (int i = 0;i < KERNEL_SIZE ;i = i+1 ) begin
            for (int j = 0;j < KERNEL_SIZE ;j = j+1 ) begin
                //now save the weigths into the kernel matrix
                kernel_matrix[i][j] <= i_kernel[i][j];
            end
        end
    end
end


    
endmodule