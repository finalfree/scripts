import os
import shutil


destination_folder = "Z:\\"

files_dict = dict()


for file in os.listdir(destination_folder):
    file_path = os.path.join(destination_folder, file)
    if os.path.isfile(file_path):
        file_size = os.path.getsize(file_path)
        if arr := files_dict.get(file_size):
            arr.append(file_path)
        else:
            arr = [file_path]
            files_dict[file_size] = arr

for arr in files_dict.values():
    if len(arr) <= 1:
        continue
    for file in arr:
        file_extension = file.split('.')[-1]
        if file.endswith(f"(1).{file_extension}"):
            if arr.__contains__(file.removesuffix(f"(1).{file_extension}") + "." + file_extension):
                print(f"try to remove {file}")
                os.remove(file)

    if len(arr) > 1:
        print(arr)