import binascii

hex_file = "processed_data_output.txt"  # Your hex file
bin_file = "processed_data.bin"  # Output binary file

with open(hex_file, "r") as f, open(bin_file, "wb") as out:
    for line in f:
        bin_data = binascii.unhexlify(line.strip())
        out.write(bin_data)

print(f"Binary data saved to {bin_file}")