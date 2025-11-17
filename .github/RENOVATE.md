# Renovate Configuration

This repository uses [Renovate](https://docs.renovatebot.com/) to automatically monitor and update the `offchainlabs/nitro-node` Docker image in the Nitro Helm chart.

## Overview

Renovate is configured to:
- Watch for new versions of the `offchainlabs/nitro-node` Docker image
- **Exclude RC (Release Candidate) versions** - only stable releases are considered
- Automatically create PRs when a new stable version is available
- Update both the `appVersion` and `version` in `Chart.yaml`

## How It Works

### 1. Image Monitoring
Renovate scans the `charts/nitro/values.yaml` file for Docker image references. When a new version of `offchainlabs/nitro-node` is published to Docker Hub:

- **Stable versions** (e.g., `v3.8.0`, `v3.9.0`) → Renovate creates a PR
- **RC versions** (e.g., `v3.8.0-rc.1`, `v3.8.0-rc.7-ef47e28`) → Skipped (filtered by `allowedVersions: "!/rc\\./"`)

### 2. Automatic Updates
When a new stable version is detected, Renovate automatically:

1. Updates the image tag in `charts/nitro/values.yaml` (if explicitly set)
2. Runs `.github/renovate-update-chart.sh` which:
   - Updates `appVersion` in `charts/nitro/Chart.yaml` to the new image version
   - Increments the chart `version` (patch number)
3. Creates a PR with all changes

### 3. PR Creation
PRs are created with:
- **Title**: `chore(nitro): update nitro-node to <version>`
- **Labels**: `dependencies`, `docker`, `renovate`, `nitro`
- **Commits**: Follow semantic commit conventions

## Configuration Files

### `.github/renovate-config.json`
Main Renovate configuration that defines:
- Which files to monitor (`charts/*/values.yaml`)
- Package rules for `offchainlabs/nitro-node`
- Version filtering (excluding RC versions)
- Post-upgrade tasks to run

### `.github/renovate-update-chart.sh`
Bash script that:
- Updates `appVersion` in Chart.yaml to match the new Docker image version
- Bumps the chart `version` (patch number)
- Requires `yq` to be installed (handled by the entrypoint script)

### `.github/renovate-entrypoint.sh`
Setup script that runs before Renovate:
- Installs `yq` for YAML processing
- Configures environment variables
- Validates required settings

### `.github/workflows/renovate.yaml`
GitHub Actions workflow that:
- Runs Renovate on a schedule (every 6 hours)
- Can be manually triggered via workflow dispatch
- Supports both GitHub App and PAT authentication

## Running Renovate

### Automatic Runs
Renovate runs automatically every 6 hours via GitHub Actions.

### Manual Runs
You can trigger Renovate manually:

1. Go to **Actions** → **Renovate** workflow
2. Click **Run workflow**
3. Optionally customize:
   - Repository to run on
   - Log level (debug, info, warn, error)

### Local Testing
To test the update script locally:

```bash
# Example: simulate updating to v3.9.0
.github/renovate-update-chart.sh charts/nitro/Chart.yaml v3.9.0
```

## Authentication

The workflow supports two authentication methods:

### Option 1: GitHub App (Recommended)
Set these repository secrets:
- `RENOVATE_APP_ID`: Your GitHub App ID
- `RENOVATE_APP_PRIVATE_KEY`: Your GitHub App private key

### Option 2: Personal Access Token
Set this repository secret:
- `RENOVATE_TOKEN`: GitHub PAT with `repo` scope

If neither is set, it falls back to `GITHUB_TOKEN` (limited permissions).

## Monitoring

### Dependency Dashboard
When enabled, Renovate creates a "Dependency Dashboard" issue that shows:
- Pending updates
- Update status
- Any errors or warnings

### PR Limits
To avoid overwhelming the repository:
- Maximum 5 PRs concurrently
- Maximum 2 PRs per hour

## Troubleshooting

### Renovate not detecting new versions
1. Check the [nitro-node Docker Hub page](https://hub.docker.com/r/offchainlabs/nitro-node/tags) for new versions
2. Verify the version doesn't contain `rc.` (which would exclude it)
3. Review Renovate logs in the GitHub Actions run

### Update script failures
1. Ensure `yq` is installed (should be handled by entrypoint)
2. Check Chart.yaml format is valid YAML
3. Review script execution logs in the PR

### PR not created
1. Check if a PR already exists for this update
2. Verify GitHub token has sufficient permissions
3. Check Renovate logs for errors

## Multiple Charts

This repository contains three Helm charts that all use the `offchainlabs/nitro-node` image:
- **nitro**: Main Nitro node chart
- **das**: Data Availability Server chart
- **relay**: Relay node chart

When a new stable version is released, Renovate will create **a single PR** that updates all three charts together, ensuring consistency across all deployments.

## Example PR

When `offchainlabs/nitro-node:v3.9.0` is released, Renovate will create a PR with changes like:

```yaml
# charts/nitro/Chart.yaml
- version: 0.8.0
- appVersion: "v3.8.0-rc.7-ef47e28"
+ version: 0.8.1
+ appVersion: "v3.9.0"

# charts/das/Chart.yaml
- version: 0.7.0
- appVersion: "v3.8.0-rc.7-ef47e28"
+ version: 0.7.1
+ appVersion: "v3.9.0"

# charts/relay/Chart.yaml
- version: 0.7.0
- appVersion: "v3.8.0-rc.7-ef47e28"
+ version: 0.7.1
+ appVersion: "v3.9.0"
```

```yaml
# charts/*/values.yaml (if tag is explicitly set)
image:
  repository: offchainlabs/nitro-node
- tag: "v3.8.0-rc.7-ef47e28"
+ tag: "v3.9.0"
```

## Additional Resources

- [Renovate Documentation](https://docs.renovatebot.com/)
- [Helm Values Manager](https://docs.renovatebot.com/modules/manager/helm-values/)
- [Package Rules](https://docs.renovatebot.com/configuration-options/#packagerules)
