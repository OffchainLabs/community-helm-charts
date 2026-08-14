# The Offchain Labs Community Library for Kubernetes

[Kubernetes Helm Charts](https://github.com/helm/helm), provided by [Offchain Labs](https://www.offchainlabs.com/), to support deployment of Arbitrum and other Offchain Labs products on Kubernetes clusters.

Please see each chart's README for more details on specific configuration options.

## Instructions

```console
helm repo add offchainlabs https://charts.arbitrum.io
```

```console
helm install <my-release> offchainlabs/<chart>
```

## Grafana Dashboards for Nitro

Community Grafana dashboards for Nitro nodes, relays, sequencers, validators, and Timeboost are published through two channels:

* **GitHub Releases** — every `nitro-dashboards-*` release in the [Releases section](https://github.com/OffchainLabs/community-helm-charts/releases) attaches the raw dashboard JSON files (plus a tarball of all of them) for direct import into Grafana via **Dashboards → New → Import**.
* **Helm chart** — the [`nitro-dashboards`](charts/nitro-dashboards) chart deploys the same dashboards as ConfigMaps labelled for the Grafana dashboard sidecar (e.g. as deployed by kube-prometheus-stack):

```console
helm install <my-release> offchainlabs/nitro-dashboards
```

See [charts/nitro-dashboards/dashboards/README.md](charts/nitro-dashboards/dashboards/README.md) for the conventions the dashboards expect (datasources, metric labels, and discovery queries).
