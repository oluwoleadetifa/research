#!/bin/bash

INPUT_FILE=${1:-xor_output.bin}
HEX_FILE="temp_output.hex"
FREQ_FILE="byte_frequency.txt"

if [ ! -f "$INPUT_FILE" ]; then
  echo "File $INPUT_FILE not found!"
  exit 1
fi

echo "🔍 Converting binary to hex..."
xxd -p -c 1 "$INPUT_FILE" > "$HEX_FILE"

echo "📊 Top 10 most frequent bytes:"
sort "$HEX_FILE" | uniq -c | sort -nr | head

echo ""
echo "🧮 Counting '00' bytes (possible structure indicator):"
grep -c '^00$' "$HEX_FILE"

echo ""
echo "🧠 Running entropy test (ent)..."
ent "$INPUT_FILE"

echo ""
echo "🧵 Scanning for ASCII strings (may indicate structure):"
strings "$INPUT_FILE" | head -n 10

echo ""
echo "📈 Generating byte frequency histogram data (for plotting)..."
od -An -t u1 "$INPUT_FILE" | tr -s ' ' '\n' | sort -n | uniq -c | awk '{print $2, $1}' > "$FREQ_FILE"
echo "→ Byte frequency saved to: $FREQ_FILE"

echo ""
echo "✅ Done. Review the results above for signs of structure or bias."

