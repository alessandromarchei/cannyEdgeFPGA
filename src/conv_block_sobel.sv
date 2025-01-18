`include "params.sv"

module conv_block_sobel #(
    parameter NBIT = 8,          // Bit-width of input pixels
    parameter KERNEL_SIZE = 3,
    parameter NBIT_SOBEL = 2*NBIT    // Size of the kernel
)(
    input wire i_clk,                                    // Clock signal
    input wire [NBIT-1:0] i_data [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0], // Input pixel data
    input wire i_data_valid,                             // Valid signal for input data
    output reg signed [NBIT_SOBEL-1:0] gx,       // Compute the output G as gradient
    output reg signed [NBIT_SOBEL-1:0] gy       
);

// Sampling input data and direction at clock edge
always @(posedge i_clk) begin
    if (i_data_valid) begin
        gx <= i_data[0][0] 
                        + (i_data[1][0] << 1) 
                        + i_data[2][0] 
                        - i_data[0][2] 
                        - (i_data[1][2] << 1) 
                        - i_data[2][2];
        gy <= i_data[0][0] 
                        + (i_data[0][1] << 1) 
                        + i_data[0][2] 
                        - i_data[2][0] 
                        - (i_data[2][1] << 1) 
                        - i_data[2][2];
    end
end


endmodule
