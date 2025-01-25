import numpy as np
from scipy.ndimage import gaussian_filter

import numpy as np

def apply_convolution(pixel_matrix, kernel_size, sigma):
    """
    Applies convolution to the input pixel matrix using a Gaussian filter.
    Returns a single convolved value.
    
    Parameters:
        pixel_matrix (np.ndarray): Input matrix with pre-stored values.
        kernel_size (int): Size of the Gaussian kernel (e.g., 3 for a 3x3 kernel).
        sigma (float): Standard deviation of the Gaussian filter.
    
    Returns:
        float: The single convolved value.
    """
    # Generate a Gaussian filter kernel
    kernel_radius = kernel_size // 2
    x = np.linspace(-kernel_radius, kernel_radius, kernel_size)
    gaussian_1d = np.exp(-0.5 * (x / sigma) ** 2)
    gaussian_1d /= gaussian_1d.sum()
    kernel = np.outer(gaussian_1d, gaussian_1d)  # Create a 2D Gaussian kernel

    print("Gaussian Kernel:")
    print(kernel)

    # Ensure the input matrix is the same size as the kernel
    if pixel_matrix.shape != (kernel_size, kernel_size):
        raise ValueError(f"Input pixel matrix must be {kernel_size}x{kernel_size} for this operation.")
    
    # Perform element-wise multiplication and sum the results
    convolved_value = np.sum(pixel_matrix * kernel)

    return convolved_value
# Input pixel matrix (pre-stored values)
pixel_matrix = np.array([
    [115, 109, 103],
    [80, 125, 164],
    [116, 124, 129]
], dtype=float)

# Parameters for the Gaussian filter
kernel_size = 3  # Example: 3x3 kernel
sigma = 1.0      # Standard deviation

# Apply convolution
output_matrix = apply_convolution(pixel_matrix, kernel_size, sigma)

# Print the input and output matrices
print("Input Pixel Matrix:")
print(pixel_matrix)
print("\nOutput Matrix (After Convolution):")
print(output_matrix)