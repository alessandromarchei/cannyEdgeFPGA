import numpy as np
import matplotlib.pyplot as plt
import argparse

# Parameters
MAX_VALUE = 1021  # Maximum value for gx and gy
LOG_BASE = 2     # Base for logarithmic quantization

HORIZONTAL_DIRECTION = 0b00
DIAGONAL_DIRECTION = 0b10
VERTICAL_DIRECTION = 0b01

def get_direction_name(direction):
    if direction == HORIZONTAL_DIRECTION:
        return "HORIZONTAL"
    elif direction == DIAGONAL_DIRECTION:
        return "DIAGONAL"
    elif direction == VERTICAL_DIRECTION:
        return "VERTICAL"
    return "UNKNOWN"

def log_quantize(value, base):
    if value == 0:
        return 0
    return int(np.log(value + 1) / np.log(base))

def fill_2d_map(lut, base):
    def get_direction(angle):
        if 0 <= angle < 22.5:
            return HORIZONTAL_DIRECTION
        elif 22.5 <= angle < 67.5:
            return DIAGONAL_DIRECTION
        elif 67.5 <= angle <= 90:
            return VERTICAL_DIRECTION
        return HORIZONTAL_DIRECTION

    for x in range(MAX_VALUE + 1):
        for y in range(MAX_VALUE + 1):
            if x == 0 and y == 0:
                lut[0, 0] = HORIZONTAL_DIRECTION
                continue
            
            write_x = log_quantize(x, base)
            write_y = log_quantize(y, base)
            angle = np.degrees(np.arctan2(y, x))
            lut[write_x, write_y] = get_direction(angle)
    
    return lut

def visualize_mapping():
    original_size = min(MAX_VALUE + 1, 100)  # Limit size for visualization
    original_map = np.zeros((original_size, original_size), dtype=np.uint8)
    
    for x in range(original_size):
        for y in range(original_size):
            if x == 0 and y == 0:
                original_map[x, y] = HORIZONTAL_DIRECTION
                continue
            angle = np.degrees(np.arctan2(y, x))
            if 0 <= angle < 22.5:
                original_map[x, y] = HORIZONTAL_DIRECTION
            elif 22.5 <= angle < 67.5:
                original_map[x, y] = DIAGONAL_DIRECTION
            elif 67.5 <= angle <= 90:
                original_map[x, y] = VERTICAL_DIRECTION
    
    max_log_x = log_quantize(MAX_VALUE, LOG_BASE)
    max_log_y = log_quantize(MAX_VALUE, LOG_BASE)
    lut = np.zeros((max_log_x + 1, max_log_y + 1), dtype=np.uint8)
    lut = fill_2d_map(lut, LOG_BASE)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 7))
    
    im1 = ax1.imshow(original_map, cmap="viridis", origin="lower")
    ax1.set_title('Original (Non-Quantized) Directions')
    ax1.set_xlabel('X coordinate')
    ax1.set_ylabel('Y coordinate')
    plt.colorbar(im1, ax=ax1, label='Direction (2-bit values)')
    
    im2 = ax2.imshow(lut, cmap="viridis", origin="lower")
    ax2.set_title('Log Quantized Directions (LUT)')
    ax2.set_xlabel('Log Quantized X coordinate')
    ax2.set_ylabel('Log Quantized Y coordinate')
    plt.colorbar(im2, ax=ax2, label='Direction (2-bit values)')
    
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate and query log-quantized direction LUT')
    parser.add_argument('--show-plot', action='store_true', help='Show visualization plot')
    args = parser.parse_args()

    max_log_x = log_quantize(MAX_VALUE, LOG_BASE)
    max_log_y = log_quantize(MAX_VALUE, LOG_BASE)
    lut = np.zeros((max_log_x + 1, max_log_y + 1), dtype=np.uint8)
    lut = fill_2d_map(lut, LOG_BASE)
    
    if args.show_plot:
        visualize_mapping()
    
    filename = "lut_atan_log.mem"
    with open(filename, "w") as file:
        #write each row into the file
        for row in lut:
            file.write(" ".join([f"{cell:02b}" for cell in row]) + "\n")
    print(f"LUT saved as {filename}")
