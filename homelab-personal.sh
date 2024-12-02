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
echo "Running Cockpit and Additional Tools Installer for Ubuntu by Clark Weckmann"
echo "This script will install Cockpit, Docker, Portainer, Identities Plugin, and Tailscale."

# Step 1: Update package list and install Cockpit
(sudo apt-get update >/dev/null 2>&1 && sudo apt-get install cockpit -y >/dev/null 2>&1) &
show_step "Installing Cockpit" $!

# Step 2: Enable and start Cockpit socket
(sudo systemctl enable --now cockpit.socket >/dev/null 2>&1) &
show_step "Enabling and starting Cockpit service" $!

# Step 3: Open firewall port for Cockpit
(sudo ufw allow 9090 >/dev/null 2>&1) &
show_step "Allowing Cockpit port 9090 in UFW" $!

# Step 4: Add 45Drives repository and install Identities Plugin
(curl -sSL https://repo.45drives.com/setup | sudo bash >/dev/null 2>&1 && sudo apt update >/dev/null 2>&1 && sudo apt install cockpit-identities -y >/dev/null 2>&1) &
show_step "Installing Identities Plugin" $!

# Step 5: Install Docker
(
  sudo apt-get install -y ca-certificates curl >/dev/null 2>&1
  sudo install -m 0755 -d /etc/apt/keyrings >/dev/null 2>&1
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc >/dev/null 2>&1
  sudo chmod a+r /etc/apt/keyrings/docker.asc >/dev/null 2>&1
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update >/dev/null 2>&1
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null 2>&1
) &
show_step "Installing Docker" $!

# Step 6: Install Portainer
(
  sudo docker volume create portainer_data >/dev/null 2>&1
  sudo docker run -d -p 8000:8000 -p 9000:9000 -p 9443:9443 --name portainer --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.4 >/dev/null 2>&1
) &
show_step "Installing Portainer" $!

# Step 7: Install Tailscale
(
  curl -fsSL https://tailscale.com/install.sh | sh >/dev/null 2>&1
) &
show_step "Installing Tailscale" $!

# Step 8: Prompt user for Tailscale auth key and configure Tailscale
echo -n "Enter your Tailscale auth key: "
read -r TAILSCALE_AUTH_KEY
sudo tailscale up --auth-key="$TAILSCALE_AUTH_KEY"
if [ $? -eq 0 ]; then
  echo "Tailscale is configured successfully."
else
  echo "Tailscale configuration failed. Please check the auth key and try again."
fi

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