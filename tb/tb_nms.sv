// Testbench for Canny Edge Detector with Non-Maximum Suppression
// This testbench loads an image from a file, processes it using FPGA modules, and outputs the NMS result.
`include "../src/params.sv"
`timescale 1ns / 1ns


module tb_nms();

    parameter NBIT = 8;
    parameter KERNEL_SIZE = 3;
    parameter IMAGE_WIDTH = `IM_WIDTH;  // Adjust according to image size
    parameter IMAGE_HEIGHT = `IM_HEIGHT;  // Adjust according to image size
    parameter FRAC_BITS = 10;

    // Clock and reset signals
    reg clk;
    reg reset;

    // Memory to store input image pixels
    reg [8-1:0] image_memory [0:IMAGE_HEIGHT-1][0:IMAGE_WIDTH-1];

    // Signals for intermediate and final results
    wire [8-1:0] gaussian_output[0:IMAGE_HEIGHT-KERNEL_SIZE][0:IMAGE_WIDTH-KERNEL_SIZE];
    wire signed [10:0] gx[0:IMAGE_HEIGHT-KERNEL_SIZE*2 + 1][0:IMAGE_WIDTH-KERNEL_SIZE*2+1];
    wire signed [10:0] gy[0:IMAGE_HEIGHT-KERNEL_SIZE*2 + 1][0:IMAGE_WIDTH-KERNEL_SIZE*2+1];
    wire [11:0] gradient_magnitude[0:IMAGE_HEIGHT-KERNEL_SIZE*2 + 1][0:IMAGE_WIDTH-KERNEL_SIZE*2+1];
    wire [1:0] gradient_direction[0:IMAGE_HEIGHT-KERNEL_SIZE*2 + 1][0:IMAGE_WIDTH-KERNEL_SIZE*2+1];
    wire [7:0] nms_output[0:IMAGE_HEIGHT-KERNEL_SIZE*3 + 2][0:IMAGE_WIDTH-KERNEL_SIZE*3 + 2];
    wire [7:0] threshold_output[0:IMAGE_HEIGHT-KERNEL_SIZE*3 + 2][0:IMAGE_WIDTH-KERNEL_SIZE*3 + 2];
    reg [FRAC_BITS-1:0] i_kernel [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
    reg i_data_valid;
    reg i_kernel_valid;


    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Load image data from file into memory
    initial begin
        $readmemh("lena.hex", image_memory);  // Load image as hex values
        reset = 0;
        for(int i = 0;i < IMAGE_HEIGHT; i = i + 1) begin
            for(int j = 0;j < IMAGE_WIDTH; j = j + 1) begin
                //$display("image_memory[%0d][%0d] = %h", i, j, image_memory[i][j]);
            end
        end
        #10 reset = 0;
    end

    // Generate blocks for parallelized computation

    genvar i,j;
    genvar x,y;
    genvar a,b;

    // Gaussian filtering blocks
    generate
        for (i = 0; i < IMAGE_HEIGHT - KERNEL_SIZE + 1; i = i + 1) begin : gaussian_row
            for (j = 0; j < IMAGE_WIDTH - KERNEL_SIZE + 1; j = j + 1) begin : gaussian_col
                wire [8-1:0] gaussian_input[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
                for (x = 0; x < KERNEL_SIZE; x = x + 1) begin
                    for (y = 0; y < KERNEL_SIZE; y = y + 1) begin
                        assign gaussian_input[x][y] = image_memory[i + x][j + y];
                    end
                end

                conv_block_gaussian #(
                    .NBIT(8),
                    .KERNEL_SIZE(KERNEL_SIZE),
                    .FRAC_BITS(FRAC_BITS)
                ) gaussian (
                    .i_clk(clk),
                    .i_data(gaussian_input),
                    .i_data_valid(1'b1),
                    .i_kernel(i_kernel),
                    .i_kernel_valid(1'b1),
                    .o_pixel(gaussian_output[i][j])
                );
            end
        end
    endgenerate

    // Sobel blocks
    generate
        for (i = 0; i < IMAGE_HEIGHT - KERNEL_SIZE*2 + 2; i = i + 1) begin : sobel_row
            for (j = 0; j < IMAGE_WIDTH - KERNEL_SIZE*2 + 2; j = j + 1) begin : sobel_col
                wire [NBIT-1:0] sobel_input[KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
                for (x = 0; x < KERNEL_SIZE; x = x + 1) begin
                    for (y = 0; y < KERNEL_SIZE; y = y + 1) begin
                        assign sobel_input[x][y] = gaussian_output[i + x][j + y];
                    end
                end

                conv_block_sobel #(
                    .NBIT(NBIT),
                    .KERNEL_SIZE(KERNEL_SIZE)
                ) sobel (
                    .i_clk(clk),
                    .i_data(sobel_input),
                    .i_data_valid(1'b1),
                    .gx(gx[i][j]),
                    .gy(gy[i][j])
                );
            end
        end
    endgenerate

    // Gradient magnitude and direction blocks
    generate
        for (i = 0; i < IMAGE_HEIGHT - KERNEL_SIZE*2 + 2; i = i + 1) begin : mag_row
            for (j = 0; j < IMAGE_WIDTH - KERNEL_SIZE*2 + 2; j = j + 1) begin : mag_col

                sobel_magnitude #(
                    .NBIT(11)
                ) sobel_mag (
                    .i_clk(clk),
                    .i_data_valid(1'b1),
                    .gx(gx[i][j]),
                    .gy(gy[i][j]),
                    .module_g(gradient_magnitude[i][j])
                );
            end
        end
    endgenerate

    // DIRECTION blocks
    generate
        for (i = 0; i < IMAGE_HEIGHT - KERNEL_SIZE*2 + 2; i = i + 1) begin : arctan_row
            for (j = 0; j < IMAGE_WIDTH - KERNEL_SIZE*2 + 2; j = j + 1) begin : arctan_col

                sobel_arctan #(
                    .NBIT_SOBEL(11)
                ) sobel_dir (
                    .i_clk(clk),
                    .gx(gx[i][j]),
                    .gy(gy[i][j]),
                    .angle_range(gradient_direction[i][j])
                );
            end
        end
    endgenerate

    // NMS blocks
    generate
        for (i = 0; i < IMAGE_HEIGHT - KERNEL_SIZE*3 + 3; i = i + 1) begin : nms_row
            for (j = 0; j < IMAGE_WIDTH - KERNEL_SIZE*3 + 3; j = j + 1) begin : nms_col
                wire [11:0] nms_input_block[2:0][2:0];
                for (x = 0; x < 3; x = x + 1) begin
                    for (y = 0; y < 3; y = y + 1) begin
                        assign nms_input_block[x][y] = gradient_magnitude[i + x][j + y];
                    end
                end

                nms #(
                    .NBIT_INPUT(12)
                ) nms_block (
                    .i_clk(clk),
                    .i_block(nms_input_block),
                    .direction(gradient_direction[i][j]),
                    .nms_output(nms_output[i][j])
                );

            end
        end
    endgenerate

    generate
        for(a = 0;a < IMAGE_HEIGHT-KERNEL_SIZE*3 + 3;a = a + 1) begin : thresh_row
            for(b = 0;b < IMAGE_WIDTH-KERNEL_SIZE*3 + 3;b = b + 1) begin : thresh_col
                threshold #(.HIGH_THRESHOLD(100), .HIGH_VALUE(255), .LOW_VALUE(0))
                    uut_threshold(
                        .i_clk(clk),
                        .input_pixel(nms_output[a][b]),
                        .output_pixel(threshold_output[a][b])
                    );
        end
    end
    endgenerate



    // Task to read kernel weights from a file and convert them to fixed-point
    task load_kernel_from_file(input string file_name);
        integer file, i, j;
        real kernel_value_flt;
        reg [FRAC_BITS:0] kernel_value_fixed;
        real scale_factor; // scale factor for converting float to fixed-point

        begin
            // Scale factor: decide based on how many fractional bits you want (e.g., Q1.7 for 8-bit)
            scale_factor = (1 << FRAC_BITS);
            $display("scale factor : %d", scale_factor);

            file = $fopen(file_name, "r");
            if (file == 0) begin
                $display("ERROR: Could not open file %s", file_name);
                $finish;
            end

            // Read kernel values from file and convert to fixed-point
            for (i = 0; i < KERNEL_SIZE; i = i + 1) begin
                for (j = 0; j < KERNEL_SIZE; j = j + 1) begin
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


    initial begin

                // Initialize signals
        i_data_valid = 0;
        i_kernel_valid = 0;

        // Load kernel weights from file and convert them to fixed-point
        load_kernel_from_file("kernel_gaussian.txt");

        // Apply kernel to DUT
        i_kernel_valid = 1;
        @(posedge clk);
        i_kernel_valid = 0;
    end

    // Save NMS output to file
    integer outfile;
    integer threshold_file;


initial begin
    integer clk_counter = 0;  // Clock cycle counter
    outfile = $fopen("../output_files/nms_output.hex", "w");
    threshold_file = $fopen("../output_files/thresh_output.hex", "w");
    $display("Waiting for processing to complete");

    // Wait for 5 clock cycles
    @(posedge clk);
    repeat (5) @(posedge clk);

    // Start writing the output
    for (int i = 0; i < IMAGE_HEIGHT - KERNEL_SIZE*3 + 3; i = i + 1) begin
        for (int j = 0; j < IMAGE_WIDTH - KERNEL_SIZE*3 + 3; j = j + 1) begin
            // Write values in matrix form: Add a space between columns, write a newline at the end of each row
            if (j == IMAGE_WIDTH - KERNEL_SIZE*3 + 2) begin
                $fwrite(outfile, "%h\n", nms_output[i][j]);  // End of row
            end else begin
                $fwrite(outfile, "%h ", nms_output[i][j]);  // Space-separated values
            end

        end
    end

    $fclose(outfile);  // Close the file after writing
    $display("Processing complete. Output written to file.");
end


initial begin
    integer clk_counter = 0;  // Clock cycle counter
    threshold_file = $fopen("../output_files/thresh_output.hex", "w");

    // Wait for 5 clock cycles
    @(posedge clk);
    repeat (5) @(posedge clk);

    // Start writing the output
    for (int i = 0; i < IMAGE_HEIGHT - KERNEL_SIZE*3 + 3; i = i + 1) begin
        for (int j = 0; j < IMAGE_WIDTH - KERNEL_SIZE*3 + 3; j = j + 1) begin
            // Write values in matrix form: Add a space between columns, write a newline at the end of each row
            if (j == IMAGE_WIDTH - KERNEL_SIZE*3 + 2) begin
                $fwrite(threshold_file, "%h\n", threshold_output[i][j]);  // End of row
            end else begin
                $fwrite(threshold_file, "%h ", threshold_output[i][j]);  // Space-separated values
            end

        end
    end

    $fclose(threshold_file);  // Close the file after writing
    $display("Processing complete. Output written to file.");
end

endmodule
