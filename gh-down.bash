#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install jq before running this script."
  exit 1
fi

# Get the URL from the first argument
url="$1"

# The ourput file
output_file="$2"

# Check if the argument is provided
if [[ -z "$url" ]]; then
  echo "Error: Please provide the URL of the JSON response as an argument."
  exit 1
fi

# Check if the argument is provided
if [[ -z "$output_file" ]]; then
  echo "Warn: Output file not provided, writing to output.txt"
  output_file="output.txt"
fi

# Temporary file for downloaded JSON
temp_file=$(mktemp --suffix=.json)

# Download the JSON response using wget
wget -q -O "$temp_file" "$url"

# Check if the download was successful (exit code 0 indicates success)
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to download JSON response from $url."
  rm "$temp_file"
  exit 1
fi

# Extract "rawLines" from downloaded JSON
json_response=$(jq -r '.payload.blob.rawLines' < "$temp_file")

# Remove temporary file
rm "$temp_file"

# ... rest of the script remains the same ...

# Loop through each line in the array and write it to the output file
while IFS=',' read -r line; do
  # Remove quotes from the line
  line=${line%\"\"}
  line=${line#\"}
  echo "$line" >> output.txt
done <<< "$json_response"

echo "Lines extracted successfully and written to output.txt"
