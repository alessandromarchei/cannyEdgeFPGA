`include "params.sv"

module lut_log_quantizer (
    input logic [9:0] input_value,  // 10-bit input value (0 to 1024)
    output logic [3:0] output_log // Corresponding log2 value (0 to 9)
);

    // Find the highest set bit using priority encoding
    assign output_log = (input_value >= 512) ? 9 :
                  (input_value >= 256) ? 8 :
                  (input_value >= 128) ? 7 :
                  (input_value >= 64)  ? 6 :
                  (input_value >= 32)  ? 5 :
                  (input_value >= 16)  ? 4 :
                  (input_value >= 8)   ? 3 :
                  (input_value >= 4)   ? 2 :
                  (input_value >= 2)   ? 1 : 
                  (input_value == 0)   ? 1 : 0;

endmodule
