`timescale 1ns / 1ps
`include "../src/params.sv"


module tb_conv_sobel_nms();

    // Clock and signals
    reg i_clk;
    reg i_data_valid;
    reg [`NBIT-1:0] i_data [`KERNEL_SIZE-1:0][`KERNEL_SIZE-1:0];
    wire signed [$clog2((`NBIT+1)*3) + `NBIT-1:0] gx;
    wire signed [$clog2((`NBIT+1)*3) + `NBIT-1:0] gy;

    reg [$clog2((`NBIT+1)*3) + `NBIT:0] module_g;
    reg [1:0] angle_range;

    // Instantiate the DUT
    conv_block_sobel #(
        .NBIT(`NBIT),
        .KERNEL_SIZE(`KERNEL_SIZE)
    ) uut (
        .i_clk(i_clk),
        .i_data(i_data),
        .i_data_valid(i_data_valid),
        .gx(gx),
        .gy(gy)
    );

    sobel_arctan uut_atan
    (
        .i_clk(i_clk),
        .gx(gx),   // G_y
        .gy(gy),   // G_x
        .angle_range(angle_range) //
    );

    sobel_magnitude uut_mag
    (
        .i_clk(i_clk),                                   // Clock signal
        .i_data_valid('b1),                             // Valid signal for input data
        .gx(gx),
        .gy(gy),
        .module_g(module_g)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;  // 10 ns clock period
    end

    // Task to generate random pixel data
    task generate_random_pixels();
        integer i, j;
        begin
            for (i = 0; i < `KERNEL_SIZE; i = i + 1) begin
                for (j = 0; j < `KERNEL_SIZE; j = j + 1) begin
                    i_data[i][j] = $urandom_range(-(1 << (`NBIT-1)), (1 << (`NBIT-1)) - 1);
                end
            end
        end
    endtask

    // Testbench logic
    initial begin
        // Initialize signals
        i_data_valid = 0;

        // Test with random pixel data for multiple iterations
        $display("Testing with random pixel data...");
        repeat (`NUM_TESTS) begin
            generate_random_pixels();
            i_data_valid = 1;
            @(posedge i_clk);
            i_data_valid = 1;
            @(posedge i_clk);  // Wait for one clock cycle
            $display("G : (%d,%d)", gx, gy);
        end

    end

endmodule
