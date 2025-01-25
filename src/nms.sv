`include "params.sv"

/* DIRECTION CODES
    - 00 : HORIZONTAL
    - 01 : DIAGONAL 45 DEGREES
    - 10 : VERTICAL
    - 11 : DIAGONAL 135 DEGREES
*/

module nms #(
    parameter NBIT_INPUT = 12        // Bit width for the magnitude values
)(
    input wire i_clk,
    input wire [NBIT_INPUT-1:0] i_block[2:0][2:0], // Kernel of neighboring pixels with absolute values
    input wire [1:0] direction,     // Direction from arctan module
    output reg [NBIT_INPUT-1:0] nms_output // Suppressed magnitude output
);

localparam CENTER = 2 / 2; // Index of the center pixel
wire [NBIT_INPUT-1:0] center_pixel;


assign center_pixel = i_block[CENTER][CENTER];


always @(posedge i_clk) begin
    // Default: Suppress the output
    nms_output <= 0;

    // Neighbor pixel magnitudes based on the direction
    case (direction)
        2'b00: begin  // HORIZONTAL
            if (center_pixel >= i_block[CENTER][CENTER-1] && center_pixel >= i_block[CENTER][CENTER+1])
                nms_output <= center_pixel;
        end

        2'b01: begin  // DIAGONAL 45 DEGREES
            if (center_pixel >= i_block[CENTER-1][CENTER+1] && center_pixel >= i_block[CENTER+1][CENTER-1])
                nms_output <= center_pixel;
        end

        2'b10: begin  // VERTICAL
            if (center_pixel >= i_block[CENTER-1][CENTER] && center_pixel >= i_block[CENTER+1][CENTER])
                nms_output <= center_pixel;
        end

        2'b11: begin  // DIAGONAL 135 DEGREES
            if (center_pixel >= i_block[CENTER-1][CENTER-1] && center_pixel >= i_block[CENTER+1][CENTER+1])
                nms_output <= center_pixel;
        end

        default: begin
            nms_output <= 0;  // Suppress if direction is undefined
        end
    endcase
end

endmodule
