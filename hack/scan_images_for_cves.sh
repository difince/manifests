#!/bin/bash

if ! [ -x "$(command -v trivy)" ]; then
  echo 'Error: trivy is not installed.' >&2
  exit 1
fi 

IMAGE_LISTS_DIR="../docs/image_lists"

# Check if the directory exists
if [ ! -d "$IMAGE_LISTS_DIR" ]; then
    echo "Directory not found: $IMAGE_LISTS_DIR"
    exit 1
fi

CVE_REPORTS_DIR="../docs/cve-reports/"
mkdir -p "$CVE_REPORTS_DIR"

# Iterate through each file in the directory 
for file in "$IMAGE_LISTS_DIR"/*; do
    # Extract the file name without the path
    filename=$(basename "$file")
    cve_filename="$CVE_REPORTS_DIR/$filename"
    echo "Scanning images from file: $file"
      # Read the image names from the file and iterate through them
      while IFS= read -r image_name; do
          echo "> Scanning image: $image_name"
          trivy  image "$image_name" --scanners vuln -q >> "$cve_filename"

          # Check the exit code of Trivy
          if [ $? -ne 0 ]; then
              echo "Error scanning $image_name" >> "$cve_filename"
          fi
      done < "$file"

      echo "Done scanning images from file: $file"
      echo "--||--||--||--||--||--||--||--||--||--||--||--"

done

