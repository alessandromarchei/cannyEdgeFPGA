`include "params.sv"

module lut_atan (
    input wire i_clk,
    input logic [3:0] x,  // input x
    input logic [3:0] y,  // input y
    output reg [1:0] direction // output
);


localparam int MAX_VALUE = 1021;
localparam int X_SIZE = $clog2(MAX_VALUE);

// LUT for the first quadrant (positive gx and gy only)
reg [1:0] lut [0:X_SIZE-1][0:X_SIZE-1];

/*
INSERT HERE THE LUT CONTENT
*/
    initial begin
        lut[0][0] = 2'b00;
        lut[0][1] = 2'b01;
        lut[0][2] = 2'b01;
        lut[0][3] = 2'b01;
        lut[0][4] = 2'b01;
        lut[0][5] = 2'b01;
        lut[0][6] = 2'b01;
        lut[0][7] = 2'b01;
        lut[0][8] = 2'b01;
        lut[0][9] = 2'b01;
        lut[1][0] = 2'b00;
        lut[1][1] = 2'b10;
        lut[1][2] = 2'b01;
        lut[1][3] = 2'b01;
        lut[1][4] = 2'b01;
        lut[1][5] = 2'b01;
        lut[1][6] = 2'b01;
        lut[1][7] = 2'b01;
        lut[1][8] = 2'b01;
        lut[1][9] = 2'b01;
        lut[2][0] = 2'b00;
        lut[2][1] = 2'b00;
        lut[2][2] = 2'b10;
        lut[2][3] = 2'b10;
        lut[2][4] = 2'b01;
        lut[2][5] = 2'b01;
        lut[2][6] = 2'b01;
        lut[2][7] = 2'b01;
        lut[2][8] = 2'b01;
        lut[2][9] = 2'b01;
        lut[3][0] = 2'b00;
        lut[3][1] = 2'b00;
        lut[3][2] = 2'b10;
        lut[3][3] = 2'b10;
        lut[3][4] = 2'b10;
        lut[3][5] = 2'b01;
        lut[3][6] = 2'b01;
        lut[3][7] = 2'b01;
        lut[3][8] = 2'b01;
        lut[3][9] = 2'b01;
        lut[4][0] = 2'b00;
        lut[4][1] = 2'b00;
        lut[4][2] = 2'b00;
        lut[4][3] = 2'b10;
        lut[4][4] = 2'b10;
        lut[4][5] = 2'b10;
        lut[4][6] = 2'b01;
        lut[4][7] = 2'b01;
        lut[4][8] = 2'b01;
        lut[4][9] = 2'b01;
        lut[5][0] = 2'b00;
        lut[5][1] = 2'b00;
        lut[5][2] = 2'b00;
        lut[5][3] = 2'b00;
        lut[5][4] = 2'b10;
        lut[5][5] = 2'b10;
        lut[5][6] = 2'b10;
        lut[5][7] = 2'b01;
        lut[5][8] = 2'b01;
        lut[5][9] = 2'b01;
        lut[6][0] = 2'b00;
        lut[6][1] = 2'b00;
        lut[6][2] = 2'b00;
        lut[6][3] = 2'b00;
        lut[6][4] = 2'b00;
        lut[6][5] = 2'b10;
        lut[6][6] = 2'b10;
        lut[6][7] = 2'b10;
        lut[6][8] = 2'b01;
        lut[6][9] = 2'b01;
        lut[7][0] = 2'b00;
        lut[7][1] = 2'b00;
        lut[7][2] = 2'b00;
        lut[7][3] = 2'b00;
        lut[7][4] = 2'b00;
        lut[7][5] = 2'b00;
        lut[7][6] = 2'b10;
        lut[7][7] = 2'b10;
        lut[7][8] = 2'b10;
        lut[7][9] = 2'b01;
        lut[8][0] = 2'b00;
        lut[8][1] = 2'b00;
        lut[8][2] = 2'b00;
        lut[8][3] = 2'b00;
        lut[8][4] = 2'b00;
        lut[8][5] = 2'b00;
        lut[8][6] = 2'b00;
        lut[8][7] = 2'b10;
        lut[8][8] = 2'b10;
        lut[8][9] = 2'b10;
        lut[9][0] = 2'b00;
        lut[9][1] = 2'b00;
        lut[9][2] = 2'b00;
        lut[9][3] = 2'b00;
        lut[9][4] = 2'b00;
        lut[9][5] = 2'b00;
        lut[9][6] = 2'b00;
        lut[9][7] = 2'b00;
        lut[9][8] = 2'b10;
        lut[9][9] = 2'b10;
    end


always @(posedge i_clk) begin
    direction <= lut[x][y];
end


endmodule
