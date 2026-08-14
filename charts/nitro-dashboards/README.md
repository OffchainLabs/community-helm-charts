# Nitro Dashboards

Community Grafana dashboards for Arbitrum Nitro nodes, relays, sequencers, validators, and Timeboost, packaged as one ConfigMap per dashboard for automatic discovery by a Grafana dashboard sidecar (such as the one deployed by [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)).

The dashboards are rendered from [OffchainLabs/ocl-dashboards](https://github.com/OffchainLabs/ocl-dashboards) and synced into this chart automatically. The chart `appVersion` records the source commit the packaged dashboards were rendered from. If you prefer to import the raw JSON into Grafana directly, every chart release also publishes the dashboard files as a [GitHub Release](https://github.com/OffchainLabs/community-helm-charts/releases).

See [dashboards/README.md](dashboards/README.md) for the conventions the dashboards expect: datasource variables, required metric labels, component discovery queries, and the optional Kubernetes event overlays.

## Quickstart

```console
helm repo add offchainlabs https://charts.arbitrum.io
```

```console
helm install <my-release> offchainlabs/nitro-dashboards
```

Each dashboard is deployed as a ConfigMap labelled `grafana_dashboard: "1"`, which the Grafana sidecar loads automatically.

### Examples

File the dashboards into a Grafana folder and skip one of them:

```console
helm install <my-release> offchainlabs/nitro-dashboards \
--set grafanaFolder=Arbitrum \
--set excludeDashboards={timeboost-summary}
```

## Parameters

### Dashboard provisioning

| Name                 | Description                                                                                                                                     | Value               |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| `sidecar.label`      | Label key the Grafana dashboard sidecar watches for                                                                                             | `grafana_dashboard` |
| `sidecar.labelValue` | Label value the Grafana dashboard sidecar matches on                                                                                            | `1`                 |
| `grafanaFolder`      | Grafana folder to file the dashboards into. When set, it is added to every dashboard ConfigMap as the annotation configured by folderAnnotation | `""`                |
| `folderAnnotation`   | Annotation key the Grafana dashboard sidecar reads the target folder from                                                                       | `grafana_folder`    |
| `extraLabels`        | Additional labels to add to every dashboard ConfigMap                                                                                           | `{}`                |
| `extraAnnotations`   | Additional annotations to add to every dashboard ConfigMap                                                                                      | `{}`                |
| `excludeDashboards`  | List of dashboard file names to skip, with or without the .json extension (e.g. timeboost-summary)                                              | `[]`                |
| `extraObjects`       | Additional Kubernetes objects to deploy alongside the dashboards (rendered through tpl)                                                         | `[]`                |

### Testing

| Name               | Description                                                                                                      | Value |
| ------------------ | ---------------------------------------------------------------------------------------------------------------- | ----- |
| `tests.grafanaUrl` | When set, helm test verifies every packaged dashboard is loaded in the Grafana instance at this URL (used by CI) | `""`  |

### Naming

| Name               | Description                                            | Value |
| ------------------ | ------------------------------------------------------ | ----- |
| `nameOverride`     | String to partially override nitro-dashboards fullname | `""`  |
| `fullnameOverride` | String to fully override nitro-dashboards fullname     | `""`  |
