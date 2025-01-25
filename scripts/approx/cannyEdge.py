import cv2
import numpy as np

def non_maximum_suppression(gradient_magnitude, gradient_direction):
    # Get image dimensions
    rows, cols = gradient_magnitude.shape
    
    # Create output array filled with zeros
    nms_output = np.zeros((rows, cols), dtype=np.float32)
    
    # Normalize gradient directions to the range [0, 180)
    gradient_direction = np.rad2deg(gradient_direction) % 180
    
    # Iterate over each pixel (ignore borders)
    for i in range(1, rows - 1):
        for j in range(1, cols - 1):
            # Get the current direction
            direction = gradient_direction[i, j]
            
            # Initialize the neighbors to compare
            neighbor_1, neighbor_2 = 0, 0
            
            # Quantize direction to nearest of 0, 45, 90, 135 degrees
            if (0 <= direction < 22.5) or (157.5 <= direction < 180):
                # Direction is 0 degrees (horizontal)
                neighbor_1 = gradient_magnitude[i, j - 1]  # Left
                neighbor_2 = gradient_magnitude[i, j + 1]  # Right
            elif 22.5 <= direction < 67.5:
                # Direction is 45 degrees (diagonal, top-right to bottom-left)
                neighbor_1 = gradient_magnitude[i - 1, j + 1]  # Top-right
                neighbor_2 = gradient_magnitude[i + 1, j - 1]  # Bottom-left
            elif 67.5 <= direction < 112.5:
                # Direction is 90 degrees (vertical)
                neighbor_1 = gradient_magnitude[i - 1, j]  # Top
                neighbor_2 = gradient_magnitude[i + 1, j]  # Bottom
            elif 112.5 <= direction < 157.5:
                # Direction is 135 degrees (diagonal, top-left to bottom-right)
                neighbor_1 = gradient_magnitude[i - 1, j - 1]  # Top-left
                neighbor_2 = gradient_magnitude[i + 1, j + 1]  # Bottom-right
            
            # Suppress non-maximum pixels
            if gradient_magnitude[i, j] >= neighbor_1 and gradient_magnitude[i, j] >= neighbor_2:
                nms_output[i, j] = gradient_magnitude[i, j]
            else:
                nms_output[i, j] = 0
    
    return nms_output

kernel_size = (5, 5)
sigma = 1.4

SOBEL_DEPTH = cv2.CV_16S  # precision = 8 bits
DX = 1
DY = 1
KERNEL_SOBEL = 3

# Load the grayscale image
image_path = 'lena.png'  # Correct the file path
image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

# Print the input image
cv2.imshow("INPUT IMAGE", image)

# Now perform the gaussian blur
image_gaussian = cv2.GaussianBlur(image, kernel_size, sigma)
np.set_printoptions(threshold=np.inf)
cv2.imshow("GAUSSIAN FILTER", image_gaussian)

# Apply the Sobel filter
image_sobel_x = cv2.Sobel(image_gaussian, ddepth=SOBEL_DEPTH, dx=DX, dy=0, ksize=KERNEL_SOBEL)
image_sobel_y = cv2.Sobel(image_gaussian, ddepth=SOBEL_DEPTH, dy=DY, dx=0, ksize=KERNEL_SOBEL)

print(f"sobel x max {image_sobel_x.max()}, min : {image_sobel_x.min()}")
print(f"sobel y max {image_sobel_y.max()}, min : {image_sobel_y.min()}")

cv2.imshow("SOBEL X", np.int8(image_sobel_x))
cv2.imshow("SOBEL Y", np.int8(image_sobel_y))

# Now compute the gradient magnitude for each of the derivative
gradient_magnitude = np.uint8((np.sqrt(image_sobel_x**2 + image_sobel_y**2)))

# Compute the approximate gradient magnitude for each pixel
abs_sobel_x = np.abs(image_sobel_x).astype(np.float32)  # Absolute value of Sobel X
abs_sobel_y = np.abs(image_sobel_y).astype(np.float32)  # Absolute value of Sobel Y
gradient_magnitude_approx = np.maximum(abs_sobel_x, abs_sobel_y) + 0.5 * np.minimum(abs_sobel_x, abs_sobel_y)
gradient_magnitude_approx_2 = np.uint8(np.abs(image_sobel_x) + np.abs(image_sobel_y))
# Convert both matrices to uint8 (clipping values to [0, 255])
gradient_magnitude = np.uint8(np.clip(gradient_magnitude, 0, 255))
gradient_magnitude_approx = np.uint8(np.clip(gradient_magnitude_approx, 0, 255))
cv2.imshow("GRADIENT MAG", gradient_magnitude)
cv2.imshow("GRADIENT MAG APPROXIMATE", gradient_magnitude_approx)
cv2.imshow("GRADIENT MAG APPROXIMATE 2", gradient_magnitude_approx_2)
# Now compute the direction of the gradient of the image
gradient_direction = np.arctan2(image_sobel_y, image_sobel_x)
# Normalize direction to range [0, 255] for visualization
gradient_direction_normalized = np.uint8(((gradient_direction + np.pi) / (2 * np.pi)) * 255)

# Apply a colormap to visualize gradient directions
colored_direction = cv2.applyColorMap(gradient_direction_normalized, cv2.COLORMAP_HSV)

print(f"G module MAX {gradient_magnitude.max()}, min : {gradient_magnitude.min()}")
print(f"G direction MAX {gradient_direction.max()}, min : {gradient_direction.min()}")

cv2.imshow("Gradient Direction (Color)", colored_direction)

# NMS
nms = non_maximum_suppression(gradient_magnitude, gradient_direction)
# Normalize the nms
nms = np.uint8(nms / nms.max() * 255)
cv2.imshow("NMS", nms)

nms_approx = non_maximum_suppression(gradient_magnitude_approx, gradient_direction)
# Normalize the nms
nms_approx = np.uint8(nms_approx / nms_approx.max() * 255)
cv2.imshow("NMS APPROX", nms_approx)

# Thresholding
low_threshold = 50
high_threshold = 150

strong_edges = (nms > high_threshold).astype(np.uint8) * 255
weak_edges = ((nms >= low_threshold) & (nms <= high_threshold)).astype(np.uint8) * 128

# Combine strong and weak edges
edges = strong_edges + weak_edges

cv2.imshow("OUTPUT", edges)

strong_edges_approx = (nms_approx > high_threshold).astype(np.uint8) * 255
weak_edges_approx = ((nms_approx >= low_threshold) & (nms_approx <= high_threshold)).astype(np.uint8) * 128

# Combine strong and weak edges
edges_approx = strong_edges_approx + weak_edges_approx
cv2.imshow("OUTPUT APPROX", edges_approx)

cv2.waitKey(0)