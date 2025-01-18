import numpy as np

# Parameters
lut_size = 1024  # Number of entries in the LUT
lut = np.zeros(lut_size)

# Fill the LUT with arctan values
for i in range(lut_size):
    ratio = i / (lut_size - 1)  # Normalize ratio between 0 and 1
    lut[i] = np.arctan(ratio) * (180 / np.pi)  # Store in degrees

# Save LUT to file
np.savetxt("arctan_lut.txt", lut, fmt="%.6f")
