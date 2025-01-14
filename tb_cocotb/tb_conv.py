import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import random


    # Parameters
KERNEL_SIZE = 3  # Adjust according to your design
NBIT = 8         # Bit width of each data/kernel element


@cocotb.test()
async def tb_conv(dut):
    """Test convolution block."""

    
    # Generate a clock signal
    clock = Clock(dut.i_clk, 10, units="ns")  # 10ns period = 100MHz
    cocotb.start_soon(clock.start())

    # Initialize signals
    dut.i_data_valid.value = 0
    dut.i_kernel_valid.value = 0
    dut.i_data.value = 0
    dut.i_kernel.value = 0

    # Generate a random kernel and data matrix
    kernel = [[random.randint(0, 2**NBIT - 1) for _ in range(KERNEL_SIZE)] for _ in range(KERNEL_SIZE)]
    data = [[random.randint(0, 2**NBIT - 1) for _ in range(KERNEL_SIZE)] for _ in range(KERNEL_SIZE)]

    # Apply kernel weights
    dut.i_kernel_valid.value = 1
    for i in range(KERNEL_SIZE):
        for j in range(KERNEL_SIZE):
            dut.i_kernel[i][j].value = kernel[i][j]
    await RisingEdge(dut.i_clk)
    dut.i_kernel_valid.value = 0

    # Apply input data and validate MAC computation
    dut.i_data_valid.value = 1
    for i in range(KERNEL_SIZE):
        for j in range(KERNEL_SIZE):
            dut.i_data[i][j].value = data[i][j]
    await RisingEdge(dut.i_clk)
    dut.i_data_valid.value = 0

    # Wait for the output
    await Timer(10, units="ns")

    # Compute expected output manually (pure Python)
    expected_pixel = sum(
        kernel[i][j] * data[i][j] for i in range(KERNEL_SIZE) for j in range(KERNEL_SIZE)
    )

    # Assert the output
    actual_pixel = dut.o_pixel.value.signed_integer  # If `o_pixel` is signed
    assert actual_pixel == expected_pixel, f"Output mismatch: Expected {expected_pixel}, got {actual_pixel}"
