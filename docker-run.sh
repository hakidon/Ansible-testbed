#!/bin/bash

# Create a directory named Dockerfiles
mkdir -p Dockerfiles

# Download files into the Dockerfiles directory
curl -o Dockerfiles/Dockerfile-db https://raw.githubusercontent.com/hakidon/Ansible-testbed/refs/heads/main/Dockerfiles/Dockerfile-db
curl -o Dockerfiles/Dockerfile-be https://raw.githubusercontent.com/hakidon/Ansible-testbed/refs/heads/main/Dockerfiles/Dockerfile-be
curl -o Dockerfiles/Dockerfile-fe https://raw.githubusercontent.com/hakidon/Ansible-testbed/refs/heads/main/Dockerfiles/Dockerfile-fe
curl -o Dockerfiles/docker-compose.yml https://raw.githubusercontent.com/hakidon/Ansible-testbed/refs/heads/main/Dockerfiles/docker-compose.yml

# Start the Docker Compose services
# sudo docker compose -f Dockerfiles/docker-compose.yml up -d
