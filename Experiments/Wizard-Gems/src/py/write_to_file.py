#!/usr/bin/python
# permissions need to be 755 or more restrictive.
def write_to_file(file_name, data):
    import collections, csv, datetime, json, sys, os

    access_time = str(datetime.datetime.now())
    sys.stderr = sys.stdout  # Make sure we can see any errors
    # Write headers if the file doesn't exist
    if not os.path.exists(file_name):
        with open(file_name, "w") as output_file:
            writer = csv.writer(output_file, delimiter=",")
            # Only write one row
            for row in data:
                writer.writerow(row.keys() + ["ip"] + ["access_time"])
                break
        os.chmod(file_name, 0o640)  # change permissions

    # Write out actual data
    with open(file_name, "a") as output_file:
        writer = csv.writer(output_file, delimiter=",")
        for row in data:
            row["ip"] = os.environ["REMOTE_ADDR"]
            row["access_time"] = access_time
            writer.writerow(row.values())

    sys.stdout.write("Content-type: text/plain; charset=UTF-8\n\n")
    sys.stdout.write("--SERVER: Data saved successfully!")
    return True
