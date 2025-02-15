#!/bin/bash
# This script checks if the user is logged in to Docker and logs them in if they are not.

# Function to check if the user is logged in to Docker
is_logged_in() {
    # Check if the Docker config file contains an auth entry
    if [ -f "$HOME/.docker/config.json" ]; then
        # Check for the presence of "auths" in the config file
        grep -q '"auths": {' "$HOME/.docker/config.json" && grep -q '"https://index.docker.io/v1/": {}' "$HOME/.docker/config.json"
        return $?
    else
        return 1
    fi
}

# Check if the user is already logged in
if is_logged_in; then
    echo "Already logged in to Docker."
else
    echo "Not logged in to Docker. Initiating login..."
    docker login
fi 