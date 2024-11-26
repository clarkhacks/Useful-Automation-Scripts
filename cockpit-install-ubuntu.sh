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

# Log Cockpit access URL
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "Cockpit is running on https://$IP_ADDRESS:9090"
