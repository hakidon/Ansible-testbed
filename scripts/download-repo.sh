#!/bin/bash

# Function to download files
download_files() {
  local dir=$1
  local json=$2
  local urls=$(echo $json | grep -oP '"download_url": "\K(.*?)(?=")')
  local dir_urls=$(echo $json | grep -oP '"self": "\K(.*?)(?=")')
  local types=$(echo $json | grep -oP '"type": "\K(.*?)(?=")')
  local names=$(echo $json | grep -oP '"name": "\K(.*?)(?=")')

  local i=0
  while read -r type; do
    url=$(echo $urls | cut -d ' ' -f $((i + 1)))
    name=$(echo $names | cut -d ' ' -f $((i + 1)))
    dir_url=$(echo $dir_urls | cut -d ' ' -f $((i + 1)))

    if [ "$type" == "dir" ]; then
      mkdir -p "$dir/$name"
      json=$(curl -s "$dir_url")
      download_files "$dir/$name" "$json"
    else
      curl -o "$dir/$name" "$url"
    fi
    i=$((i + 1))
  done <<< "$types"
}

# Check if URL and directory are provided
if [ -z "$1" ]; then
  echo "Usage: $0 <url> [directory]"
  exit 1
fi

# Set the directory to the second parameter or default to the current directory
dir=${2:-.}

# Fetch the JSON response
json=$(curl -s "$1")

# Start downloading files
download_files "$dir" "$json"
