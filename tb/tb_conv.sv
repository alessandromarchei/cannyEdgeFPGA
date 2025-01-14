`timescale 1ns / 1ps
`include "../src/params.sv"

module tb_conv();
    
    // Clock and signals
    reg i_clk;
    reg i_data_valid;
    reg i_kernel_valid;
    reg [`NBIT-1:0] i_data [`KERNEL_SIZE-1:0][`KERNEL_SIZE-1:0];
    reg [`NBIT-1:0] i_kernel [`KERNEL_SIZE-1:0][`KERNEL_SIZE-1:0];
    wire [`NBIT*`NBIT+$clog2(`KERNEL_SIZE*`KERNEL_SIZE)-1:0] o_pixel;

    // Instantiate the DUT
    conv_block #(
        .NBIT(`NBIT),
        .KERNEL_SIZE(`KERNEL_SIZE),
        .FRAC_BITS(`FRAC_BITS)
    ) uut (
        .i_clk(i_clk),
        .i_data(i_data),
        .i_data_valid(i_data_valid),
        .i_kernel(i_kernel),
        .i_kernel_valid(i_kernel_valid),
        .o_pixel(o_pixel)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;  // 10 ns clock period
    end

    // Task to read kernel weights from a file and convert them to fixed-point
    task load_kernel_from_file(input string file_name);
        integer file, i, j;
        real kernel_value_flt;
        reg [`NBIT-1:0] kernel_value_fixed;
        real scale_factor; // scale factor for converting float to fixed-point

        begin
            // Scale factor: decide based on how many fractional bits you want (e.g., Q1.7 for 8-bit)
            scale_factor = (1 << `FRAC_BITS);
            $display("scale factor : %d", scale_factor);

            file = $fopen(file_name, "r");
            if (file == 0) begin
                $display("ERROR: Could not open file %s", file_name);
                $finish;
            end

            // Read kernel values from file and convert to fixed-point
            for (i = 0; i < `KERNEL_SIZE; i = i + 1) begin
                for (j = 0; j < `KERNEL_SIZE; j = j + 1) begin
                    if (!$feof(file)) begin
                        $fscanf(file, "%f", kernel_value_flt);
                        kernel_value_fixed = $rtoi(kernel_value_flt * scale_factor);  // Convert to fixed-point
                        i_kernel[i][j] = kernel_value_fixed;
                        $display("Kernel[%0d][%0d] = %.5f (fixed-point: %d)", i, j, kernel_value_flt, kernel_value_fixed);
                    end else begin
                        $display("ERROR: Insufficient data in file %s", file_name);
                        $finish;
                    end
                end
            end
            $fclose(file);
        end
    endtask

    // Task to generate random pixel data
    task generate_random_pixels();
        integer i, j;
        begin
            for (i = 0; i < `KERNEL_SIZE; i = i + 1) begin
                for (j = 0; j < `KERNEL_SIZE; j = j + 1) begin
                    //i_data[i][j] = $urandom_range(0, (1 << `NBIT) - 1);
                    i_data[i][j] = $urandom_range(1, 5);
                end
            end
        end
    endtask

    // Testbench logic
    initial begin
        // Initialize signals
        i_data_valid = 0;
        i_kernel_valid = 0;

        // Load kernel weights from file and convert them to fixed-point
        load_kernel_from_file("kernel_config.txt");

        // Apply kernel to DUT
        i_kernel_valid = 1;
        @(posedge i_clk);
        i_kernel_valid = 0;

        // Generate random pixel data and apply to DUT
        repeat (`NUM_TESTS) begin  // Perform 100 random tests
            generate_random_pixels();
            i_data_valid = 1;
            @(posedge i_clk);
            i_data_valid = 0;
            @(posedge i_clk);  // Wait for result
        end
    end

endmodule
