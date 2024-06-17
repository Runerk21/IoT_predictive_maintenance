import os
import numpy as np

# Specify the folder containing the compressed .npz files
folder_path = "add path"

# List all files in the folder
files = os.listdir(folder_path)

# Filter out only the .npz files
npz_files = [file for file in files if file.endswith('.npz')]

# Convert the .npz files to .csv files saving the timestamp in the first column,
# the time in the secound column, and the amplitude in the third
for filename in npz_files:
    full_path = os.path.join(folder_path, filename)
    loaded = np.load(full_path)
    data = loaded['a']
    csv_filename = filename.replace('.npz', '.csv')
    csv_filepath = os.path.join(folder_path, csv_filename)

    np.savetxt(csv_filepath, data, delimiter=",", fmt="%s", header="Timestamp,Time (s),Amplitude", comments="")
