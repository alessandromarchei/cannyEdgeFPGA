`include "params.sv"

`define MEM_DIR "../mems/"
`define ARCTAN_LUT "lut_arctan.mem"

module arctan_lut (
    input  logic signed [`NBIT_SOBEL-1:0] gx,  // input x
    input  logic signed [`NBIT_SOBEL-1:0] gy,  // input y
    output logic signed [`NBIT_SOBEL-1:0] arctan // output
);

    // LUT for the first quadrant (positive gx and gy only)
    logic [`NBIT_SOBEL-1:0] lut [0:$sqrt(`LUT_ATAN_SIZE)-1][0:$sqrt(`LUT_ATAN_SIZE)-1];

    // LUT initialization (values precomputed offline)
    initial begin
        $readmemh({`MEM_DIR,`ARCTAN_LUT}, lut); // Load LUT data from a file
    end

    // Compute the arctangent using LUT and adjust for symmetry
    always_comb begin
        logic signed [`NBIT_SOBEL-1:0] abs_gx, abs_gy;
        logic signed [`NBIT_SOBEL-1:0] lut_value;

        // Take absolute values to map to the first quadrant
        abs_gx = (gx < 0) ? -gx : gx;
        abs_gy = (gy < 0) ? -gy : gy;

        // Bound inputs to LUT size
        if (abs_gx >= `LUT_ATAN_SIZE/2 || abs_gy >= `LUT_ATAN_SIZE/2) begin
            lut_value = 0; // Handle out-of-range values gracefully
        end else begin
            lut_value = lut[abs_gx][abs_gy]; // Look up the LUT
        end

        // Adjust result based on quadrant
        if (gx >= 0 && gy >= 0) begin
            arctan = lut_value; // First quadrant
        end else if (gx < 0 && gy >= 0) begin
            arctan = 90 - lut_value; // Second quadrant
        end else if (gx < 0 && gy < 0) begin
            arctan = -90 + lut_value; // Third quadrant
        end else begin
            arctan = -lut_value; // Fourth quadrant
        end
    end

endmodule
