#!/bin/bash

echo "====================================="
echo "        USER CREATION SCRIPT"
echo "====================================="

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run this script as root or with sudo."
   exit 1
fi

# Validate arguments
if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <username> <fullname> <password> [sudo:y/n] [forcepass:y/n]"
  exit 1
fi

# Assign arguments
USERNAME=$1
FULLNAME=$2
PASSWORD=$3
SUDO_ACCESS=${4:-n}
FORCE_PASS=${5:-n}

# Check if user already exists
if id "$USERNAME" &>/dev/null; then
    echo "User '$USERNAME' already exists!"
    exit 1
fi

# Create user
useradd -m -s /bin/bash -c "$FULLNAME" "$USERNAME"

# Set password
echo "$USERNAME:$PASSWORD" | chpasswd

# Add sudo access if requested
if [[ "$SUDO_ACCESS" == "y" || "$SUDO_ACCESS" == "Y" ]]; then
    usermod -aG sudo "$USERNAME"
    echo "User added to sudo group."
fi

# Force password change if requested
if [[ "$FORCE_PASS" == "y" || "$FORCE_PASS" == "Y" ]]; then
    chage -d 0 "$USERNAME"
    echo "User must change password on first login."
fi

echo
echo "User '$USERNAME' created successfully!"
echo "-------------------------------------"
echo "Username: $USERNAME"
echo "Full Name: $FULLNAME"
echo "Home Dir: /home/$USERNAME"
echo "Shell: /bin/bash"
echo "-------------------------------------"