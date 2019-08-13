#!/usr/bin/python
# permissions need to be 755 or more restrictive.
import collections, csv, datetime, json, sys, os
from write_csv import write_csv

sys.stderr = sys.stdout  # Make sure we can see any errors
data_dir = "../data/"
data = json.load(sys.stdin, object_pairs_hook=collections.OrderedDict)
file_name = data_dir + data["file_name"]
file_data = data["file_data"]
success = write_csv(file_name, file_data)
sys.stdout.write("Content-type: text/plain; charset=UTF-8\n\n")
sys.stdout.write("--SERVER: Data saved = " + str(success))
