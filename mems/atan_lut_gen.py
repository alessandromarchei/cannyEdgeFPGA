import numpy as np
import matplotlib.pyplot as plt
import argparse

# Parameters
FINE_THRESHOLD = 16  # Fine region limit
COARSE_STEP = 32     # Coarse quantization step
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

def fill_2d_map(lut, fine_threshold, coarse_step):
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
            return fine_threshold + ((val - fine_threshold) // coarse_step)

    for x in range(MAX_VALUE + 1):
        for y in range(MAX_VALUE + 1):
            if x == 0 and y == 0:
                lut[0, 0] = HORIZONTAL_DIRECTION
                continue
            write_x = get_quantized_coord(x)
            write_y = get_quantized_coord(y)
            angle = np.degrees(np.arctan2(y, x))
            lut[write_x, write_y] = get_direction(angle)
    
    return lut

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate and save direction LUT')
    args = parser.parse_args()

    x_size = (FINE_THRESHOLD + (MAX_VALUE - FINE_THRESHOLD) // COARSE_STEP + 1)
    y_size = (FINE_THRESHOLD + (MAX_VALUE - FINE_THRESHOLD) // COARSE_STEP + 1)
    lut = np.zeros((x_size, y_size), dtype=np.uint8)
    lut = fill_2d_map(lut, FINE_THRESHOLD, COARSE_STEP)

    filename = f"lut_atan_fine{FINE_THRESHOLD}_coarse{COARSE_STEP}.mem"
    with open(filename, "w") as file:
        for x in range(x_size):
            for y in range(y_size):
                file.write(f"x : {x:02X} y : {y:02X} -> {lut[x, y]:02X}\n")
    
    print(f"LUT saved as {filename}")
