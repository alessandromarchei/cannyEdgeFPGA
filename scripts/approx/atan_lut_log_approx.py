import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Function to map angles to 4 possible values
def map_angle_to_range(angle):
    angle = (angle + 180) % 360 - 180  # Normalize angle to [-180, 180]
    if (-22.5 <= angle <= 22.5) or (157.5 <= angle or angle <= -157.5):
        return 0
    elif (22.5 < angle <= 67.5) or (-157.5 < angle <= -112.5):
        return 1
    elif (67.5 < angle <= 112.5) or (-112.5 < angle <= -67.5):
        return 2
    elif (112.5 < angle <= 157.5) or (-67.5 < angle <= -22.5):
        return 3
    else:
        print(f"Unhandled angle: {angle}")
        return None

# Logarithmic quantization function
def log_quantize(value):
    if value == 0:
        return 0
    sign = np.sign(value)
    abs_value = abs(value)
    quantized_value = 2 ** int(np.floor(np.log2(abs_value)))
    return sign * quantized_value

# Generate grid values for X and Y
max_value = 1024
x = np.arange(-max_value, max_value, 1)
y = np.arange(-max_value, max_value, 1)
X, Y = np.meshgrid(x, y)
num_elements = X.size

# Compute arctangent for original values
Z_true = np.arctan2(X, Y)
Z_mapped = np.vectorize(map_angle_to_range)(np.degrees(Z_true))

# Apply logarithmic quantization
vectorized_log_quantize = np.vectorize(log_quantize)
X_quantized = vectorized_log_quantize(X)
Y_quantized = vectorized_log_quantize(Y)

# Compute arctangent for quantized grid
Z_quantized = np.arctan2(X_quantized, Y_quantized)
Z_quantized_mapped = np.vectorize(map_angle_to_range)(np.degrees(Z_quantized))

# Compute error between original and quantized grids
absolute_error = np.abs(Z_quantized_mapped - Z_mapped) != 0
non_zero_error_count = np.count_nonzero(absolute_error)

# Output statistical error information
print(f"Number of wrong guesses: {non_zero_error_count}")
print(f"Number of elements: {num_elements}")
print(f"RELATIVE WRONG GUESSES: {(non_zero_error_count / num_elements) * 100:.2f}%")

# Compute LUT size based on log quantization
unique_x_values = len(np.unique(X_quantized))
unique_y_values = len(np.unique(Y_quantized))
print(f"UNIQUE X VALUES: {unique_x_values}")
print(f"UNIQUE Y VALUES: {unique_y_values}")
print(f"TOTAL LUT ENTRIES: {unique_x_values * unique_y_values}")

# 3D Plot
fig = plt.figure(figsize=(14, 7))

# Original grid plot
ax1 = fig.add_subplot(121, projection='3d')
ax1.plot_surface(X, Y, Z_mapped, cmap='viridis')
ax1.set_xlabel('X (10-bit scale)')
ax1.set_ylabel('Y (10-bit scale)')
ax1.set_zlabel('Mapped Angle')
ax1.set_title('Original Grid')

# Quantized grid plot
ax2 = fig.add_subplot(122, projection='3d')
ax2.plot_surface(X_quantized, Y_quantized, Z_quantized_mapped, cmap='viridis')
ax2.set_xlabel('X (Log Quantized)')
ax2.set_ylabel('Y (Log Quantized)')
ax2.set_zlabel('Mapped Angle')
ax2.set_title('Logarithmic Quantized Grid')

# Error visualization
fig_error = plt.figure(figsize=(7, 7))
ax_error = fig_error.add_subplot(111, projection='3d')
ax_error.plot_surface(X, Y, absolute_error, cmap='inferno')
ax_error.set_xlabel('X (10-bit scale)')
ax_error.set_ylabel('Y (10-bit scale)')
ax_error.set_zlabel('Absolute Error')
ax_error.set_title('Absolute Error Distribution')

# Show plots
plt.show()
