#!/bin/bash

# Configuration
QRNG_DEVICE="/dev/qrandom0"
OUTPUT_DIR="/home/wole/Documents/research/research"
RAW_BIN_FILE="${OUTPUT_DIR}/raw_random.bin"
HEX_FILE="${OUTPUT_DIR}/raw_data.hex"
PROCESSED_FILE="${OUTPUT_DIR}/raw_data.hex"

# Check if user provided command-line arguments
if [ $# -lt 2 ]; then
  read -p "Enter the number of random numbers to generate: " LINES
  read -p "Enter the bit width (e.g., 32, 64, 128): " BIT_WIDTH
else
  LINES=$1
  BIT_WIDTH=$2
fi

# Validate input
if ! [[ "$LINES" =~ ^[0-9]+$ ]]; then
  echo "Error: Number of random numbers must be a positive integer."
  exit 1
fi

if ! [[ "$BIT_WIDTH" =~ ^[0-9]+$ ]] || (( BIT_WIDTH % 8 != 0 )); then
  echo "Error: Bit width must be a positive integer and a multiple of 8."
  exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Calculate bytes per number
BYTES=$((BIT_WIDTH / 8))

# Generate raw random numbers
dd if="${QRNG_DEVICE}" of="${RAW_BIN_FILE}" bs=${BYTES} count=${LINES} status=progress

# Convert .bin to .hex (generate hexadecimal representation)
xxd -p -c ${BYTES} "${RAW_BIN_FILE}" > "${HEX_FILE}"

# GHDL simulation and processing
cd "${OUTPUT_DIR}"
ghdl -a --std=08 direct_processing.vhdl direct_processing_tb.vhdl
ghdl -e --std=08 DirectProcessing
ghdl -r --std=08 DirectProcessing --stop-time=1ms

# Output completion message
echo "Random number generation and processing completed."
echo "Processed data saved to ${PROCESSED_FILE}."
