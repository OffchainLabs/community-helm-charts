#!/bin/bash
# This script acts as a wrapper for the helm command to substitute --reuse-values with --reset-then-reuse-values.

# Get the directory of the original helm binary
helm_dir=$(dirname "$(which helm)")

# Call the original helm binary with modified arguments
exec "$helm_dir/helm" "${@//--reuse-values/--reset-then-reuse-values}"
