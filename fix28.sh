#!/bin/bash

# Stop Docker and Containerd
systemctl stop docker
systemctl stop containerd

# Download and install Docker
wget https://download.docker.com/linux/static/stable/x86_64/docker-24.0.6.tgz
tar xzvf docker-24.0.6.tgz
cp docker/* /usr/bin/

# Remove the existing runc
rm -f /usr/sbin/runc

# Download and configure containerd
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -O /usr/lib/systemd/system/containerd.service
sed -i 's/local\///g' /usr/lib/systemd/system/containerd.service

# Download Docker systemd unit files
wget https://raw.githubusercontent.com/moby/moby/master/contrib/init/systemd/docker.service -O /usr/lib/systemd/system/docker.service
wget https://raw.githubusercontent.com/moby/moby/master/contrib/init/systemd/docker.socket -O /usr/lib/systemd/system/docker.socket

# Reload systemd and start containerd and docker
systemctl daemon-reload
systemctl start containerd
systemctl start docker

# Install Docker Compose
curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

# Cleanup - Remove downloaded archive and extracted files
rm -rf docker-24.0.6.tgz docker

# Pull Docker images
sudo docker pull edgify/edgify-agent:1.28.0
sudo docker pull edgify/edgify-collaborator:2.1.3
sudo docker pull edgify/edgify-worker-cpu:2.1.3

# Remove docker-compose-agent.yml
rm -f docker-compose-agent.yml

# Download docker-compose.yml
wget https://raw.githubusercontent.com/Omriak10/Edgify/main/docker-compose.yml

# Start Docker Compose
sudo docker-compose up -d

echo "Docker installation, configuration, and application setup completed successfully."
