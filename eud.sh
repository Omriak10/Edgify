#!/bin/bash

# Step 1: Delete docker-compose.yml if it exists in the script's location
if [ -e docker-compose.yml ]; then
    rm docker-compose.yml
fi

# Step 2: Pull the Docker image edgify/edgify-agent:1.27.0
docker pull edgify/edgify-agent:1.27.0

# Step 3: Pull the Docker image edgify/edgify-worker-cpu:2.1.2
docker pull edgify/edgify-worker-cpu:2.1.2

# Step 4: Pull the Docker image edgify/edgify-collaborator:2.1.2
docker pull edgify/edgify-collaborator:2.1.2

# Step 5: Download the new docker-compose.yml from the specified URL
wget https://raw.githubusercontent.com/Omriak10/Edgify/main/docker-compose.yml

# Step 6: Run 'docker compose up -d'
docker compose up -d

# Step 7: Run 'docker-compose up -d'
docker-compose up -d
