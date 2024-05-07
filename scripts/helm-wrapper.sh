#!/bin/bash
# This script is used as a stub for helm to substitute --reset-then-reuse-values
# for instances of --reuse-values until https://github.com/helm/chart-testing/pull/531
# or a similar PR is merged and released

# Get the directory of the original helm binary
helm_dir=$(dirname "$(which helm)")

# Call the original helm binary with modified arguments
exec "$helm_dir/helm" "${@//--reuse-values/--reset-then-reuse-values}"
