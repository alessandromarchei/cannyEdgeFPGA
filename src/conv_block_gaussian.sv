`include "params.sv"

// THIS MODULE IMPLEMENTS THE CONVOLUTIONAL BLOCKS for a GAUSSIAN filter, in FIXED POINT REPRESENTATION
module conv_block_gaussian #(
    parameter NBIT = 8,          // Define NBIT (bit-width)
    parameter KERNEL_SIZE = 3,   // Define KERNEL_SIZE (size of the kernel)
    parameter FRAC_BITS = 10     // FRACTIONAL BITS FOR THE FIXED POINT REPRESENTATION
)(
    input i_clk,                                   // Clock signal
    input[NBIT-1:0] i_data [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0],  // Pixels entering the convolution block
    input i_data_valid,                            // Indicating when to perform the MAC
    input [FRAC_BITS-1:0] i_kernel [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0], // Data for the kernel block
    input i_kernel_valid,                          // Indicating the new kernel to load
    output[NBIT+NBIT+$clog2(KERNEL_SIZE*KERNEL_SIZE)-1:0] o_pixel // Computed pixel at the output
);

// Declare KERNEL_SIZE**2 signal data as output of the multipliers
//wire[(NBIT)+(NBIT)-1:0] out_mul [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
wire unsigned[NBIT + 1 + FRAC_BITS -1:0] out_mul_extended [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];


// Separating the input data into KERNEL_SIZE**2 pixels
reg [FRAC_BITS-1:0] kernel_matrix [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
genvar i, j;

// Perform each multiplication in parallel (combinational block)
generate
    for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : mul_loop_i
        for (j = 0; j < KERNEL_SIZE; j = j + 1) begin : mul_loop_j
            assign out_mul_extended[i][j] = (kernel_matrix[i][j] * i_data[i][j]);   //shifting is applied after the sum, to maintain precision 
        end
    end
endgenerate


wire [(NBIT + 1 + FRAC_BITS)-1:0] flattened_out_mul_extended [KERNEL_SIZE*KERNEL_SIZE-1:0];

// Flattening the out_mul matrix of the multiplier results
generate
    for (i = 0; i < KERNEL_SIZE; i = i + 1) begin : flat_mul_i
        for (j = 0; j < KERNEL_SIZE; j = j + 1) begin : flat_mul_j
            assign flattened_out_mul_extended[i*KERNEL_SIZE + j] = out_mul_extended[i][j];
        end
    end
endgenerate

wire [(NBIT + FRAC_BITS + 1 +$clog2(KERNEL_SIZE*KERNEL_SIZE))-1:0] sum_extended;

// Instantiate the reduction tree module
reduction_tree #(
    .NBIT(NBIT + FRAC_BITS + 1),   // Parallelism is doubled since we are adding up multiplier outputs
    .NUM_ADDENDS(KERNEL_SIZE*KERNEL_SIZE)
) tree_adder(
    .data_in(flattened_out_mul_extended),
    .result(sum_extended)       // Output of the convolution, with full precision
);

//perform the shifting operation to get the final output
assign o_pixel = sum_extended >> FRAC_BITS;

// Process for loading the kernel weights into the matrix
always @(posedge i_clk) begin
    if (i_kernel_valid) begin
        for (int i = 0; i < KERNEL_SIZE; i = i + 1) begin
            for (int j = 0; j < KERNEL_SIZE; j = j + 1) begin
                kernel_matrix[i][j] <= i_kernel[i][j] ;
            end
        end
    end
end

endmodule
