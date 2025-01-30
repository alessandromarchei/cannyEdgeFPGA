import numpy as np
import matplotlib.pyplot as plt
import argparse


# Parameters
FINE_THRESHOLD = 16  # Fine region limit
COARSE_STEP = 64     # Coarse quantization step
MAX_VALUE = 1021     # Maximum value for gx and gy

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

def query_coordinate(x, y, lut, fine_threshold, coarse_step):
    """
    Query the direction and mapping for specific x,y coordinates
    """
    # Get quantized coordinates
    quant_x = x if x <= fine_threshold else fine_threshold + ((x - fine_threshold) // coarse_step)
    quant_y = y if y <= fine_threshold else fine_threshold + ((y - fine_threshold) // coarse_step)
    
    # Calculate angle
    angle = np.degrees(np.arctan2(y, x))
    
    # Get direction from LUT
    lut_direction = lut[quant_x, quant_y]
    
    # Prepare result
    result = {
        'original_coords': (x, y),
        'quantized_coords': (quant_x, quant_y),
        'angle': angle,
        'direction_value': lut_direction,
        'direction_name': get_direction_name(lut_direction)
    }
    
    return result



def fill_2d_map(lut, fine_threshold, coarse_step):
    """
    Fill a 2D lookup table with directional values based on gradient angles.
    Handles three cases:
    1. Both x,y below fine_threshold -> use exact values
    2. One coordinate below threshold, other above -> mix of exact and quantized
    3. Both above threshold -> use coarse quantized values
    
    Args:
        lut: Lookup table to fill
        fine_threshold: Threshold below which fine granularity is used
        coarse_step: Step size for coarse quantization
    """
    def get_direction(angle):
        if 0 <= angle < 22.5:
            return HORIZONTAL_DIRECTION
        elif 22.5 <= angle < 67.5:
            return DIAGONAL_DIRECTION
        elif 67.5 <= angle <= 90:
            return VERTICAL_DIRECTION
        return HORIZONTAL_DIRECTION

    def get_quantized_coord(val):
        if val <= fine_threshold:
            return val  # Use exact value
        else:
            # Quantize values above threshold
            return fine_threshold + ((val - fine_threshold) // coarse_step)

    # Single loop over all coordinates
    for x in range(MAX_VALUE + 1):
        for y in range(MAX_VALUE + 1):
            # Skip if both coordinates are zero
            if x == 0 and y == 0:
                lut[0, 0] = HORIZONTAL_DIRECTION
                continue
                
            # Get the proper write coordinates based on whether each dimension
            # is fine or coarse
            write_x = get_quantized_coord(x)
            write_y = get_quantized_coord(y)
            
            # Calculate angle using original coordinates for accuracy
            angle = np.degrees(np.arctan2(y, x))
            
            # Write the direction to the quantized location
            lut[write_x, write_y] = get_direction(angle)
    
    return lut

def visualize_mapping():
    # Generate original (non-quantized) map for comparison
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

    # Generate quantized LUT
    x_size = (FINE_THRESHOLD + (MAX_VALUE - FINE_THRESHOLD) // COARSE_STEP + 1)
    y_size = (FINE_THRESHOLD + (MAX_VALUE - FINE_THRESHOLD) // COARSE_STEP + 1)
    print(f"LUT SIZE : {x_size}x{y_size} = {x_size * y_size}")
    
    lut = np.zeros((x_size, y_size), dtype=np.uint8)
    lut = fill_2d_map(lut, FINE_THRESHOLD, COARSE_STEP)

    # Create visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 7))
    
    # Plot original directions
    im1 = ax1.imshow(original_map, cmap="viridis", origin="lower")
    ax1.set_title('Original (Non-Quantized) Directions')
    ax1.set_xlabel('X coordinate')
    ax1.set_ylabel('Y coordinate')
    plt.colorbar(im1, ax=ax1, label='Direction (2-bit values)')
    
    # Plot quantized directions
    im2 = ax2.imshow(lut, cmap="viridis", origin="lower")
    ax2.set_title('Quantized Directions (LUT)')
    ax2.set_xlabel('Quantized X coordinate')
    ax2.set_ylabel('Quantized Y coordinate')
    plt.colorbar(im2, ax=ax2, label='Direction (2-bit values)')
    
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate and query direction LUT')
    parser.add_argument('-x', type=int, help='X coordinate to query')
    parser.add_argument('-y', type=int, help='Y coordinate to query')
    parser.add_argument('--show-plot', action='store_true', help='Show visualization plot')
    args = parser.parse_args()

    # Generate LUT
    x_size = (FINE_THRESHOLD + (MAX_VALUE - FINE_THRESHOLD) // COARSE_STEP + 1)
    y_size = (FINE_THRESHOLD + (MAX_VALUE - FINE_THRESHOLD) // COARSE_STEP + 1)
    lut = np.zeros((x_size, y_size), dtype=np.uint8)
    lut = fill_2d_map(lut, FINE_THRESHOLD, COARSE_STEP)

    # If coordinates are provided, query them
    if args.x is not None and args.y is not None:
        if 0 <= args.x <= MAX_VALUE and 0 <= args.y <= MAX_VALUE:
            result = query_coordinate(args.x, args.y, lut, FINE_THRESHOLD, COARSE_STEP)
            print("\nQueried Coordinate Results:")
            print(f"Original coordinates: ({result['original_coords'][0]}, {result['original_coords'][1]})")
            print(f"Quantized coordinates: ({result['quantized_coords'][0]}, {result['quantized_coords'][1]})")
            print(f"Angle: {result['angle']:.2f}°")
            print(f"Direction value in LUT: {result['direction_value']} ({result['direction_name']})")
        else:
            print(f"Error: Coordinates must be between 0 and {MAX_VALUE}")
            exit(1)

    # Show visualization if requested
    if args.show_plot:
        visualize_mapping()
    # If no arguments provided, show both visualization and save LUT
    elif args.x is None and args.y is None:
        visualize_mapping()

    # Always save the LUT
    lut_1d = lut.flatten()

    filename = f"lut_atan_fine{FINE_THRESHOLD}_coarse{COARSE_STEP}.mem"
    with open(filename, "w") as file:
        for value in lut_1d:
            file.write(f"{value:02X}\n")
    print(f"LUT saved as {filename}")