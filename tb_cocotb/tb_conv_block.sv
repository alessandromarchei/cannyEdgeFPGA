module conv_block (
    input i_clk;
    input [NBIT-1] i_data [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];    //pixels entering the convolution block
    input i_data_valid;     //indicating when to perform the MAC

    //data for the kernel block
    input [NBIT-1:0] i_kernel [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];    //to change the kernel
    input i_kernel_valid;   //indicating the new kernel to load

    output [NBIT-1:0] o_pixel;  //computed pixel at the otput
);

//declare KERNEL_SIZE**2 signal data as output of the multipliers
wire [(NBIT)*(NBIT)-1:0] out_mul [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];

//separating the input data which is continuous, into KERNEL_SIZE**2 pixels
genvar i,j;
reg [NBIT-1:0] kernel_matrix [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];

//in this module we need to perfor #MUL = KERNEL_SIZE*KERNEL_SIZE, and a #ADDS = KERNEL_SIZE*KERNEL_SIZE-1

//perform each multiplication in parallel
always @(posedge i_clk) begin
    for (i = 0;i < KERNEL_SIZE;i = i+1) begin
        for (j = 0;j < KERNEL_SIZE;j = j+1) begin
        //generate the multiplication signals. it is combinatorial, so use non-blocking assignments
            assign out_mul[i][j] = kernel_weigths[i][j] * i_data[i][j];
        end 
    end
end

//process for loading the kernel weigths into the matrix
always @(posedge i_clk) begin
    //BLOCKING-ASSIGNMENTS, so save on the next clock cycle
    for (i = 0;i < KERNEL_SIZE ;i = i+1 ) begin
        for (j = 0;j < KERNEL_SIZE ;j = j+1 ) begin
            //now save the weigths into the kernel matrix
            kernel_matrix[i][j] <= i_kernel[i][j];
        end
    end


end


    
endmodule