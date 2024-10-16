#!/bin/bash

# Function to update the package manager
update_package_manager() {
    if command -v apt &> /dev/null; then
        echo "Updating package list with apt..."
        sudo apt update
    elif command -v snap &> /dev/null; then
        echo "Updating packages with snap..."
        sudo snap refresh
    elif command -v yum &> /dev/null; then
        echo "Updating packages with yum..."
        sudo yum update -y
    else
        echo "No supported package manager found. Please update manually."
    fi
}

# Function to check and install a package
install_package() {
    local package_name="$1"
    local installed=false

    if command -v "$package_name" &> /dev/null; then
        echo "$package_name is already installed. Skipping installation."
        return 0
    fi

    # Try to install the package using apt
    if command -v apt &> /dev/null; then
        if sudo apt install -y "$package_name"; then
            echo "$package_name installed successfully via apt."
            installed=true
        fi
    fi

    # Try to install the package using snap
    if command -v snap &> /dev/null; then
        if sudo snap install "$package_name"; then
            echo "$package_name installed successfully via snap."
            installed=true
        fi
    fi

    # Try to install the package using yum
    if command -v yum &> /dev/null; then
        if sudo yum install -y "$package_name"; then
            echo "$package_name installed successfully via yum."
            installed=true
        fi
    fi

    # If not installed, print a message
    if [ "$installed" = false ]; then
        echo "---------------------------------"
        echo "Failed to install $package_name."
        echo "---------------------------------"
    fi
}

# Update the package manager
update_package_manager

# Install specified tools
install_package docker
install_package curl
install_package git

git clone https://github.com/hakidon/Ansible-testbed.git 
cd Ansible-testbed

sudo docker compose -f docker-compose.yml up -d
