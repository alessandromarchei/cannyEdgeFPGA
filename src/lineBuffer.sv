module lineBuffer  #(
    parameter NBIT = 8,          // Define NBIT (bit-width)
    parameter KERNEL_SIZE = 3,    // Define KERNEL_SIZE (size of the kernel)
    parameter IMAGE_WIDTH=512
)(
    input i_clk,
    input i_rst,
    input [NBIT-1:0] i_data_byte,
    input i_wr_valid,
    input i_rd_valid,

    output [KERNEL_SIZE*(NBIT)-1:0] o_data
);

//internal signals
reg [NBIT-1:0] buffer [IMAGE_WIDTH-1:0];     //memory line buffer, containing 1 byte of data for each line
reg [($clog2(IMAGE_WIDTH))-1:0] wr_ptr;        //pointer for the data into memory
reg [($clog2(IMAGE_WIDTH))-1:0] rd_ptr;

assign o_data = {buffer[rd_ptr+'d2],buffer[rd_ptr+'d1],buffer[rd_ptr]};

//process for the datapath
always @(posedge i_clk ) begin
    //laod the data inot the buffer when the input is valid
    if(i_wr_valid) begin
        buffer[wr_ptr] <= i_data_byte;  //write into the buffer
    end
end

//WRITE PROCESS
always @(posedge i_clk ) begin
    if (i_rst == 'd1) begin
        //reset the write pointer
        wr_ptr <= 'd0;
    end
    else if(i_wr_valid) begin
        wr_ptr <= wr_ptr + 'd1;
    end
end

//READ process
always @(posedge i_clk ) begin
    if (i_rst == 'd1) begin
        //reset the write pointer
        rd_ptr <= 'd0;
    end
    else if(i_rd_valid) begin
        rd_ptr <= rd_ptr + 'd1;     //increment by 1 because we are shifting by one, so no worries about it
    end
end
    
endmodule