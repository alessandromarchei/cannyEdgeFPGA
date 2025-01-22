module sobel_arctan #(
    parameter NBIT_SOBEL = 11
)(
    input i_clk,
    input signed [NBIT_SOBEL-1:0] gy,  // G_y
    input signed [NBIT_SOBEL-1:0] gx,  // G_x
    output reg [1:0] angle_range // Output direction
);

// Internal variables
real angle;

// Mapping function for angle to range
always @(posedge i_clk) begin
    // Compute the angle using the Verilog $atan2 function
    angle = $atan2(gy, gx) * 180.0 / 3.14159265359; // Convert from radians to degrees

    // Normalize the angle to [-180, 180]
    if (angle > 180.0)
        angle = angle - 360.0;
    else if (angle < -180.0)
        angle = angle + 360.0;

    // Map the normalized angle to a 2-bit range
    if ((angle >= -22.5 && angle <= 22.5) || (angle >= 157.5 || angle <= -157.5)) begin
        angle_range <= 2'b00; // Horizontal
    end else if ((angle > 22.5 && angle <= 67.5) || (angle > -157.5 && angle <= -112.5)) begin
        angle_range <= 2'b01; // Diagonal (45 degrees)
    end else if ((angle > 67.5 && angle <= 112.5) || (angle > -112.5 && angle <= -67.5)) begin
        angle_range <= 2'b10; // Vertical
    end else if ((angle > 112.5 && angle <= 157.5) || (angle > -67.5 && angle <= -22.5)) begin
        angle_range <= 2'b11; // Diagonal (135 degrees)
    end else begin
        angle_range <= 2'b00; // Default case (could be handled differently if required)
    end
end

endmodule
