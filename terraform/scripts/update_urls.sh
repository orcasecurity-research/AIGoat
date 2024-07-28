#!/bin/bash
directory=$1
url=$2

find "$directory" -type f \( -name "*.html" -o -name "*.js" -o -name "*.js.map" \) -print0 |
xargs -0 sed -i.bak "s|PLACE_HOLDER|http://$url:8000|g"

# Check if backup files are created
find "$directory" -name "*.bak" -type f -print

# Remove backup files created by sed
find "$directory" -name "*.bak" -type f -delete

# Verify if backup files are deleted
find "$directory" -name "*.bak" -type f -print
