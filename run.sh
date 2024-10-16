#!/bin/bash
sudo apt update
sudo apt install git curl -y
sudo snap install docker

git clone https://github.com/hakidon/Ansible-testbed.git 

sudo docker compose -f Ansible-testbed/docker-compose.yml up -d
