import re

def read_mem_file(filename):
    """Reads the .mem file and stores values in a 2D list."""
    with open(filename, "r") as file:
        lines = [line.strip() for line in file if line.strip()]
    
    # Determine the LUT size
    lut_data = [line.split() for line in lines]  # Convert space-separated values into 2D list
    return lut_data

def format_lut_declaration(lut_data):
    """Formats the LUT data as a SystemVerilog 2D array initialization."""
    lut_str = "    initial begin\n"
    for i, row in enumerate(lut_data):
        for j, value in enumerate(row):
            lut_str += f"        lut[{i}][{j}] = 2'b{value};\n"
    lut_str += "    end\n"
    return lut_str

def insert_lut_into_sv(mem_filename, sv_filename):
    """Inserts the LUT content into the SystemVerilog file after the comment marker."""
    lut_data = read_mem_file(mem_filename)
    lut_code = format_lut_declaration(lut_data)
    
    # Read the SystemVerilog file
    with open(sv_filename, "r") as file:
        sv_code = file.read()
    
    # Match the comment marker and insert the LUT content right after it, keeping the comment intact
    new_sv_code = re.sub(r"(/\*\s*INSERT HERE THE LUT CONTENT\s*\*/)", r"\1\n" + lut_code, sv_code)
    
    # Write back the modified file
    with open(sv_filename, "w") as file:
        file.write(new_sv_code)
    
    print("LUT content inserted successfully!")

# Example usage
insert_lut_into_sv("lut_atan_log.mem", "../src/lut_atan.sv")
