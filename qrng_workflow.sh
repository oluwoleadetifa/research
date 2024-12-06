#!/bin/bash

# Configuration
QRNG_DEVICE="/dev/qrandom0"
OUTPUT_DIR="/home/wole/Documents/research/research"
RAW_BIN_FILE="${OUTPUT_DIR}/raw_random.bin"
HEX_FILE="${OUTPUT_DIR}/raw_data.hex"
PROCESSED_FILE="${OUTPUT_DIR}/processed_random.txt"
BIT_WIDTH=32  # Specify bit width for the test

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Generate raw random numbers (size should be aligned to bit width)
# Ensure each line in the hex file represents the BIT_WIDTH (4 characters per byte)
BYTES=$((BIT_WIDTH / 8)) # Calculate bytes for 32 bits
LINES=10000              # Number of random numbers to test (adjust as needed)
dd if="${QRNG_DEVICE}" of="${RAW_BIN_FILE}" bs=${BYTES} count=${LINES}

# Convert .bin to .hex (generate hexadecimal representation)
xxd -p -c ${BYTES} "${RAW_BIN_FILE}" > "${HEX_FILE}"  # -c ensures line length matches 32-bit

# GHDL simulation and processing
cd "${OUTPUT_DIR}"
ghdl -a --std=08 postprocessing.vhdl postprocessing_tb.vhdl
ghdl -e --std=08 PostProcessing_tb
ghdl -r --std=08 PostProcessing_tb --stop-time=1ms

# Output completion message
echo "Random number generation and processing completed."
echo "Processed data saved to ${PROCESSED_FILE}."
