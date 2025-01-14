module reduction_tree #(parameter NBIT = 8, NUM_ADDENDS = 8) (
    input [NBIT-1:0] data_in [NUM_ADDENDS-1:0],
    output [NBIT+$clog2(NUM_ADDENDS)-1:0] result
);

    genvar i, level;

    // Array to hold intermediate sums
    wire [NBIT+$clog2(NUM_ADDENDS)-1:0] sums[0:$clog2(NUM_ADDENDS)][0:NUM_ADDENDS-1];

    // Assign input data to the first level of sums
    generate
        for (i = 0; i < NUM_ADDENDS; i = i + 1) begin
            assign sums[0][i] = data_in[i];
        end
    endgenerate

    // Perform pairwise reductions at each level
    generate
        for (level = 1; level <= $clog2(NUM_ADDENDS); level = level + 1) begin
            // Compute the number of inputs at the current level
            localparam int inputs_at_level = (NUM_ADDENDS + (1 << (level - 1)) - 1) >> level;

            for (i = 0; i < inputs_at_level / 2; i = i + 1) begin
                assign sums[level][i] = sums[level-1][2*i] + sums[level-1][2*i+1];
            end

            // Handle odd number of inputs by passing through the last element
            if (inputs_at_level % 2 != 0) begin
                assign sums[level][inputs_at_level / 2] = sums[level-1][inputs_at_level - 1];
            end
        end
    endgenerate

    // Final result is the top of the tree
    assign result = sums[$clog2(NUM_ADDENDS)][0];

endmodule
