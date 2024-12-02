# Automation Scripts

These are a handful of scripts I use to make my life and job easier. Give each one a thumb through if you're using them yourself to make sure there isn't a random 'only works for me' item in there.

## Bash Scripts

### Cockpit Ubuntu Install

This script installs Cockpit on Ubuntu along with additional modules for file sharing and navigation.

```bash
curl -fsSL https://sh.clarktoday.com/cockpit-install-ubuntu.sh | sudo bash
```

### Homelab Personal Setup

This script sets up a personal homelab environment. It installs and configures:

* Cockpit: A powerful web interface for server management.

* Identities Plugin: Enhances Cockpit with user identity management features.

* Docker: Container platform for deploying applications.

* Portainer: A web interface for managing Docker containers.

* Tailscale: A secure VPN service for networking between devices.


Run the script with the following command:

```bash
curl -fsSL https://sh.clarktoday.com/homelab-personal.sh | sudo bash
```

Features:

* Configures and starts Cockpit services.

* Opens the necessary ports for Cockpit on the firewall.

* Installs Docker and its plugins.

* Sets up Portainer to manage Docker containers.

* Installs and configures Tailscale, prompting for an authentication key during the setup.

