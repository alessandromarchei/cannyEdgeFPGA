`include "params.sv"

module sobel_magnitude #(
    parameter NBIT = 11          // Bit-width of input pixels
)
(
    input wire i_clk,                                    // Clock signal
    input wire i_data_valid,                             // Valid signal for input data
    input signed [NBIT-1:0] gx,
    input signed [NBIT-1:0] gy,
    output reg [NBIT:0] module_g
);

/*
    APPROXIMATIONS : 
    - MODULE : G = max(abs(GX),abs(GY)) + 0.5*min(abs(GX),abs(GY))
    - ARCTANG : LUT BASED
*/

wire [NBIT-1:0] gx_abs;
wire [NBIT-1:0] gy_abs;

assign gx_abs = (gx < 0) ? -gx : gx;
assign gy_abs = (gy < 0) ? -gy : gy;


always @(posedge i_clk) begin
    if (i_data_valid) begin
        if(gx_abs > gy_abs) begin
            module_g <= gx_abs + (gy_abs >> 1);
        end
        else begin
            module_g <= gy_abs + (gx_abs >> 1);
        end
    end
end


endmodule
