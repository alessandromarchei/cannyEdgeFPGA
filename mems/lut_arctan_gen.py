import numpy as np
import re

# Parameters for LUT computation
DELTA = 0.01  # Step size for ground truth grid

def parse_lut_size(params_file):
    """
    Parse the LUT_SIZE and NBIT_SOBEL parameters from the params.sv file.

    Parameters:
    params_file (str): Path to the SystemVerilog parameters file.

    Returns:
    tuple: Extracted LUT_SIZE and NBIT_SOBEL values.
    """
    with open(params_file, "r") as f:
        content = f.read()
    
    # Regular expressions to find the definitions
    match_lut_size = re.search(r"`define\s+LUT_ATAN_SIZE\s+(\d+)", content)
    match_nbit_sobel = re.search(r"`define\s+NBIT_SOBEL\s+(\d+)", content)
    if match_lut_size and match_nbit_sobel:
        return int(match_lut_size.group(1)), int(match_nbit_sobel.group(1))
    else:
        raise ValueError("LUT_SIZE or NBIT_SOBEL not defined in params.sv file.")

def compute_arctan_lut(max_value, lut_size, nbit_sobel):
    """
    Compute the LUT for arctangent approximation.

    Parameters:
    max_value (float): Maximum value for both x and y.
    lut_size (int): Total size of the LUT.
    nbit_sobel (int): Bit width for signed LUT values.

    Returns:
    ndarray: LUT values as a 2D array.
    """
    # Calculate LUT dimension (sqrt of LUT_SIZE)
    
    lut_dim = int(np.sqrt(lut_size))  # e.g., for 1024 LUT_SIZE, we get a 32x32 grid
    lut_step = 1

    print(f"lut dim {lut_dim}")
    print(f"lut step {lut_step}")
    print(f"lut size {lut_size}")


    # LUT array
    lut = np.zeros((lut_dim, lut_dim), dtype=int)

    # Bit range for signed values
    max_quantized_value = (2**(nbit_sobel - 1)) - 1
    min_quantized_value = -(2**(nbit_sobel - 1))

    # Populate the LUT
    for y_idx in range(lut_dim):
        for x_idx in range(lut_dim):
            x = x_idx * lut_step
            y = y_idx * lut_step
            angle = np.arctan2(y, x)  # Compute arctan2

            print(f"arctan {y}/{x} : {angle*180/np.pi}")

            # Normalize angle to range [-π, π]
            normalized_angle = angle / np.pi

            # Quantize to nbit_sobel range
            quantized_value = int(normalized_angle * max_quantized_value)

            # Clamp the value within the allowed range
            quantized_value = max(min(quantized_value, max_quantized_value), min_quantized_value)

            # Store the quantized value in the LUT
            lut[y_idx, x_idx] = quantized_value

    return lut

# Example usage
if __name__ == "__main__":
# Path to the params.sv file
    src_path = "../src/"
    params_name = "params.sv"

    params_file = src_path + params_name

    # Parse LUT parameters
    lut_size, nbit_sobel = parse_lut_size(params_file)

    # Compute the LUT
    lut = compute_arctan_lut(int(np.sqrt(lut_size)), lut_size, nbit_sobel)

    # Save LUT to file or use it as needed
    np.savetxt("lut_arctan.mem", lut, fmt="%d")


# if __name__ == "__main__":
#     # Path to the params.sv file
#     src_path = "../src/"
#     params_name = "params.sv"

#     params_file = src_path + params_name

#     # Extract LUT_SIZE from the params.sv file
#     try:
#         lut_size,nbit_sobel = parse_lut_size(params_file)
#         print(f"LUT_SIZE extracted: {lut_size}")
#         print(f"NBIT SOBEL extracted: {nbit_sobel}")
#     except ValueError as e:
#         print(e)
#         exit(1)

#     # Compute the LUT
#     lut = compute_arctan_lut(int(np.sqrt(lut_size)), lut_size, nbit_sobel)

#     # Save the LUT to a .mem file
#     save_lut_to_mem(lut,nbit_sobel, "lut_arctan.mem")
#     print("LUT saved to lut_arctan.mem")