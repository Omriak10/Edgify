#!/bin/bash

# Set up the repository
echo "Setting up Docker repository..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
echo "Adding Docker's GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the repository
echo "Adding Docker repository to apt sources..."
echo "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package index
echo "Updating apt package index..."
sudo apt-get update

# Install Docker Engine, containerd, and Docker Compose
echo "Installing Docker Engine, containerd, and Docker Compose..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

# Verify Docker installation
echo "Verifying Docker installation..."
sudo docker run hello-world

echo "Docker setup completed!"

