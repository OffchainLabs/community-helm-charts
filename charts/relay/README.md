# Relay

A Helm chart for Arbitrum Nitro Relays. For full details on running a feed relay, please see the official [Arbitrum Documentation](https://docs.arbitrum.io/node-running/how-tos/running-a-feed-relay).

## Quickstart

```console
helm repo add offchainlabs https://charts.arbitrum.io
```

```console
helm install <my-release> offchainlabs/relay
```

### Required Parameters
Chart defaults are for launching an Arbitrum One relay. At a minimum, you must provide a feed input url.

```console
helm install <my-release> offchainlabs/relay \
--set configmap.data.node.feed.input.url=wss://arb1.arbitrum.io/feed
``` 

### Examples

Running a relay for a network other than Arbitrum One requires setting the chain id. For instance, to run a relay for Arbitrum Sepolia.

```console
helm install <my-release> offchainlabs/relay \
--set configmap.data.chain.id=421614 \
--set configmap.data.node.feed.input.url=wss://sepolia-rollup.arbitrum.io/feed
```

## Parameters

### Relay

| Name                                              | Description                                        | Value                       |
| ------------------------------------------------- | -------------------------------------------------- | --------------------------- |
| `lifecycle`                                       | Lifecycle hooks configuration                      | `{}`                        |
| `extraEnv`                                        | Additional environment variables for the container | `{}`                        |
| `replicaCount`                                    | Number of replicas to deploy                       | `1`                         |
| `image.repository`                                | Docker image repository                            | `offchainlabs/nitro-node`   |
| `image.pullPolicy`                                | Docker image pull policy                           | `Always`                    |
| `image.tag`                                       | Docker image tag ovverrides the chart appVersion   | `""`                        |
| `imagePullSecrets`                                | Docker registry pull secret                        | `[]`                        |
| `nameOverride`                                    | String to partially override relay fullname        | `""`                        |
| `fullnameOverride`                                | String to fully override relay fullname            | `""`                        |
| `autoscaling.enabled`                             | Enable autoscaling                                 | `false`                     |
| `autoscaling.minReplicas`                         | Minimum number of replicas                         | `1`                         |
| `autoscaling.maxReplicas`                         | Maximum number of replicas                         | `6`                         |
| `autoscaling.averageCpuUtilization`               | Average CPU utilization                            | `75`                        |
| `autoscaling.averageMemoryUtilization`            | Average memory utilization                         | `75`                        |
| `autoscaling.scaleUpPercent`                      | Percent to scale up                                | `100`                       |
| `autoscaling.scaleUpPeriodSeconds`                | Period to scale up                                 | `30`                        |
| `autoscaling.scaleUpstabilizationWindowSeconds`   | Stabilization window to scale up                   | `30`                        |
| `autoscaling.scaleDownPercent`                    | Percent to scale down                              | `10`                        |
| `autoscaling.scaleDownPeriodSeconds`              | Period to scale down                               | `600`                       |
| `autoscaling.scaleDownstabilizationWindowSeconds` | Stabilization window to scale down                 | `600`                       |
| `commandOverride`                                 | Command override for the relay container           | `{}`                        |
| `livenessProbe.enabled`                           | Enable built in liveness probe                     | `true`                      |
| `livenessProbe.httpGet.path`                      | Path for liveness probe                            | `/livenessprobe`            |
| `livenessProbe.httpGet.port`                      | Port for liveness probe                            | `feed`                      |
| `livenessProbe.initialDelaySeconds`               | Initial delay for liveness probe                   | `10`                        |
| `livenessProbe.periodSeconds`                     | Period for liveness probe                          | `1`                         |
| `readinessProbe.enabled`                          | Enable built in readiness probe                    | `true`                      |
| `readinessProbe.tcpSocket.port`                   | Port for readiness probe                           | `feed`                      |
| `readinessProbe.initialDelaySeconds`              | Initial delay for readiness probe                  | `20`                        |
| `readinessProbe.periodSeconds`                    | Period for readiness probe                         | `1`                         |
| `startupProbe.enabled`                            | Enable built in startup probe                      | `false`                     |
| `serviceMonitor.enabled`                          | Enable prometheus service monitor                  | `false`                     |
| `serviceMonitor.fallbackScrapeProtocol`           | Set the fallback scrape protocol                   | `PrometheusText0.0.4`       |
| `serviceMonitor.portName`                         | Port name for prometheus service monitor           | `metrics`                   |
| `serviceMonitor.path`                             | Path for prometheus service monitor                | `/debug/metrics/prometheus` |
| `serviceMonitor.interval`                         | Interval for prometheus service monitor            | `5s`                        |
| `serviceMonitor.relabelings`                      | Add relabelings for the metrics being scraped      | `[]`                        |
| `perReplicaService.enabled`                       | Enable per replica service                         | `false`                     |
| `perReplicaService.publishNotReadyAddresses`      | Publish not ready addresses                        | `false`                     |
| `headlessService.enabled`                         | Enable headless service                            | `true`                      |
| `headlessService.publishNotReadyAddresses`        | Publish not ready addresses                        | `true`                      |
| `pdb.enabled`                                     | Enable pod disruption budget                       | `false`                     |
| `pdb.minAvailable`                                | Minimum number of available pods                   | `50%`                       |
| `pdb.maxUnavailable`                              | Maximum number of unavailable pods                 | `""`                        |
| `serviceAccount.create`                           | Create a service account                           | `true`                      |
| `serviceAccount.annotations`                      | Annotations for the service account                | `{}`                        |
| `serviceAccount.name`                             | Name of the service account                        | `""`                        |
| `podAnnotations`                                  | Annotations for the pod                            | `{}`                        |
| `podSecurityContext.fsGroup`                      | Group id for the pod                               | `1000`                      |
| `podSecurityContext.runAsGroup`                   | Group id for the user                              | `1000`                      |
| `podSecurityContext.runAsNonRoot`                 | Run as non root                                    | `true`                      |
| `podSecurityContext.runAsUser`                    | User id for the user                               | `1000`                      |
| `podSecurityContext.fsGroupChangePolicy`          | Policy for the fs group                            | `OnRootMismatch`            |
| `securityContext`                                 | Security context for the container                 | `{}`                        |
| `priorityClassName`                               | Priority class name for the pod                    | `""`                        |
| `service.type`                                    | Service type                                       | `ClusterIP`                 |
| `resources`                                       | Resources for the container                        | `{}`                        |
| `nodeSelector`                                    | Node selector for the pod                          | `{}`                        |
| `tolerations`                                     | Tolerations for the pod                            | `[]`                        |
| `topologySpreadConstraints`                       | Topology spread constraints for the pod            | `[]`                        |
| `affinity`                                        | Affinity for the pod                               | `{}`                        |

### Relay Configmap

| Name                                                       | Description                                            | Value     |
| ---------------------------------------------------------- | ------------------------------------------------------ | --------- |
| `configmap.enabled`                                        | Enable configmap                                       | `true`    |
| `configmap.data`                                           | See Configuration Options for the full list of options |           |
| `configmap.data.chain.id`                                  | Chain id                                               | `42161`   |
| `configmap.data.conf.env-prefix`                           | Environment variable prefix                            | `NITRO`   |
| `configmap.data.log-type`                                  | Log type                                               | `json`    |
| `configmap.data.metrics`                                   | Enable metrics                                         | `false`   |
| `configmap.data.metrics-server.addr`                       | Metrics server address                                 | `0.0.0.0` |
| `configmap.data.metrics-server.port`                       | Metrics server port                                    | `6070`    |
| `configmap.data.node.feed.input.url`                       | Feed input url                                         | `""`      |
| `configmap.data.node.feed.input.reconnect-initial-backoff` | Feed input reconnect initial backoff                   | `50ms`    |
| `configmap.data.node.feed.input.reconnect-maximum-backoff` | Feed input reconnect maximum backoff                   | `800ms`   |
| `configmap.data.node.feed.input.timeout`                   | Feed input timeout                                     | `10s`     |
| `configmap.data.node.feed.output.addr`                     | Feed output address                                    | `0.0.0.0` |
| `configmap.data.node.feed.output.port`                     | Feed output port                                       | `9642`    |

## Configuration Options
The following table lists the exhaustive configurable parameters that can be applied as part of the configmap (nested under `configmap.data`) or as standalone cli flags.

Option | Description | Default
--- | --- | ---

## Notes

