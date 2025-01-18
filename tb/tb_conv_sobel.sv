`timescale 1ns / 1ps
`include "../src/params.sv"


module tb_conv_sobel();

    // Clock and signals
    reg i_clk;
    reg i_data_valid;
    reg [`NBIT-1:0] i_data [`KERNEL_SIZE-1:0][`KERNEL_SIZE-1:0];
    wire signed [`NBIT+$clog2(6)-1:0] gx;
    wire signed [`NBIT+$clog2(6)-1:0] gy;

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
            i_data_valid = 0;
            @(posedge i_clk);  // Wait for one clock cycle
            $display("G : (%d,%d)", gx, gy);
        end

        $stop;
    end

endmodule
