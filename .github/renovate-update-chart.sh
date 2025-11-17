#!/bin/bash

# Script to update Chart.yaml appVersion and bump chart version
# when a new nitro-node Docker image is available (excluding RC versions)
# Usage: ./renovate-update-chart.sh <Chart.yaml file path> <new image version>

set -e

if [ $# -ne 2 ]; then
    echo "Error: Invalid number of arguments"
    echo "Usage: $0 <Chart.yaml file path> <new image version>"
    exit 1
fi

CHART_FILE="$1"
NEW_IMAGE_VERSION="$2"

if [ ! -f "$CHART_FILE" ]; then
    echo "Error: File '$CHART_FILE' does not exist"
    exit 1
fi

# Verify this is a Chart.yaml file
if [[ ! "$CHART_FILE" =~ Chart\.yaml$ ]]; then
    echo "Error: File '$CHART_FILE' is not a Chart.yaml file"
    exit 1
fi

# Check if yq is available
if ! command -v yq >/dev/null 2>&1; then
    echo "Error: yq is not installed. Please install yq first."
    exit 1
fi

echo "Updating Chart.yaml: $CHART_FILE"
echo "New image version: $NEW_IMAGE_VERSION"

# Extract current versions
CURRENT_APP_VERSION=$(yq -r '.appVersion' "$CHART_FILE")
CURRENT_CHART_VERSION=$(yq -r '.version' "$CHART_FILE")

echo "Current appVersion: $CURRENT_APP_VERSION"
echo "Current chart version: $CURRENT_CHART_VERSION"

# Update appVersion to the new Docker image version
yq -i ".appVersion = \"$NEW_IMAGE_VERSION\"" "$CHART_FILE"
echo "✓ Updated appVersion to $NEW_IMAGE_VERSION"

# Bump chart version (patch number)
yq -i '.version |= (split(".") | .[0:2] + [((.[2] | tonumber) + 1 | tostring)] | join("."))' "$CHART_FILE"

NEW_CHART_VERSION=$(yq -r '.version' "$CHART_FILE")
echo "✓ Bumped chart version from $CURRENT_CHART_VERSION to $NEW_CHART_VERSION"

echo "Successfully updated $CHART_FILE"
