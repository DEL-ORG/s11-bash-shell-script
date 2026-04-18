#!/bin/bash

echo "====================================="
echo "        USER CREATION SCRIPT"
echo "====================================="

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ Please run this script as root or with sudo."
   exit 1
fi

# Prompt for user details
read -p "Enter username: " USERNAME
read -p "Enter full name: " FULLNAME
read -s -p "Enter password: " PASSWORD
echo
read -s -p "Confirm password: " PASSWORD_CONFIRM
echo

# Validate password match
if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
    echo "❌ Passwords do not match. Exiting..."
    exit 1
fi

# Check if user already exists
if id "$USERNAME" &>/dev/null; then
    echo "❌ User '$USERNAME' already exists!"
    exit 1
fi

# Create user with home directory and bash shell
useradd -m -s /bin/bash -c "$FULLNAME" "$USERNAME"

# Set password
echo "$USERNAME:$PASSWORD" | chpasswd

# Ask if user should have sudo privileges
read -p "Should this user have sudo privileges? (y/n): " SUDO_ACCESS

if [[ "$SUDO_ACCESS" == "y" || "$SUDO_ACCESS" == "Y" ]]; then
    usermod -aG sudo "$USERNAME"
    echo "✅ User added to sudo group."
fi

# Force password change on first login (optional)
read -p "Force password change on first login? (y/n): " FORCE_PASS

if [[ "$FORCE_PASS" == "y" || "$FORCE_PASS" == "Y" ]]; then
    chage -d 0 "$USERNAME"
    echo "✅ User will be required to change password on first login."
fi

echo
echo "✅ User '$USERNAME' created successfully!"
echo "-------------------------------------"
echo "Username: $USERNAME"
echo "Full Name: $FULLNAME"
echo "Home Dir: /home/$USERNAME"
echo "Shell: /bin/bash"
echo "-------------------------------------"