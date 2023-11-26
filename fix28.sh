#!/bin/bash

# 1 - Stop Docker and containerd
sudo systemctl stop docker
sudo systemctl stop containerd

# 2 - Download Docker binary
wget https://download.docker.com/linux/static/stable/x86_64/docker-24.0.6.tgz

# 3 - Extract Docker binary
tar xzvf docker-24.0.6.tgz

# 4 - Copy Docker binary to /usr/bin/
sudo cp docker/* /usr/bin/

# 5 - Download and configure containerd service
sudo wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -O /usr/lib/systemd/system/containerd.service
sudo sed -i 's/local\///g' /usr/lib/systemd/system/containerd.service

# 6 - Download Docker systemd service and socket files
sudo wget https://raw.githubusercontent.com/moby/moby/master/contrib/init/systemd/docker.service -O /usr/lib/systemd/system/docker.service
sudo wget https://raw.githubusercontent.com/moby/moby/master/contrib/init/systemd/docker.socket -O /usr/lib/systemd/system/docker.socket

# 7 - Reload systemd configuration
sudo systemctl daemon-reload

# 8 - Start containerd and Docker
sudo systemctl start containerd
sudo systemctl start docker

# 9 - Cleanup - Remove downloaded archive and extracted files
rm -rf docker-24.0.6.tgz docker

# 10 - Pull Docker images
sudo docker pull edgify/edgify-agent:1.28.0
sudo docker pull edgify/edgify-collaborator:2.1.3
sudo docker pull edgify/edgify-worker-cpu:2.1.3

# 11 - Remove docker-compose-agent.yml
rm docker-compose-agent.yml

# 12 - Download docker-compose.yml
wget https://raw.githubusercontent.com/Omriak10/Edgify/main/docker-compose.yml

# 13 - Start Docker Compose
sudo docker-compose up -d

echo "Docker installation, configuration, and application setup completed successfully."
