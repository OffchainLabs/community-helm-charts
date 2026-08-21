#!/bin/bash

# This script is executed by the Renovate GitHub Action
# It sets up the environment and runs Renovate

set -e

YQ_VERSION="v4.53.3"
YQ_SHA256="fa52a4e758c63d38299163fbdd1edfb4c4963247918bf9c1c5d31d84789eded4"
HELM_VERSION="v3.13.0"
HELM_SHA256="138676351483e61d12dfade70da6c03d471bbdcac84eaadeb5e1d06fa114a24f"
PYYAML_VERSION="6.0.3"

# Install yq in the container
echo "Installing yq ${YQ_VERSION}..."
curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o /usr/local/bin/yq
echo "${YQ_SHA256}  /usr/local/bin/yq" | sha256sum -c -
chmod +x /usr/local/bin/yq

# Install Python and dependencies for README generation
echo "Installing Python and dependencies..."
apt-get update -qq
apt-get install -y -qq python3 python3-pip > /dev/null 2>&1
pip3 install -q --break-system-packages --ignore-installed "pyyaml==${PYYAML_VERSION}"

# Install Helm for chart rendering
echo "Installing Helm ${HELM_VERSION}..."
curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" -o helm.tar.gz
echo "${HELM_SHA256}  helm.tar.gz" | sha256sum -c -
tar -zxf helm.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm
rm -rf helm.tar.gz linux-amd64

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
