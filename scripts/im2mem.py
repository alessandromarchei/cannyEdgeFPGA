from PIL import Image
import numpy as np

def process_image(input_path, output_path, width, height, file_format="hex"):
    """
    Processes an image, converts it to grayscale, resizes it to the given dimensions,
    and writes the pixel data to a .hex or .mem file.
    
    Parameters:
        input_path (str): Path to the input image.
        output_path (str): Path to save the output .hex or .mem file.
        width (int): Desired width of the processed image.
        height (int): Desired height of the processed image.
        file_format (str): Output file format, either 'hex' or 'mem'.
    """
    # Open and convert the image to grayscale
    img = Image.open(input_path).convert("L")  # 'L' mode is for grayscale
    
    # Resize the image to the specified dimensions
    img = img.resize((width, height), Image.ANTIALIAS)
    
    # Get the pixel values as a NumPy array
    pixel_array = np.array(img)
    
    # Create and write the output file
    with open(output_path, "w") as f:
        if file_format == "hex":
            # Write a .hex file where each pixel is in hexadecimal format
            for row in pixel_array:
                hex_values = [f"{pixel:02X}" for pixel in row]  # Format each pixel as two-digit hex
                f.write(" ".join(hex_values) + "\n")
        elif file_format == "mem":
            # Write a .mem file where each pixel is in hexadecimal format
            for row in pixel_array:
                hex_values = [f"{pixel:02X}" for pixel in row]  # Format each pixel as two-digit hex
                f.write("".join(hex_values) + "\n")
        else:
            raise ValueError("Unsupported file format. Use 'hex' or 'mem'.")
    
    print(f"{file_format.upper()} file written to {output_path}")

# Parameters
input_image_path = "mars.png"  # Change to your input image path
output_file_path = "../sim/mars.hex"  # Change to your desired output file path
output_width = 120  # Desired image width
output_height = 120  # Desired image height
output_format = "hex"  # Set to 'hex' or 'mem'

# Process the image
process_image(input_image_path, output_file_path, output_width, output_height, output_format)

# Now enter the file in "../src/params.sv" file and change the value of "IM_WIDTH" and "IM_HEIGHT" to the desired values
params_file_path = "../src/params.sv"

# Read the contents of the params.sv file
with open(params_file_path, "r") as file:
    lines = file.readlines()

# Modify the IM_WIDTH and IM_HEIGHT values
with open(params_file_path, "w") as file:
    for line in lines:
        if "IM_WIDTH" in line:
            file.write(f"`define IM_WIDTH {output_width}\n")
        elif "IM_HEIGHT" in line:
            file.write(f"`define IM_HEIGHT {output_height}\n")
        else:
            file.write(line)

print(f"Updated IM_WIDTH and IM_HEIGHT in {params_file_path}")


