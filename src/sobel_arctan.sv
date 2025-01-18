module arctan_lut #(
    parameter NBIT_SOBEL = 16
    
)(
    input signed[NBIT_SOBEL-1:0] gy,   // G_y
    input signed [NBIT_SOBEL-1:0] gx,   // G_x
    output signed [NBIT_SOBEL-1:0] angle //
);
    logic [9:0] ratio;  // Quantized ratio for LUT
    logic [15:0] lut [0:1023]; // Precomputed LUT

    initial begin
        $readmemh("arctan_lut.mem", lut); // Load LUT from file
    end

    always_comb begin
        // Normalize ratio and handle division by zero
        if (gx == 0) begin
            ratio = (gy > 0) ? 1023 : 0;
        end else begin
            ratio = (gy <<< 10) / gx; // Scale to LUT index range
        end

        // Fetch LUT value and adjust for quadrant
        if (gx > 0 && gy >= 0) begin
            angle = lut[ratio]; // 1st quadrant
        end else if (gx < 0 && gy >= 0) begin
            angle = 180 - lut[~ratio]; // 2nd quadrant
        end else if (gx < 0 && gy < 0) begin
            angle = -180 + lut[~ratio]; // 3rd quadrant
        end else begin
            angle = -lut[ratio]; // 4th quadrant
        end
    end
endmodule
