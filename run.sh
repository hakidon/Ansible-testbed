#!/bin/bash

# Update package list and install necessary packages
sudo apt update
sudo apt install git curl -y

# Function to show elapsed time for the installation
show_timer() {
    local duration=0
    echo -n "Installing Docker"
    while ps aux | grep -q "[s]nap install docker"; do
        sleep 1
        duration=$((duration + 1))
        echo -ne "\rInstalling Docker... ${duration} seconds"
    done
    echo -e "\rInstalling Docker... Done!"
}

# Install Docker with a timer
sudo snap install docker &
show_timer

# Clone the repository
git clone https://github.com/hakidon/Ansible-testbed.git 

# Start Docker containers
sudo docker compose -f Ansible-testbed/docker-compose.yml up -d