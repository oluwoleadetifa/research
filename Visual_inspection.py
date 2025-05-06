import numpy as np
import matplotlib.pyplot as plt

# Step 1: Load the binary data
with open('raw_random.bin', 'rb') as f:
    data = np.frombuffer(f.read(), dtype=np.uint8)

# Step 2: Plot histogram
plt.figure(figsize=(10, 6))
plt.hist(data, bins=256, range=(0, 256), density=True, alpha=0.7, color='blue')
plt.title('Histogram of Byte Values in raw_random.bin')
plt.xlabel('Byte Value')
plt.ylabel('Frequency')
plt.grid(True)
plt.show()
