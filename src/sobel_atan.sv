module sobel_atan #(
    parameter NBIT_SOBEL = 11
)(
    input i_clk,
    input signed [NBIT_SOBEL-1:0] gy,  // G_y
    input signed [NBIT_SOBEL-1:0] gx,  // G_x
    output logic [1:0] o_direction // Output direction
);

logic [NBIT_SOBEL-2:0] abs_gx,abs_gy;        //absolute values of gx and gy
logic [3:0] addr_x,addr_y;                  //addresses for hte 2D lut
logic [1:0] lut_output; 
wire x_sign,y_sign;             //these signals store the sign of the input values

assign abs_gx = (gx < 0) ? -gx : gx;
assign abs_gy = (gy < 0) ? -gy : gy;

assign x_sign = gx[NBIT_SOBEL-1];
assign y_sign = gy[NBIT_SOBEL-1];


//now perform the LOG quantization on each of the inputs
lut_log_quantizer log_x(
    .input_value(abs_gx),
    .output_log(addr_x)
);

//now perform the LOG quantization on each of the inputs
lut_log_quantizer log_y(
    .input_value(abs_gy),
    .output_log(addr_y)
);

//now feed the ATAN LUT with the addresses
lut_atan LUT(
    .i_clk(i_clk),
    .x(addr_x),
    .y(addr_y),
    .direction(lut_output)
);


//now check if the output is of type DIAGONAL.
// This line assigns a value to the output direction signal (o_direction).
// The value assigned depends on the XOR result of x_sign and y_sign, and the second bit of o_direction.
// If the XOR of x_sign and y_sign is 1 and the second bit of o_direction is 1, 
// the output direction is set to the lookup table output (lut_output) ORed with 1.
// Otherwise, the output direction is set to the lookup table output (lut_output).
assign o_direction = (((x_sign ^ y_sign) == 1) && (lut_output[1] == 1)) ? (lut_output | 1'b1) : lut_output;


endmodule
