#!/usr/bin/python
# permissions need to be 755 or more restrictive.
def write_csv(file_name, file_data):
    import csv, sys

    with open(file_name, "a") as output_file:
        output_file.writelines(file_data)

    sys.stdout.write("Content-type: text/plain; charset=UTF-8\n\n")
    sys.stdout.write("--SERVER: Data saved successfully!")
    return True
