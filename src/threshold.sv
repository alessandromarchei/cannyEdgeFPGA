`include "params.sv"

module threshold #(
    parameter HIGH_THRESHOLD = 100,   // High threshold for the magnitude values
    parameter HIGH_VALUE = 255,
    parameter LOW_VALUE = 0
)(
    input wire i_clk,
    input wire [7:0] input_pixel,
    output reg [7:0] output_pixel
);


always @(posedge i_clk) begin
    //check if the input is greater than the threshold
    if(input_pixel >= HIGH_THRESHOLD) begin
        output_pixel <= HIGH_VALUE;
    end
    else output_pixel <= LOW_VALUE;
end

endmodule
