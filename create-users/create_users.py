#!/usr/bin/env python3

import os
import sys
import subprocess
import getpass

def main():
    print("=====================================")
    print("        USER CREATION SCRIPT")
    print("=====================================")

    if os.geteuid() != 0:
        print("❌ Please run this script as root or with sudo.")
        sys.exit(1)

    username = input("Enter username: ")
    fullname = input("Enter full name: ")
    password = getpass.getpass("Enter password: ")
    password_confirm = getpass.getpass("Confirm password: ")

    if password != password_confirm:
        print("❌ Passwords do not match. Exiting...")
        sys.exit(1)

    result = subprocess.run(["id", username], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if result.returncode == 0:
        print(f"❌ User '{username}' already exists!")
        sys.exit(1)

    subprocess.run(["useradd", "-m", "-s", "/bin/bash", "-c", fullname, username], check=True)

    chpasswd = subprocess.run(["chpasswd"], input=f"{username}:{password}", text=True, check=True)

    sudo_access = input("Should this user have sudo privileges? (y/n): ")
    if sudo_access.lower() == "y":
        subprocess.run(["usermod", "-aG", "sudo", username], check=True)
        print("✅ User added to sudo group.")

    force_pass = input("Force password change on first login? (y/n): ")
    if force_pass.lower() == "y":
        subprocess.run(["chage", "-d", "0", username], check=True)
        print("✅ User will be required to change password on first login.")

    print(f"\n✅ User '{username}' created successfully!")
    print("-------------------------------------")
    print(f"Username: {username}")
    print(f"Full Name: {fullname}")
    print(f"Home Dir: /home/{username}")
    print(f"Shell:    /bin/bash")
    print("-------------------------------------")

if __name__ == "__main__":
    main()
