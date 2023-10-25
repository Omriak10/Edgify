#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root or with sudo."
  exit 1
fi

# Function to install Filebeat
install_filebeat() {
  # Get the system name
  system_name=$(hostname)

  # Get the local IP address
  local_ip=$(ip -o -4 addr show scope global | awk '{print $4}' | cut -d'/' -f1)

  # Ask the user for the environment name
  read -p "Enter environment name: " environment_name

  # Add Elastic repository and import GPG key
  echo "Adding Elastic repository..."
  echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

  # Update package index
  echo "Updating package index..."
  sudo apt update

  # Install Filebeat 8.7.1
  echo "Installing Filebeat 8.7.1..."
  sudo apt install -y filebeat=8.7.1

  # Create the Filebeat configuration file with provided content
  echo "Creating Filebeat configuration file..."
  sudo tee /etc/filebeat/filebeat.yml <<EOF
filebeat.inputs:
- type: filestream
  id: edgify-agent
  paths:
    - /edgify_agent/logs/agent.log
  parsers:
    - ndjson:
        target: "edgify"
        expand_keys: false
        message_key: message
  ignore_older: 12h
  close.on_state_changes.renamed: true
  fields_under_root: true
  fields:
    environment: "$environment_name"
    type: agent
    edgify.local_ip: "$local_ip"
    edgify.device_name: "$system_name"

- type: filestream
  id: edgify-worker
  paths:
    - /edgify_agent/logs/worker/training.log
  parsers:
    - ndjson:
        target: "edgify"
        expand_keys: false
        message_key: message
  ignore_older: 12h
  close.on_state_changes.renamed: true
  fields_under_root: true
  fields:
    environment: "$environment_name"
    type: worker
    edgify.local_ip: "$local_ip"
    edgify.device_name: "$system_name"

- type: filestream
  id: edgify-collaborator
  paths:
    - /edgify_agent/logs/collaborator/training.log
  parsers:
    - ndjson:
        target: "edgify"
        expand_keys: false
        message_key: message
  ignore_older: 12h
  close.on_state_changes.renamed: true
  fields_under_root: true
  fields:
    environment: "$environment_name"
    type: collaborator
    edgify.local_ip: "$local_ip"
    edgify.device_name: "$system_name"

processors:
  - timestamp:
      field: edgify.time
      layouts:
        - '2006-01-02T15:04:05Z'
        - '2006-01-02T15:04:05.999Z'
        - '2006-01-02T15:04:05.999999Z'
        - '2006-01-02T15:04:05.999999999Z'
        - '2006-01-02T15:04:05.999-07:00'

cloud.id: "Edgify:ZXVyb3BlLXdlc3QxLmdjcC5jbG91ZC5lcy5pbzo0NDMkMzNkMDFiOWJlN2U2NGM4M2JiNDZiMTQ3ZjI1MDljMzgkY2ViYmI1NTI0YTg3NGZkZDlmNzU3ODA0NDE0MTBmN2Q="
cloud.auth: "elastic:c5r7FoF6QPgnP2hXcWZ33gm3"

output.elasticsearch.index: "edgify-edge-$environment_name"
setup.template.name: "edgify-ds-edge"
setup.template.pattern: "edgify-edge-*"
EOF

  # Start and enable Filebeat service
  sudo service filebeat start
  sudo systemctl enable filebeat

  # Show Filebeat status
  echo "Checking Filebeat status..."
  sudo service filebeat status
}

# Call the function to install Filebeat
install_filebeat
