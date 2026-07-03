#!/bin/bash

# 1. Check if exactly 2 arguments were provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <old_name> <new_name>"
    exit 1
fi

OLD_NAME="$1"
NEW_NAME="$2"

# 2. Check if the source exists at all
if [ ! -e "$OLD_NAME" ]; then
    echo "Error: Cannot find '$OLD_NAME'"
    exit 1
fi

# 3. Determine if it is a File or Directory for better reporting
if [ -d "$OLD_NAME" ]; then
    TYPE="Directory"
elif [ -f "$OLD_NAME" ]; then
    TYPE="File"
else
    TYPE="Other object" # For symlinks, sockets, etc.
fi

# 4. Check if destination already exists to prevent accidental overwrites/merges
if [ -e "$NEW_NAME" ]; then
    echo "Error: Cannot rename because '$NEW_NAME' already exists."
    exit 1
fi

# 5. Perform the rename using 'mv' with strict quoting
if mv "$OLD_NAME" "$NEW_NAME"; then
    echo "Success: Renamed $TYPE '$OLD_NAME' to '$NEW_NAME'"
else
    echo "Error: Failed to rename. Check permissions."
    exit 1
fi
