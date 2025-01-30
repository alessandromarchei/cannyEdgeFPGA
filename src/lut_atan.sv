`include "params.sv"

`define MEM_DIR "../mems/"
`define MAX_VALUE 1021
`define LUT_ATAN_SIZE ((`FINE_THRESHOLD + (`MAX_VALUE - `FINE_THRESHOLD)) ** 2)

module lut_atan (
    input wire i_clk,
    input signed [10:0] gx,  // input x
    input signed [10:0] gy,  // input y
    output reg signed [1:0] atan // output
);

    // LUT for the first quadrant (positive gx and gy only)
    logic [1:0] lut [0:`LUT_ATAN_SIZE-1];

    // LUT initialization (values precomputed offline)
    initial begin
        $readmemh({`MEM_DIR,"lut_atan_fine",`FINE_THRESHOLD,"_coarse",`COARSE_STEP,".mem"}, lut); // Load LUT data from a file
    end

//address for the LUT. it is composed by the LSB of the X coordinate, 
//and on the MSB it contains the Y coordinates, scaled and quantized
logic [$clog2(LUT_ATAN_SIZE)-1:0] lut_address;


logic [9:0] abs_gx,abs_gy;
logic [($clog2(LUT_ATAN_SIZE)/2) - 1:0] x_addr,y_addr;


//precompute the absolute values of gx and gy
assign abs_gx = (gx < 0) ? -gx : gx;
assign abs_gy = (gy < 0) ? -gy : gy;

    always_comb begin : part_address_computation
        localparam base_addr = `FINE_THRESHOLD;
        if(abs_gx < FINE_THRESHOLD) begin
            x_addr = abs_gx;
        end
        else x_addr = base_addr + 
    end


    // Compute the arctangent using LUT and adjust for symmetry
    always_comb begin

        // Bound inputs to LUT size
        if (abs_gx >= `LUT_ATAN_SIZE/2 || abs_gy >= `LUT_ATAN_SIZE/2) begin
            lut_value = 0; // Handle out-of-range values gracefully
        end else begin
            lut_value = lut[abs_gx][abs_gy]; // Look up the LUT
        end

        // Adjust result based on quadrant
        if (gx >= 0 && gy >= 0) begin
            atan = lut_value; // First quadrant
        end else if (gx < 0 && gy >= 0) begin
            atan = 90 - lut_value; // Second quadrant
        end else if (gx < 0 && gy < 0) begin
            atan = -90 + lut_value; // Third quadrant
        end else begin
            atan = -lut_value; // Fourth quadrant
        end
    end

endmodule
