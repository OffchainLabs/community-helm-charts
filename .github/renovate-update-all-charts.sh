#!/bin/bash

# Script to update all Chart.yaml files that use nitro-node image
# Bumps chart version for all charts when nitro-node image is updated
# Usage: ./renovate-update-all-charts.sh <new image version>

set -e

if [ $# -ne 1 ]; then
    echo "Error: Invalid number of arguments"
    echo "Usage: $0 <new image version>"
    exit 1
fi

NEW_IMAGE_VERSION="$1"

# Check if yq is available
if ! command -v yq >/dev/null 2>&1; then
    echo "Error: yq is not installed. Please install yq first."
    exit 1
fi

echo "Updating all charts to nitro-node version: $NEW_IMAGE_VERSION"
echo ""

# Find all Chart.yaml files in charts directory
CHART_FILES=$(find charts -name "Chart.yaml" -type f)

if [ -z "$CHART_FILES" ]; then
    echo "No Chart.yaml files found in charts directory"
    exit 1
fi

# Update each chart
for CHART_FILE in $CHART_FILES; do
    # Extract current versions
    CURRENT_APP_VERSION=$(yq -r '.appVersion' "$CHART_FILE")
    CURRENT_CHART_VERSION=$(yq -r '.version' "$CHART_FILE")
    CHART_NAME=$(yq -r '.name' "$CHART_FILE")

    echo "Processing: $CHART_NAME ($CHART_FILE)"
    echo "  Current appVersion: $CURRENT_APP_VERSION"
    echo "  Current chart version: $CURRENT_CHART_VERSION"

    # Check if this chart uses nitro-node (by checking if appVersion matches the pattern)
    if [[ "$CURRENT_APP_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+-[0-9a-fA-F]{7}$ ]]; then
        # Bump chart version (patch number)
        yq -i '.version |= (split(".") | .[0:2] + [((.[2] | tonumber) + 1 | tostring)] | join("."))' "$CHART_FILE"

        NEW_CHART_VERSION=$(yq -r '.version' "$CHART_FILE")
        echo "  ✓ Bumped chart version: $CURRENT_CHART_VERSION → $NEW_CHART_VERSION"
    else
        echo "  ⊘ Skipped (appVersion doesn't match nitro-node pattern)"
    fi

    echo ""
done

echo "Successfully updated all nitro-node charts"
echo ""

# Update README with new configuration options (if script exists)
if [ -f "scripts/readmecli.py" ]; then
    echo "Updating README files with configuration options..."
    cd scripts
    if python3 readmecli.py 2>&1; then
        echo "✓ README update complete"
    else
        echo "⚠ Warning: README update failed with exit code $?, continuing anyway"
    fi
    cd ..
else
    echo "⚠ Info: scripts/readmecli.py not found, skipping README update"
fi
