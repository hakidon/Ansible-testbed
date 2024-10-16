#!/bin/bash

# Update package list
apt update

# Install Docker and necessary tools
if apt install -y docker curl git; then
    echo "Docker, curl, and git installed successfully."
else
    echo "Failed to install Docker, curl, or git."
    # Try to use snap if installation failed
    if sudo snap install docker; then
        echo "Docker installed via snap."
    else
        echo "Failed to install Docker via snap. Trying yum..."
        # Check if yum is available (for RHEL/CentOS)
        if command -v yum &> /dev/null; then
            if yum install -y docker; then
                echo "Docker installed via yum."
            else
                echo "Failed to install Docker via yum."
                echo "Your operating system is not supported."
            fi
        else
            echo "Your operating system is not supported."
        fi
    fi
fi

git clone https://github.com/hakidon/Ansible-testbed.git 

sudo docker compose -f docker-compose.yml up -d
