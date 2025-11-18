#!/bin/bash

# This script is executed by the Renovate GitHub Action
# It sets up the environment and runs Renovate

set -e

# Install yq in the container
echo "Installing yq..."
curl -sL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq
chmod +x /usr/local/bin/yq

# Debug information
echo "Starting Renovate..."
echo "Repository Owner: ${GITHUB_REPOSITORY_OWNER}"
echo "Log Level: ${LOG_LEVEL}"
echo "Renovate Version: $(renovate --version)"

# Validate required environment variables
if [ -z "$RENOVATE_TOKEN" ]; then
    echo "Error: RENOVATE_TOKEN is not set"
    exit 1
fi

if [ -z "$RENOVATE_PLATFORM" ]; then
    echo "Error: RENOVATE_PLATFORM is not set"
    exit 1
fi

# Set default values
export RENOVATE_PLATFORM=${RENOVATE_PLATFORM:-github}
export LOG_LEVEL=${LOG_LEVEL:-info}
export RENOVATE_LOG_LEVEL=${RENOVATE_LOG_LEVEL:-info}

# GitHub App specific settings
if [ -n "$RENOVATE_USERNAME" ]; then
    echo "Using GitHub App username: $RENOVATE_USERNAME"
fi

if [ -n "$RENOVATE_GIT_AUTHOR" ]; then
    echo "Using GitHub App git author: $RENOVATE_GIT_AUTHOR"
fi

# Repository configuration
if [ -n "$RENOVATE_REPOSITORIES" ]; then
    echo "Running on specific repositories: $RENOVATE_REPOSITORIES"
else
    echo "Running on all repositories in organization: $GITHUB_REPOSITORY_OWNER"
fi

# Configuration file check
if [ -f "$RENOVATE_CONFIG_FILE" ]; then
    echo "Using configuration file: $RENOVATE_CONFIG_FILE"
else
    echo "Warning: Configuration file not found: $RENOVATE_CONFIG_FILE"
fi

# GitHub.com token check for changelog lookups
if [ -n "$RENOVATE_GITHUB_COM_TOKEN" ]; then
    echo "GitHub.com token configured for changelog lookups"
else
    echo "Warning: RENOVATE_GITHUB_COM_TOKEN not set - may hit rate limits for changelog lookups"
fi

# Run Renovate
echo "Running Renovate..."
exec renovate "$@"
