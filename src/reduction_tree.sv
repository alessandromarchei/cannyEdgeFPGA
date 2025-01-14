module reduction_tree #(parameter NBIT = 8, NUM_ADDENDS = 8) (
    input [NBIT-1:0] data_in [0:NUM_ADDENDS-1],
    output [NBIT+$clog2(NUM_ADDENDS)-1:0] result
);

    genvar i, level;

    // Array to hold intermediate sums
    wire [NBIT+$clog2(NUM_ADDENDS)-1:0] sums [0:$clog2(NUM_ADDENDS)][0:NUM_ADDENDS-1];

    // Assign input data to the first level of sums
    generate
        for (i = 0; i < NUM_ADDENDS; i = i + 1) begin : assign_input
            assign sums[0][i] = data_in[i];
        end
    endgenerate

    // Perform pairwise reductions at each level
    generate
        for (level = 1; level <= $clog2(NUM_ADDENDS); level = level + 1) begin : levels
            localparam int num_elements_prev_level = (NUM_ADDENDS + (1 << (level - 1)) - 1) >> (level - 1);
            localparam int num_elements_curr_level = (num_elements_prev_level + 1) >> 1;

            for (i = 0; i < num_elements_curr_level; i = i + 1) begin : reduction_pairs
                if (2 * i + 1 < num_elements_prev_level) begin
                    // Perform addition for valid pairs
                    assign sums[level][i] = sums[level-1][2*i] + sums[level-1][2*i+1];
                end else begin
                    // Handle odd case by passing through the last element
                    assign sums[level][i] = sums[level-1][2*i];
                end
            end
        end
    endgenerate

    // Final result is the top of the tree
    assign result = sums[$clog2(NUM_ADDENDS)][0];

endmodule
