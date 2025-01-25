from PIL import Image
import sys

def hex_to_image(input_file):
    try:
        # Read the .hex file
        with open(input_file, 'r') as file:
            lines = file.readlines()

        # Parse the .hex file into a 2D list (matrix)
        matrix = []
        for line in lines:
            row = [int(cell, 16) for cell in line.strip().split()]
            matrix.append(row)

        # Get the dimensions of the matrix
        height = len(matrix)
        width = len(matrix[0]) if height > 0 else 0

        # Create an image from the matrix
        image = Image.new('L', (width, height))  # 'L' mode for 8-bit grayscale
        for y, row in enumerate(matrix):
            for x, value in enumerate(row):
                image.putpixel((x, y), value)

        # Save the image as .png
        output_file = input_file.replace('.hex', '.png')
        image.save(output_file)
        print(f"Image saved as {output_file}")

    except Exception as e:
        print(f"Error: {e}")

# Usage example: Replace 'input_file.hex' with your file name
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python hex_to_image.py <input_file.hex>")
    else:
        hex_to_image(sys.argv[1])
