import subprocess
import os
import shutil
import time
from datetime import datetime

# ===== Configuration ====
script_path = "./qrng_workflow.sh"
args = ["6553000", "128"]
raw_output_file = "raw_random.bin"
base_run_folder = "run_"
num_runs = 300
delay_seconds = 20 * 60 # 30 minutes

# === Step 1: Find next available run number ===
def get_next_run_number():
    i = 1
    while os.path.exists(f"{base_run_folder}{i}"):
        i += 1
    return i

# ==== Step 2: Run the script and capture output, erros, timestamps ===
def run_script():
    start_time = datetime.now()
    try:
        result = subprocess.run(
            [script_path] + args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            check=True
        )
        end_time = datetime.now()
        return {
            "success": True,
            "start": start_time,
            "end": end_time,
            "stdout": result.stdout,
            "stderr": result.stderr
        }
    except subprocess.CalledProcessError as e:
        end_time = datetime.now()
        return {
            "success": False,
            "start": start_time,
            "end": end_time,
            "stdout": e.stdout,
            "stderr": e.stderr
        }

#==== Step 3: Save run data ===
def save_run(result, run_folder):
    os.makedirs(run_folder)
    with open(os.path.join(run_folder, "details.txt"), "w") as f:
        f.write(f'''
        ===   QRNG Run ===\n
        Start Time: {result['start']}\n
        End Time: {result['end']}\n
        Status: {'SUCCESS' if result['success'] else 'FAILURE'}\n\n

        == STDOUT ===\n
        {result['stdout'] or '[No output]'}\n
        
        ==== STDERR ===\n
        {result['stderr'] or '[No Errors]'}\n
        ''')
    
    if os.path.exists(raw_output_file):
        shutil.move(raw_output_file, os.path.join(run_folder, raw_output_file))
    else:
        print(f"Warning: {raw_output_file} not found.")



# ==== Main Loop =====
if __name__ == "__main__":
    start_run = get_next_run_number()
    
    for i in range(start_run, start_run + num_runs):
        run_folder = f"{base_run_folder}{i}"
        print(f"[Run {i}] Running script, saving output to {run_folder}...")

        result = run_script()
        save_run(result, run_folder)

        print(f"[Run {i}] {'Success' if result['success'] else 'Failure'} - Waiting 30 minutes before next run...\n")

        if i < start_run + num_runs - 1:
            time.sleep(delay_seconds)
    
    print("All runs complete.")