#!/bin/bash

echo "====================================="
echo "        SSH LOGIN AUTOMATION"
echo "====================================="

# Prompt for inputs
read -p "Enter your preferred username: " USERNAME
read -p "Enter your password: " PASSWORD
echo
read -p "Enter server FQDN (e.g. server.example.com): " SERVER

echo
echo "Connecting to $SERVER as $USERNAME..."
echo

# SSH connection (will prompt for password securely)
ssh "$USERNAME@$SERVER"
# ssh tia@bastion.devopseasylearning.net

echo
echo "Connection closed."