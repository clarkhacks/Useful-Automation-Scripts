#!/bin/bash

# Function to display a step message with a loading spinner
show_step() {
  local msg=$1
  local pid=$2
  echo -n "$msg"
  while kill -0 "$pid" 2>/dev/null; do
    echo -n "."
    sleep 0.5
  done
  echo " done."
}

# Log the start of the script
echo "Running Cockpit Install For Ubuntu By Clark Weckmann"
echo "This script will install and configure Cockpit with a few addons from 45Drives"

# Step 1: Update package list and install Cockpit
(sudo apt-get update >/dev/null 2>&1 && sudo apt-get install cockpit -y >/dev/null 2>&1) &
show_step "Installing Cockpit" $!

# Step 2: Enable and start Cockpit socket
(sudo systemctl enable --now cockpit.socket >/dev/null 2>&1) &
show_step "Enabling and starting Cockpit service" $!

# Step 3: Open firewall port for Cockpit
(sudo ufw allow 9090 >/dev/null 2>&1) &
show_step "Allowing Cockpit port 9090 in UFW" $!

# Step 4: Add 45Drives repository
(curl -sSL https://repo.45drives.com/setup | sudo bash >/dev/null 2>&1) &
show_step "Adding 45Drives repository" $!

# Step 5: Update package list and install Cockpit Navigator and File Sharing
(sudo apt-get update >/dev/null 2>&1 && sudo apt install -y cockpit-navigator cockpit-file-sharing >/dev/null 2>&1) &
show_step "Installing Cockpit Navigator and File Sharing modules" $!

# Step 6: Check if Samba is installed and install if missing
if ! dpkg -l | grep -q samba; then
  (sudo apt install -y samba >/dev/null 2>&1) &
  show_step "Installing Samba" $!
else
  echo "Samba is already installed."
fi

# Step 7: Restart Cockpit and Samba services
(sudo systemctl restart cockpit smb smbd >/dev/null 2>&1) &
show_step "Restarting Cockpit and Samba services" $!

# Log Cockpit access URL
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "Cockpit is running on https://$IP_ADDRESS:9090"

# Ask if the user wants to delete the script
echo -n "Do you want to delete this install script? (y/n): "
read -r DELETE_SCRIPT

if [[ "$DELETE_SCRIPT" == "y" || "$DELETE_SCRIPT" == "Y" ]]; then
  echo "Deleting install script..."
  rm -- "$0"
  echo "Install script deleted."
else
  echo "Install script retained."
fi
