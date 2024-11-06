#!/bin/bash
set -e

# Define the archive URL
archive="http://34.95.11.164:31403/"

# Print start message
echo "Running stellar-archivist mirror process from ${archive}"

# Run stellar-archivist mirror command
stellar-archivist mirror "${archive}" "file:///opt/stellar/history/local/"
