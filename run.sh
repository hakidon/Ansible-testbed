#!/bin/bash

# Update package list and install necessary packages
sudo apt update
sudo apt install git curl -y

# Function to show a loading progress bar
show_progress() {
    echo -n "Installing Docker"
    while ps aux | grep -q "[s]nap install docker"; do
        echo -n "."
        sleep 1
    done
    echo " Done!"
}

# Install Docker with a progress indicator
sudo snap install docker &
show_progress

# Clone the repository
git clone https://github.com/hakidon/Ansible-testbed.git 

# Start Docker containers
sudo docker compose -f Ansible-testbed/docker-compose.yml up -d