import numpy as np
import cv2
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # Explicit import for 3D plotting

def compute_sobel(x, y, image):
    sobel_x = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]])
    sobel_y = np.array([[-1, -2, -1], [0, 0, 0], [1, 2, 1]])
    region = image[x-1:x+2, y-1:y+2]
    gx = np.sum(region * sobel_x)
    gy = np.sum(region * sobel_y)
    return gx, gy

def compute_errors(image):
    h, w = image.shape
    abs_error_sum = np.zeros((h, w))  # For abs(gx) + abs(gy)
    rel_error_sum = np.zeros((h, w))
    abs_error_weighted = np.zeros((h, w))  # For max-min weighted approximation
    rel_error_weighted = np.zeros((h, w))

    for x in range(1, h-1):  # Avoid border pixels
        for y in range(1, w-1):
            gx, gy = compute_sobel(x, y, image)
            g_true = np.sqrt(gx**2 + gy**2)
            
            # Approximation 1: abs(gx) + abs(gy)
            g_approx_sum = abs(gx) + abs(gy)
            abs_error_sum[x, y] = abs(g_true - g_approx_sum)
            rel_error_sum[x, y] = abs_error_sum[x, y] / g_true if g_true > 0 else 0
            
            # Approximation 2: max(|gx|, |gy|) + 0.5 * min(|gx|, |gy|)
            g_approx_weighted = max(abs(gx), abs(gy)) + 0.5 * min(abs(gx), abs(gy))
            abs_error_weighted[x, y] = abs(g_true - g_approx_weighted)
            rel_error_weighted[x, y] = abs_error_weighted[x, y] / g_true if g_true > 0 else 0

    return abs_error_sum, rel_error_sum, abs_error_weighted, rel_error_weighted

def plot_merged_2d(data1, data2, title1, title2, combined_title):
    fig, axs = plt.subplots(1, 2, figsize=(16, 8))
    
    # Plot first dataset
    im1 = axs[0].imshow(data1, cmap='viridis', aspect='auto')
    axs[0].set_title(title1)
    axs[0].set_xlabel('Pixel X')
    axs[0].set_ylabel('Pixel Y')
    fig.colorbar(im1, ax=axs[0], orientation='vertical')
    
    # Plot second dataset
    im2 = axs[1].imshow(data2, cmap='viridis', aspect='auto')
    axs[1].set_title(title2)
    axs[1].set_xlabel('Pixel X')
    axs[1].set_ylabel('Pixel Y')
    fig.colorbar(im2, ax=axs[1], orientation='vertical')
    
    # Combined title
    fig.suptitle(combined_title, fontsize=16)
    plt.tight_layout()
    plt.show()

# Load the grayscale image
image_path = 'lena.jpeg'  # Correct the file path
image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

if image is None:
    print(f"Error: Unable to load the image at {image_path}. Please check the file path.")
    exit()

# Compute errors
abs_error_sum, rel_error_sum, abs_error_weighted, rel_error_weighted = compute_errors(image)

# Print average errors
print("Approximation 1: |Gx| + |Gy|")
print("  Average Absolute Error (MAE):", abs_error_sum.mean())
print("  Average Relative Error (MRE):", rel_error_sum.mean())

print("\nApproximation 2: max(|Gx|, |Gy|) + 0.5 * min(|Gx|, |Gy|)")
print("  Average Absolute Error (MAE):", abs_error_weighted.mean())
print("  Average Relative Error (MRE):", rel_error_weighted.mean())

# Plot merged images
plot_merged_2d(abs_error_sum, abs_error_weighted, 
               "Abs Error: |Gx| + |Gy|", "Abs Error: Weighted Max-Min", 
               "Absolute Errors for Two Approximations")

plot_merged_2d(rel_error_sum, rel_error_weighted, 
               "Rel Error: |Gx| + |Gy|", "Rel Error: Weighted Max-Min", 
               "Relative Errors for Two Approximations")
