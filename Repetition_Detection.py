import numpy as np


# Step 1: Load the binary data
with open('raw_random.bin', 'rb') as f:
    data = np.frombuffer(f.read(), dtype=np.uint8)

# Step 2: Define block size to check for repetitive sequences
block_size = 128  # You can change this to 32, 64, etc. for larger blocks
blocks = [data[i:i+block_size] for i in range(0, len(data), block_size)]

# Step 3: Detect repetitive blocks
unique_blocks = {}
for block in blocks:
    block_tuple = tuple(block)
    if block_tuple in unique_blocks:
        unique_blocks[block_tuple] += 1
    else:
        unique_blocks[block_tuple] = 1

# Step 4: Show repeated blocks
repeated_blocks = {block: count for block, count in unique_blocks.items() if count > 1}
print(f"Repeated blocks: {repeated_blocks}")