`include "params.sv"

module sobel_magnitude #(
    parameter NBIT = 16,          // Bit-width of input pixels
)
(
    input wire i_clk,                                    // Clock signal
    input wire i_data_valid,                             // Valid signal for input data
    input signed [NBIT-1:0] gx,
    input signed [NBIT-1:0] gy,
    output reg [NBIT-1:0] module_g,
    output reg signed [NBIT-1:0] arctang
);

/*
    APPROXIMATIONS : 
    - MODULE : G = max(abs(GX),abs(GY)) + 0.5*min(abs(GX),abs(GY))
    - ARCTANG : LUT BASED
*/



always @(posedge i_clk) begin
    if (i_data_valid) begin
        
    end
end


endmodule
