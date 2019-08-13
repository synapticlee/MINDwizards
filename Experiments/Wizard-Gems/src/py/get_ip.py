#!/usr/bin/python
# permissions need to be 755 or more restrictive.
import os, sys

sys.stderr = sys.stdout  # Make sure we can see any errors
ip_address = os.environ["REMOTE_ADDR"]
sys.stdout.write("Content-type: text/plain\n\n")
sys.stdout.write(ip_address)
