#!/bin/bash

# Create a directory named Dockerfiles
mkdir -p Dockerfiles

# Download files into the Dockerfiles directory
curl -o Dockerfiles/Dockerfile-db https://raw.githubusercontent.com/hakidon/Ansible-testbed/refs/heads/main/Dockerfiles/Dockerfile-db
curl -o Dockerfiles/Dockerfile-be https://raw.githubusercontent.com/hakidon/Ansible-testbed/refs/heads/main/Dockerfiles/Dockerfile-be
curl -o Dockerfiles/Dockerfile-fe https://raw.githubusercontent.com/hakidon/Ansible-testbed/refs/heads/main/Dockerfiles/Dockerfile-fe
curl -o Dockerfiles/docker-compose.yml https://raw.githubusercontent.com/hakidon/Ansible-testbed/refs/heads/main/Dockerfiles/docker-compose.yml

mkdir -p Dockerfiles/be
mkdir -p Dockerfiles/fe/src

curl -o Dockerfiles/be/server.js https://raw.githubusercontent.com/hakidon/Ansible-testbed/refs/heads/main/be/server.js
curl -o download-repo.sh https://raw.githubusercontent.com/hakidon/Ansible-testbed/refs/heads/main/scripts/download-repo.sh

chmod +x download-repo.sh
./download-repo.sh https://api.github.com/repos/hakidon/Ansible-testbed/contents/fe/src Dockerfiles/fe/src


# Start the Docker Compose services
sudo docker compose -f Dockerfiles/docker-compose.yml up -d
