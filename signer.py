import subprocess
import sys
from pathlib import Path
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
from Crypto.Hash import HMAC, SHA256

# Constants
SHELL_SCRIPT = "/home/wole/Documents/research/research/qrng_workflow.sh"
OUTPUT_DIR = "/home/wole/Documents/research/research"
QRNG_OUTPUT_FILE = "raw_random.bin"
ENCRYPTED_OUTPUT_FILE = "encrypted_iot_data.bin"

def run_qrng(count=1, bits=256):
    """Runs the shell script to generate a 256-bit QRNG key"""
    cmd = [SHELL_SCRIPT, str(count), str(bits)]
    print(f"🔐 Running QRNG shell script: {' '.join(cmd)}")
    subprocess.run(cmd, cwd=OUTPUT_DIR, check=True)

    key_path = Path(OUTPUT_DIR) / QRNG_OUTPUT_FILE
    if not key_path.exists():
        raise FileNotFoundError(f"QRNG output file not found at: {key_path}")
    return key_path

def load_key(key_path):
    """Loads the first 32 bytes from raw_random.bin"""
    with open(key_path, "rb") as f:
        key = f.read(32)
    if len(key) < 32:
        raise ValueError("Key file contains less than 256 bits")
    return key

def encrypt_message(key, plaintext):
    """Encrypts plaintext using AES-CBC"""
    cipher = AES.new(key, AES.MODE_CBC)
    ciphertext = cipher.encrypt(pad(plaintext, AES.block_size))
    return cipher.iv, ciphertext

def sign_data(key, iv, ciphertext):
    """Creates an HMAC-SHA256 signature"""
    hmac = HMAC.new(key, digestmod=SHA256)
    hmac.update(iv + ciphertext)
    return hmac.digest()

def save_encrypted_data(filepath, iv, hmac_signature, ciphertext):
    """Saves IV + HMAC + ciphertext in one file"""
    with open(filepath, "wb") as f:
        f.write(iv)
        f.write(hmac_signature)
        f.write(ciphertext)

def main():
    if len(sys.argv) != 2:
        print("❗Usage: python3 encrypt_with_qrng.py <plaintext_file>")
        sys.exit(1)

    plaintext_path = Path(sys.argv[1])
    if not plaintext_path.exists():
        print(f"❗File not found: {plaintext_path}")
        sys.exit(1)

    print(f"📄 Plaintext file to encrypt: {plaintext_path}")

    # Step 1: Run QRNG shell script
    key_path = run_qrng(count=1, bits=256)

    # Step 2: Load key
    key = load_key(key_path)
    print(f"✅ Loaded 256-bit key: {key.hex()}")

    # Step 3: Read plaintext
    with open(plaintext_path, "rb") as f:
        plaintext = f.read()

    # Step 4: Encrypt
    iv, ciphertext = encrypt_message(key, plaintext)
    print(f"🔐 IV: {iv.hex()}")
    print(f"🔐 Ciphertext length: {len(ciphertext)} bytes")

    # Step 5: Sign
    hmac_sig = sign_data(key, iv, ciphertext)
    print(f"✍️ HMAC Signature: {hmac_sig.hex()}")

    # Step 6: Save output
    encrypted_file = Path(OUTPUT_DIR) / ENCRYPTED_OUTPUT_FILE
    save_encrypted_data(encrypted_file, iv, hmac_sig, ciphertext)
    print(f"✅ Encrypted data saved to: {encrypted_file}")

if __name__ == "__main__":
    main()
