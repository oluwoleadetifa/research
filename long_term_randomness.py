import numpy as np
import time
import os
import subprocess
import matplotlib.pyplot as plt
from scipy.stats import entropy, kstest

# CONFIGURATION
OUTPUT_DIR = "/home/wole/Documents/research/research"
HEX_FILE = f"{OUTPUT_DIR}/raw_data.hex" 
BASH_SCRIPT = f"{OUTPUT_DIR}/qrng_workflow.sh"  
TEST_INTERVAL = 3600  # 1 hour
TEST_CYCLES = 24
NUM_GENERATE = 100000  # How many new numbers to generate
BIT_WIDTH = 128  # Ensure this matches QRNG output
OUTPUT_LOG = f"{OUTPUT_DIR}/randomness_test_noprocessing.csv"

if not os.path.exists(OUTPUT_LOG):
    with open(OUTPUT_LOG, "w") as log:
        log.write("Cycle,Mean,Variance,Entropy,KS_p_value,Monobit_ratio\n")

def generate_new_numbers():
    print("Generating fresh random numbers from FPGA...")
    subprocess.run(["bash", BASH_SCRIPT, str(NUM_GENERATE), str(BIT_WIDTH)], check=True)
    print(f"Generated {NUM_GENERATE} new numbers.")

def read_hex_file(filename):
    with open(filename, "r") as f:
        hex_numbers = [line.strip() for line in f]
    
    # Convert hex string to a pair of np.uint64 values
    decimal_numbers = []
    for h in hex_numbers:
        # Split each 128-bit hex string into two 64-bit parts
        high = int(h[:16], 16)  # First 64 bits (high)
        low = int(h[16:], 16)   # Last 64 bits (low)
        decimal_numbers.append((high, low))
    
    # Convert the list of tuples to a numpy array of np.uint64 pairs
    return np.array(decimal_numbers, dtype=[('high', np.uint64), ('low', np.uint64)])

def analyze_randomness(numbers, cycle):
    # Combine the 'high' and 'low' parts to form 128-bit numbers using Python's int type
    full_numbers = [((int(high) << 64) | int(low)) for high, low in numbers]

    # Basic statistical analysis
    mean = np.mean(full_numbers)
    variance = np.var(full_numbers)
    
    # Convert numbers to binary and calculate monobit ratio
    binary_data = ''.join(f"{num:0128b}" for num in full_numbers)
    ones = binary_data.count('1')
    zeros = binary_data.count('0')
    monobit_ratio = ones / (ones + zeros)

    # Convert the numbers to uint8 and apply modulo 256 for 8-bit analysis
    numbers_mod_256 = np.array([num % 256 for num in full_numbers], dtype=np.uint8)
    value_counts = np.bincount(numbers_mod_256, minlength=256)
    probs = value_counts / len(full_numbers)
    ent = entropy(probs, base=2)

    # Kolmogorov-Smirnov test for uniform distribution
    # Normalize the 128-bit numbers to the range [0, 1) for the KS test
    max_value = (1 << 128) - 1  # Maximum value for a 128-bit unsigned integer
    normalized_numbers = np.array([num / max_value for num in full_numbers], dtype=np.float64)
    ks_stat, ks_p_value = kstest(normalized_numbers, 'uniform')

    # Write results to log
    with open(OUTPUT_LOG, "a") as log:
        log.write(f"{cycle},{mean},{variance},{ent},{ks_p_value},{monobit_ratio}\n")

    print(f"Cycle {cycle} - Mean: {mean:.2f}, Variance: {variance:.2f}, Entropy: {ent:.4f}, KS p-value: {ks_p_value:.4f}, Monobit Ratio: {monobit_ratio:.4f}")

# Test cycles
for cycle in range(1, TEST_CYCLES + 1):
    print(f"Starting test cycle {cycle}/{TEST_CYCLES}...")

    # Generate new random numbers
    generate_new_numbers()

    # Read and process the generated numbers
    random_numbers = read_hex_file(HEX_FILE)

    # Perform randomness analysis
    analyze_randomness(random_numbers, cycle)

    if cycle < TEST_CYCLES:
        print(f"Waiting {TEST_INTERVAL} seconds for the next test cycle...\n")
        time.sleep(TEST_INTERVAL)

print("Testing completed. Results saved to randomness_test_noprocessing  ,.csv")

# Plot results
data = np.loadtxt(OUTPUT_LOG, delimiter=",", skiprows=1, usecols=(1,2,3,4,5))
plt.figure(figsize=(12, 6))
labels = ["Mean", "Variance", "Entropy", "KS p-value", "Monobit Ratio"]
for i in range(data.shape[1]):
    plt.plot(range(1, TEST_CYCLES + 1), data[:, i], label=labels[i])

plt.xlabel("Test Cycle")
plt.ylabel("Value")
plt.title("Randomness Test Over Time")
plt.legend()
plt.grid()
plt.show()
