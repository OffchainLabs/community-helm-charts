# Arbitrum Timeboost

A Helm chart for [Timeboost](https://forum.arbitrum.foundation/t/constitutional-aip-proposal-to-adopt-timeboost-a-new-transaction-ordering-policy/25167).

## Parameters

### Global Image Configuration

| Name               | Description                                               | Value                     |
| ------------------ | --------------------------------------------------------- | ------------------------- |
| `image.repository` | Docker image repository                                   | `offchainlabs/nitro-node` |
| `image.pullPolicy` | Docker image pull policy                                  | `Always`                  |
| `image.tag`        | Docker image tag. Defaults to Chart appVersion if not set | `""`                      |

### Auctioneer Deployment Options

| Name                                                                   | Description                                                                     | Value                       |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------------------- | --------------------------- |
| `auctioneer.replicaCount`                                              | Number of replicas to deploy                                                    | `1`                         |
| `auctioneer.image.repository`                                          | Docker image repository override                                                | `""`                        |
| `auctioneer.image.pullPolicy`                                          | Docker image pull policy override                                               | `""`                        |
| `auctioneer.image.tag`                                                 | Docker image tag. Overrides the chart appVersion.                               | `""`                        |
| `auctioneer.imagePullSecrets`                                          | Docker registry pull secret names as an array                                   | `[]`                        |
| `auctioneer.nameOverride`                                              | String to partially override timeboost.fullname                                 | `""`                        |
| `auctioneer.fullnameOverride`                                          | String to fully override timeboost.fullname                                     | `""`                        |
| `auctioneer.commandOverride`                                           | Command override for the nitro container                                        | `{}`                        |
| `auctioneer.livenessProbe`                                             | Liveness probe configuration                                                    | `{}`                        |
| `auctioneer.readinessProbe`                                            | Readiness probe configuration                                                   | `{}`                        |
| `auctioneer.startupProbe.enabled`                                      | Enable built in startup probe                                                   | `false`                     |
| `auctioneer.startupProbe.failureThreshold`                             | Number of failures before pod is considered unhealthy                           | `2419200`                   |
| `auctioneer.startupProbe.periodSeconds`                                | Number of seconds between startup probes                                        | `1`                         |
| `auctioneer.startupProbe.command`                                      | Command to run for the startup probe. If empty, the built in probe will be used | `""`                        |
| `auctioneer.updateStrategy.type`                                       | Update strategy type                                                            | `RollingUpdate`             |
| `auctioneer.persistence.enabled`                                       | Enable persistence                                                              | `true`                      |
| `auctioneer.persistence.size`                                          | Size of the persistent volume claim                                             | `1Gi`                       |
| `auctioneer.persistence.storageClassName`                              | Storage class of the persistent volume claim                                    | `nil`                       |
| `auctioneer.persistence.accessModes`                                   | Access modes of the persistent volume claim                                     | `["ReadWriteOnce"]`         |
| `auctioneer.serviceMonitor.enabled`                                    | Enable service monitor CRD for prometheus operator                              | `false`                     |
| `auctioneer.serviceMonitor.portName`                                   | Name of the port to monitor                                                     | `metrics`                   |
| `auctioneer.serviceMonitor.path`                                       | Path to monitor                                                                 | `/debug/metrics/prometheus` |
| `auctioneer.serviceMonitor.interval`                                   | Interval to monitor                                                             | `5s`                        |
| `auctioneer.serviceMonitor.additionalLabels`                           | Additional labels for the service monitor                                       | `{}`                        |
| `auctioneer.serviceMonitor.relabelings`                                | Add relabelings for the metrics being scraped                                   | `[]`                        |
| `auctioneer.serviceAccount.create`                                     | Create a service account                                                        | `true`                      |
| `auctioneer.serviceAccount.annotations`                                | Annotations for the service account                                             | `{}`                        |
| `auctioneer.serviceAccount.name`                                       | Name of the service account                                                     | `""`                        |
| `auctioneer.jwtSecret.enabled`                                         | Enable a jwt secret                                                             | `false`                     |
| `auctioneer.jwtSecret.value`                                           | Value of the jwt secret                                                         | `""`                        |
| `auctioneer.podAnnotations`                                            | Annotations for the pod                                                         | `{}`                        |
| `auctioneer.podLabels`                                                 | Labels for the pod                                                              | `{}`                        |
| `auctioneer.podSecurityContext.fsGroup`                                | Group id for the pod                                                            | `1000`                      |
| `auctioneer.podSecurityContext.runAsGroup`                             | Group id for the user                                                           | `1000`                      |
| `auctioneer.podSecurityContext.runAsNonRoot`                           | Run as non root                                                                 | `true`                      |
| `auctioneer.podSecurityContext.runAsUser`                              | User id for the user                                                            | `1000`                      |
| `auctioneer.podSecurityContext.fsGroupChangePolicy`                    | Policy for the fs group                                                         | `OnRootMismatch`            |
| `auctioneer.securityContext`                                           | Security context for the container                                              | `{}`                        |
| `auctioneer.priorityClassName`                                         | Priority class name                                                             | `""`                        |
| `auctioneer.service.type`                                              | Service type                                                                    | `ClusterIP`                 |
| `auctioneer.service.publishNotReadyAddresses`                          | Publish not ready addresses                                                     | `false`                     |
| `auctioneer.resources`                                                 | Resources for the container                                                     | `{}`                        |
| `auctioneer.nodeSelector`                                              | Node selector for the pod                                                       | `{}`                        |
| `auctioneer.tolerations`                                               | Tolerations for the pod                                                         | `[]`                        |
| `auctioneer.affinity`                                                  | Affinity for the pod                                                            | `{}`                        |
| `auctioneer.additionalVolumeClaims`                                    | Additional volume claims for the pod                                            | `[]`                        |
| `auctioneer.extraVolumes`                                              | Additional volumes for the pod                                                  | `[]`                        |
| `auctioneer.extraVolumeMounts`                                         | Additional volume mounts for the pod                                            | `[]`                        |
| `auctioneer.extraPorts`                                                | Additional ports for the pod                                                    | `[]`                        |
| `auctioneer.wallet.mountPath`                                          | Path to mount the wallets                                                       | `/wallet/`                  |
| `auctioneer.wallet.files`                                              | Key value pair of wallet name and contents (ethers json format)                 | `{}`                        |
| `auctioneer.configmap.enabled`                                         | Enable a configmap for the nitro container                                      | `true`                      |
| `configmap.data`                                                       | See Configuration Options for the full list of options                          |                             |
| `auctioneer.configmap.data.auctioneer-server.auction-contract-address` | Auction contract address                                                        | `""`                        |
| `auctioneer.configmap.data.auctioneer-server.db-directory`             | Database storage directory                                                      | `/data`                     |
| `auctioneer.configmap.data.auctioneer-server.redis-url`                | Redis URL                                                                       | `redis://redis:6379`        |
| `auctioneer.configmap.data.auctioneer-server.sequencer-endpoint`       | Sequencer endpoint                                                              | `ws://sequencer:8549`       |
| `auctioneer.configmap.data.auctioneer-server.sequencer-jwt-path`       | Path to seqeuncer JWT                                                           | `/config/jwt.hex`           |
| `auctioneer.configmap.data.auctioneer-server.wallet.account`           | Wallet account                                                                  | `""`                        |
| `auctioneer.configmap.data.auctioneer-server.wallet.password`          | Wallet password                                                                 | `""`                        |
| `auctioneer.configmap.data.auctioneer-server.wallet.pathname`          | Path to wallet                                                                  | `""`                        |
| `auctioneer.configmap.data.bid-validator.enable`                       | Enable bid validator                                                            | `false`                     |
| `auctioneer.configmap.data.log-type`                                   | Type of log                                                                     | `json`                      |
| `auctioneer.configmap.data.metrics`                                    | Enable metrics                                                                  | `false`                     |
| `auctioneer.configmap.data.metrics-server.addr`                        | Address to bind metrics server to                                               | `0.0.0.0`                   |
| `auctioneer.configmap.data.metrics-server.port`                        | Port to bind metrics server to                                                  | `6070`                      |
| `auctioneer.configmap.data.persistent.auctioneer`                      | Path to persistent auction data                                                 | `/home/user/data/`          |

### Bid Validator Deployment Options

| Name                                                                 | Description                                                                     | Value                       |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------- | --------------------------- |
| `bidValidator.replicaCount`                                          | Number of replicas to deploy                                                    | `1`                         |
| `bidValidator.image.repository`                                      | Docker image repository override                                                | `""`                        |
| `bidValidator.image.pullPolicy`                                      | Docker image pull policy override                                               | `""`                        |
| `bidValidator.image.tag`                                             | Docker image tag. Overrides the chart appVersion.                               | `""`                        |
| `bidValidator.imagePullSecrets`                                      | Docker registry pull secret names as an array                                   | `[]`                        |
| `bidValidator.nameOverride`                                          | String to partially override timeboost.fullname                                 | `""`                        |
| `bidValidator.fullnameOverride`                                      | String to fully override timeboost.fullname                                     | `""`                        |
| `bidValidator.commandOverride`                                       | Command override for the nitro container                                        | `{}`                        |
| `bidValidator.livenessProbe`                                         | Liveness probe configuration                                                    | `{}`                        |
| `bidValidator.readinessProbe`                                        | Readiness probe configuration                                                   | `{}`                        |
| `bidValidator.startupProbe.enabled`                                  | Enable built in startup probe                                                   | `false`                     |
| `bidValidator.startupProbe.failureThreshold`                         | Number of failures before pod is considered unhealthy                           | `2419200`                   |
| `bidValidator.startupProbe.periodSeconds`                            | Number of seconds between startup probes                                        | `1`                         |
| `bidValidator.startupProbe.command`                                  | Command to run for the startup probe. If empty, the built in probe will be used | `""`                        |
| `bidValidator.serviceMonitor.enabled`                                | Enable service monitor CRD for prometheus operator                              | `false`                     |
| `bidValidator.serviceMonitor.portName`                               | Name of the port to monitor                                                     | `metrics`                   |
| `bidValidator.serviceMonitor.path`                                   | Path to monitor                                                                 | `/debug/metrics/prometheus` |
| `bidValidator.serviceMonitor.interval`                               | Interval to monitor                                                             | `5s`                        |
| `bidValidator.serviceMonitor.additionalLabels`                       | Additional labels for the service monitor                                       | `{}`                        |
| `bidValidator.serviceMonitor.relabelings`                            | Add relabelings for the metrics being scraped                                   | `[]`                        |
| `bidValidator.serviceAccount.create`                                 | Create a service account                                                        | `true`                      |
| `bidValidator.serviceAccount.annotations`                            | Annotations for the service account                                             | `{}`                        |
| `bidValidator.serviceAccount.name`                                   | Name of the service account                                                     | `""`                        |
| `bidValidator.podAnnotations`                                        | Annotations for the pod                                                         | `{}`                        |
| `bidValidator.podLabels`                                             | Labels for the pod                                                              | `{}`                        |
| `bidValidator.podSecurityContext.fsGroup`                            | Group id for the pod                                                            | `1000`                      |
| `bidValidator.podSecurityContext.runAsGroup`                         | Group id for the user                                                           | `1000`                      |
| `bidValidator.podSecurityContext.runAsNonRoot`                       | Run as non root                                                                 | `true`                      |
| `bidValidator.podSecurityContext.runAsUser`                          | User id for the user                                                            | `1000`                      |
| `bidValidator.podSecurityContext.fsGroupChangePolicy`                | Policy for the fs group                                                         | `OnRootMismatch`            |
| `bidValidator.securityContext`                                       | Security context for the container                                              | `{}`                        |
| `bidValidator.priorityClassName`                                     | Priority class name                                                             | `""`                        |
| `bidValidator.service.type`                                          | Service type                                                                    | `ClusterIP`                 |
| `bidValidator.service.publishNotReadyAddresses`                      | Publish not ready addresses                                                     | `false`                     |
| `bidValidator.resources`                                             | Resources for the container                                                     | `{}`                        |
| `bidValidator.nodeSelector`                                          | Node selector for the pod                                                       | `{}`                        |
| `bidValidator.tolerations`                                           | Tolerations for the pod                                                         | `[]`                        |
| `bidValidator.affinity`                                              | Affinity for the pod                                                            | `{}`                        |
| `bidValidator.additionalVolumeClaims`                                | Additional volume claims for the pod                                            | `[]`                        |
| `bidValidator.extraVolumes`                                          | Additional volumes for the pod                                                  | `[]`                        |
| `bidValidator.extraVolumeMounts`                                     | Additional volume mounts for the pod                                            | `[]`                        |
| `bidValidator.extraPorts`                                            | Additional ports for the pod                                                    | `[]`                        |
| `bidValidator.configmap.enabled`                                     | Enable a configmap for the nitro container                                      | `true`                      |
| `configmap.data`                                                     | See Configuration Options for the full list of options                          |                             |
| `bidValidator.configmap.data.http.addr`                              | Address to bind http service to                                                 | `0.0.0.0`                   |
| `bidValidator.configmap.data.http.api`                               | List of apis to enable                                                          | `["auctioneer"]`            |
| `bidValidator.configmap.data.http.corsdomain`                        | CORS domain                                                                     | `*`                         |
| `bidValidator.configmap.data.http.port`                              | Port to bind http service to                                                    | `8547`                      |
| `bidValidator.configmap.data.http.rpcprefix`                         | Prefix for rpc calls                                                            | `/rpc`                      |
| `bidValidator.configmap.data.http.vhosts`                            | Vhosts to allow                                                                 | `*`                         |
| `bidValidator.configmap.data.auctioneer-server.enable`               | Enable Auctioneer Server                                                        | `false`                     |
| `bidValidator.configmap.data.bid-validator.auction-contract-address` | Auction contract address                                                        | `""`                        |
| `bidValidator.configmap.data.bid-validator.redis-url`                | Redis URL                                                                       | `redis://redis:6379`        |
| `bidValidator.configmap.data.bid-validator.sequencer-endpoint`       | Sequencer endpoint                                                              | `http://sequencer:8547`     |
| `bidValidator.configmap.data.log-type`                               | Type of log                                                                     | `json`                      |
| `bidValidator.configmap.data.metrics`                                | Enable metrics                                                                  | `false`                     |
| `bidValidator.configmap.data.metrics-server.addr`                    | Address to bind metrics server to                                               | `0.0.0.0`                   |
| `bidValidator.configmap.data.metrics-server.port`                    | Port to bind metrics server to                                                  | `6070`                      |

