#!/bin/bash

# Configuration
QRNG_DEVICE="/dev/qrandom0"
OUTPUT_DIR="/home/wole/Documents/research/postProcessing"
RAW_BIN_FILE="${OUTPUT_DIR}/raw_random.bin"
HEX_FILE="${OUTPUT_DIR}/raw_data.hex"
PROCESSED_FILE="${OUTPUT_DIR}/processed_random.txt"

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Generate raw random numbers
dd if="${QRNG_DEVICE}" of="${RAW_BIN_FILE}" bs=1M count=10

# Convert .bin to .hex
xxd -p "${RAW_BIN_FILE}" > "${HEX_FILE}"

# GHDL simulation and processing
cd /home/wole/Documents/research/postProcessing
ghdl -a --std=08 postprocessing.vhdl postprocessing_tb.vhdl
ghdl -e --std=08 PostProcessing_tb
ghdl -r --std=08 PostProcessing_tb --stop-time=27320ns

echo "Random number generation and processing completed."
