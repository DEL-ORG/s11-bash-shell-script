#!/bin/bash

set -euo pipefail

FILE="users.txt"

# Ensure root
if [[ $EUID -ne 0 ]]; then
  echo "Run as root"
  exit 1
fi

# Read file safely into array (line by line)
mapfile -t users < "$FILE"

for raw_user in "${users[@]}"; do

  # Skip empty lines
  [[ -z "$raw_user" ]] && continue

  # Convert to lowercase
  username=$(echo "$raw_user" | tr '[:upper:]' '[:lower:]')

  echo "Processing $username"

  # Check if exists
  if id "$username" &>/dev/null; then
    echo "User exists, skipping..."
    continue
  fi

  # Create user
  useradd -m -s /bin/bash "$username"

  # Set password
  echo "$username:$username" | chpasswd

  # Fix ownership + permissions
  chown -R "$username:$username" "/home/$username"
  chmod 700 "/home/$username"

  echo "User $username created"
  echo "----------------------"

done

echo "Done"