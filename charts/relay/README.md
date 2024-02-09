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

Runninng a relay for a network other than Arbitrum One requires setting the chain id. For instance, to run a relay for Arbitrum Sepolia.

```console
helm install <my-release> offchainlabs/relay \
--set configmap.data.chain.id=421614 \
--set configmap.data.node.feed.input.url=wss://sepolia-rollup.arbitrum.io/feed
```

## Parameters

### Relay

| Name                                              | Description                                      | Value                       |
| ------------------------------------------------- | ------------------------------------------------ | --------------------------- |
| `replicaCount`                                    | Number of replicas to deploy                     | `1`                         |
| `image.repository`                                | Docker image repository                          | `offchainlabs/nitro-node`   |
| `image.pullPolicy`                                | Docker image pull policy                         | `Always`                    |
| `image.tag`                                       | Docker image tag ovverrides the chart appVersion | `""`                        |
| `imagePullSecrets`                                | Docker registry pull secret                      | `[]`                        |
| `nameOverride`                                    | String to partially override relay fullname      | `""`                        |
| `fullnameOverride`                                | String to fully override relay fullname          | `""`                        |
| `autoscaling.enabled`                             | Enable autoscaling                               | `false`                     |
| `autoscaling.minReplicas`                         | Minimum number of replicas                       | `1`                         |
| `autoscaling.maxReplicas`                         | Maximum number of replicas                       | `6`                         |
| `autoscaling.averageCpuUtilization`               | Average CPU utilization                          | `75`                        |
| `autoscaling.averageMemoryUtilization`            | Average memory utilization                       | `75`                        |
| `autoscaling.scaleUpPercent`                      | Percent to scale up                              | `100`                       |
| `autoscaling.scaleUpPeriodSeconds`                | Period to scale up                               | `30`                        |
| `autoscaling.scaleUpstabilizationWindowSeconds`   | Stabilization window to scale up                 | `30`                        |
| `autoscaling.scaleDownPercent`                    | Percent to scale down                            | `10`                        |
| `autoscaling.scaleDownPeriodSeconds`              | Period to scale down                             | `600`                       |
| `autoscaling.scaleDownstabilizationWindowSeconds` | Stabilization window to scale down               | `600`                       |
| `commandOverride`                                 | Command override for the relay container         | `{}`                        |
| `livenessProbe.enabled`                           | Enable built in liveness probe                   | `true`                      |
| `livenessProbe.httpGet.path`                      | Path for liveness probe                          | `/livenessprobe`            |
| `livenessProbe.httpGet.port`                      | Port for liveness probe                          | `feed`                      |
| `livenessProbe.initialDelaySeconds`               | Initial delay for liveness probe                 | `10`                        |
| `livenessProbe.periodSeconds`                     | Period for liveness probe                        | `1`                         |
| `readinessProbe.enabled`                          | Enable built in readiness probe                  | `true`                      |
| `readinessProbe.tcpSocket.port`                   | Port for readiness probe                         | `feed`                      |
| `readinessProbe.initialDelaySeconds`              | Initial delay for readiness probe                | `20`                        |
| `readinessProbe.periodSeconds`                    | Period for readiness probe                       | `1`                         |
| `startupProbe.enabled`                            | Enable built in startup probe                    | `false`                     |
| `serviceMonitor.enabled`                          | Enable prometheus service monitor                | `false`                     |
| `serviceMonitor.portName`                         | Port name for prometheus service monitor         | `metrics`                   |
| `serviceMonitor.path`                             | Path for prometheus service monitor              | `/debug/metrics/prometheus` |
| `serviceMonitor.interval`                         | Interval for prometheus service monitor          | `5s`                        |
| `serviceMonitor.relabelings`                      | Add relabelings for the metrics being scraped    | `{}`                        |
| `perReplicaService.enabled`                       | Enable per replica service                       | `false`                     |
| `pdb.enabled`                                     | Enable pod disruption budget                     | `false`                     |
| `pdb.minAvailable`                                | Minimum number of available pods                 | `75%`                       |
| `pdb.maxUnavailable`                              | Maximum number of unavailable pods               | `""`                        |
| `serviceAccount.create`                           | Create a service account                         | `true`                      |
| `serviceAccount.annotations`                      | Annotations for the service account              | `{}`                        |
| `serviceAccount.name`                             | Name of the service account                      | `""`                        |
| `podAnnotations`                                  | Annotations for the pod                          | `{}`                        |
| `podSecurityContext`                              | Security context for the pod                     | `{}`                        |
| `securityContext`                                 | Security context for the container               | `{}`                        |
| `service.type`                                    | Service type                                     | `ClusterIP`                 |
| `resources`                                       | Resources for the container                      | `{}`                        |
| `nodeSelector`                                    | Node selector for the pod                        | `{}`                        |
| `tolerations`                                     | Tolerations for the pod                          | `[]`                        |
| `topologySpreadConstraints`                       | Topology spread constraints for the pod          | `[]`                        |
| `affinity`                                        | Affinity for the pod                             | `{}`                        |

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
`chain.id` | uint                                                           L2 chain ID | None
`conf.dump` | print out currently active configuration file | None
`conf.env-prefix` | string                                                  environment variables with given prefix will be loaded as configuration values | None
`conf.file` | strings                                                       name of configuration file | None
`conf.reload-interval` | duration                                           how often to reload configuration (0=disable periodic reloading) | None
`conf.s3.access-key` | string                                               S3 access key | None
`conf.s3.bucket` | string                                                   S3 bucket | None
`conf.s3.object-key` | string                                               S3 object key | None
`conf.s3.region` | string                                                   S3 region | None
`conf.s3.secret-key` | string                                               S3 secret key | None
`conf.string` | string                                                      configuration as JSON string | None
`log-level` | int                                                           log level | `3`
`log-type` | string                                                         log type | `plaintext`
`metrics` | enable metrics | None
`metrics-server.addr` | string                                              metrics server address | `127.0.0.1`
`metrics-server.port` | int                                                 metrics server port | `6070`
`metrics-server.update-interval` | duration                                 metrics server update interval | `3s`
`node.feed.input.enable-compression` | enable per message deflate compression support | `true`
`node.feed.input.reconnect-initial-backoff` | duration                      initial duration to wait before reconnect | `1s`
`node.feed.input.reconnect-maximum-backoff` | duration                      maximum duration to wait before reconnect | `1m4s`
`node.feed.input.require-chain-id` | require chain id to be present on connect | None
`node.feed.input.require-feed-version` | require feed version to be present on connect | None
`node.feed.input.secondary-url` | strings                                   list of secondary URLs of sequencer feed source. Would be started in the order they appear in the list when primary feeds fails | None
`node.feed.input.timeout` | duration                                        duration to wait before timing out connection to sequencer feed | `20s`
`node.feed.input.url` | strings                                             list of primary URLs of sequencer feed source | None
`node.feed.input.verify.accept-sequencer` | accept verified message from sequencer | `true`
`node.feed.input.verify.allowed-addresses` | strings                        a list of allowed addresses | None
`node.feed.input.verify.dangerous.accept-missing` | accept empty as valid signature | `true`
`node.feed.output.addr` | string                                            address to bind the relay feed output to | None
`node.feed.output.backlog.segment-limit` | int                              the maximum number of messages each segment within the backlog can contain | `240`
`node.feed.output.client-delay` | duration                                  delay the first messages sent to each client by this amount | None
`node.feed.output.client-timeout` | duration                                duration to wait before timing out connections to client | `15s`
`node.feed.output.connection-limits.enable` | enable broadcaster per-client connection limiting | None
`node.feed.output.connection-limits.per-ip-limit` | int                     limit clients, as identified by IPv4/v6 address, to this many connections to this relay | `5`
`node.feed.output.connection-limits.per-ipv6-cidr-48-limit` | int           limit ipv6 clients, as identified by IPv6 address masked with /48, to this many connections to this relay | `20`
`node.feed.output.connection-limits.per-ipv6-cidr-64-limit` | int           limit ipv6 clients, as identified by IPv6 address masked with /64, to this many connections to this relay | `10`
`node.feed.output.connection-limits.reconnect-cooldown-period` | duration   time to wait after a relay client disconnects before the disconnect is registered with respect to the limit for this client | None
`node.feed.output.disable-signing` | don't sign feed messages | `true`
`node.feed.output.enable` | enable broadcaster | None
`node.feed.output.enable-compression` | enable per message deflate compression support | None
`node.feed.output.handshake-timeout` | duration                             duration to wait before timing out HTTP to WS upgrade | `1s`
`node.feed.output.limit-catchup` | only supply catchup buffer if requested sequence number is reasonable | None
`node.feed.output.log-connect` | log every client connect | None
`node.feed.output.log-disconnect` | log every client disconnect | None
`node.feed.output.max-catchup` | int                                        the maximum size of the catchup buffer (-1 means unlimited) | `-1`
`node.feed.output.max-send-queue` | int                                     maximum number of messages allowed to accumulate before client is disconnected | `4096`
`node.feed.output.ping` | duration                                          duration for ping interval | `5s`
`node.feed.output.port` | string                                            port to bind the relay feed output to | `9642`
`node.feed.output.queue` | int                                              queue size for HTTP to WS upgrade | `100`
`node.feed.output.read-timeout` | duration                                  duration to wait before timing out reading data (i.e. pings) from clients | `1s`
`node.feed.output.require-compression` | require clients to use compression | None
`node.feed.output.require-version` | don't connect if client version not present | None
`node.feed.output.signed` | sign broadcast messages | None
`node.feed.output.workers` | int                                            number of threads to reserve for HTTP to WS upgrade | `100`
`node.feed.output.write-timeout` | duration                                 duration to wait before timing out writing data to clients | `2s`
`pprof` | enable pprof | None
`pprof-cfg.addr` | string                                                   pprof server address | `127.0.0.1`
`pprof-cfg.port` | int                                                      pprof server port | `6071`
`queue` | int                                                               queue for incoming messages from sequencer | `1024`

## Notes
