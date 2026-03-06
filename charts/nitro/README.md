# Arbitrum Nitro

A Helm chart for Arbitrum Nitro. For full details on running a node, please see the official [Arbitrum Documentation](https://docs.arbitrum.io/run-arbitrum-node/run-full-node).

## Quickstart

```console
helm repo add offchainlabs https://charts.arbitrum.io
```

```console
helm install <my-release> offchainlabs/nitro
```

### Required Parameters
Chart defaults are for launching an arbitrum one node. At a minimum you must provide a parent chain url, consensus client api url, and an init method(downloading from snapshot is in the example).

```console
helm install <my-release> offchainlabs/nitro \
--set configmap.data.parent-chain.connection.url=<ETH_RPC_URL> \
--set configmap.data.parent-chain.blob-client.beacon-url=<CONSENSUS_API_URL> \
--set configmap.data.init.url=https://snapshot.arbitrum.foundation/arb1/nitro-genesis.tar
```
Remove init.url after the snapshot has downloaded and the node has launched. The above snapshot will sync from nitro's gensis block. There are other snapshot options on the [Arbitrum Snapshot Page](https://snapshot.arbitrum.io/) that may be more suitable for your use case. The snapshots and chain state can be quite large, so it is recommended to review the storage defaults and adjust as needed. Particular attention should be paid to the `persistence`, `configmap.data.persistent.chain`, and `init.download-path` parameters.

### Examples

Launching a node on another network requires additional configuration. See the [Nitro Deployment Options](#nitro-deployment-options) and [Configuration Options](#configuration-options) sections for more details. Here are two examples of networks and the additional configuration they require.

#### Arbitrum Sepolia
```console
helm install <my-release> offchainlabs/nitro \
--set configmap.data.parent-chain.id=11155111 \
--set configmap.data.parent-chain.connection.url=<SEPOLIA_RPC_URL> \
--set configmap.data.parent-chain.blob-client.beacon-url=<CONSENSUS_API_URL> \
--set configmap.data.chain.id=421614
```
There are snapshots available to speed up the sync process for Arbitrum Sepolia. See the [Arbitrum Snapshot Page](https://snapshot.arbitrum.io/) for more details.
    
#### Xai

```yaml
configmap:
  data:
    parent-chain:
      id: 42161
      connection:
        url: <ARBITRUM_ONE_RPC_URL>
    chain:
      id: 660279
      name: Xai
      info-json: '[{"chain-id":660279,"parent-chain-id":42161,"parent-chain-is-arbitrum":true,"chain-name":"Xai","chain-config":{"homesteadBlock":0,"daoForkBlock":null,"daoForkSupport":true,"eip150Block":0,"eip150Hash":"0x0000000000000000000000000000000000000000000000000000000000000000","eip155Block":0,"eip158Block":0,"byzantiumBlock":0,"constantinopleBlock":0,"petersburgBlock":0,"istanbulBlock":0,"muirGlacierBlock":0,"berlinBlock":0,"londonBlock":0,"clique":{"period":0,"epoch":0},"arbitrum":{"EnableArbOS":true,"AllowDebugPrecompiles":false,"DataAvailabilityCommittee":true,"InitialArbOSVersion":11,"GenesisBlockNum":0,"MaxCodeSize":40960,"MaxInitCodeSize":81920,"InitialChainOwner":"0xc7185e37A4aB4Af0E77bC08249CD2590AE3E1b51"},"chainId":660279},"rollup":{"bridge":"0x7dd8A76bdAeBE3BBBaCD7Aa87f1D4FDa1E60f94f","inbox":"0xaE21fDA3de92dE2FDAF606233b2863782Ba046F9","sequencer-inbox":"0x995a9d3ca121D48d21087eDE20bc8acb2398c8B1","rollup":"0xC47DacFbAa80Bd9D8112F4e8069482c2A3221336","validator-utils":"0x6c21303F5986180B1394d2C89f3e883890E2867b","validator-wallet-creator":"0x2b0E04Dc90e3fA58165CB41E2834B44A56E766aF","deployed-at":166757506}}]'
    execution:
      forwarding-target: https://xai-chain.net/rpc
    node:
      data-availability:
        enable: true
        sequencer-inbox-address: 0x995a9d3ca121D48d21087eDE20bc8acb2398c8B1
        parent-chain-node-url: <ARBITRUM_ONE_RPC_URL>
        rest-aggregator:
          enable: true
          online-url-list: https://xai-chain.net/das-servers
      feed:
        input:
          url: wss://xai-chain.net/feed
```

```console
helm install xai offchainlabs/nitro -f values.yaml
```

## Parameters

### Nitro Deployment Options

| Name                                                       | Description                                                                               | Value                                                               |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| `lifecycle`                                                | Lifecycle hooks configuration                                                             | `{}`                                                                |
| `extraEnv`                                                 | Additional environment variables for the container                                        | `{}`                                                                |
| `replicaCount`                                             | Number of replicas to deploy                                                              | `1`                                                                 |
| `image.repository`                                         | Docker image repository                                                                   | `offchainlabs/nitro-node`                                           |
| `image.pullPolicy`                                         | Docker image pull policy                                                                  | `Always`                                                            |
| `image.tag`                                                | Docker image tag. Overrides the chart appVersion.                                         | `""`                                                                |
| `imagePullSecrets`                                         | Docker registry pull secret names as an array                                             | `[]`                                                                |
| `nameOverride`                                             | String to partially override nitro.fullname                                               | `""`                                                                |
| `fullnameOverride`                                         | String to fully override nitro.fullname                                                   | `""`                                                                |
| `commandOverride`                                          | Command override for the nitro container                                                  | `{}`                                                                |
| `livenessProbe`                                            | Liveness probe configuration                                                              | `{}`                                                                |
| `readinessProbe`                                           | Readiness probe configuration                                                             | `{}`                                                                |
| `startupProbe.enabled`                                     | Enable built in startup probe                                                             | `true`                                                              |
| `startupProbe.failureThreshold`                            | Number of failures before pod is considered unhealthy                                     | `2419200`                                                           |
| `startupProbe.periodSeconds`                               | Number of seconds between startup probes                                                  | `1`                                                                 |
| `startupProbe.command`                                     | Command to run for the startup probe. If empty, the built in probe will be used           | `""`                                                                |
| `updateStrategy.type`                                      | Update strategy type                                                                      | `RollingUpdate`                                                     |
| `env.splitvalidator.goMemLimit.enabled`                    | Enable setting the garbage cleanup limit in Go for the split validator                    | `true`                                                              |
| `env.splitvalidator.goMemLimit.multiplier`                 | The multiplier of available memory to use for the split validator                         | `0.75`                                                              |
| `env.splitvalidator.goMaxProcs.enabled`                    | Enable setting GOMAXPROCS for the split validator                                         | `true`                                                              |
| `env.splitvalidator.goMaxProcs.multiplier`                 | The multiplier to use for CPU request (default 2)                                         | `2`                                                                 |
| `env.nitro.goMemLimit.enabled`                             | Enable setting the garbage cleanup limit in Go for nitro                                  | `true`                                                              |
| `env.nitro.goMemLimit.multiplier`                          | The multiplier of available memory to use for nitro                                       | `0.9`                                                               |
| `env.nitro.goMaxProcs.enabled`                             | Enable setting GOMAXPROCS for nitro                                                       | `false`                                                             |
| `env.nitro.goMaxProcs.multiplier`                          | The multiplier to use for CPU request (default 2)                                         | `2`                                                                 |
| `env.resourceMgmtMemFreeLimit.enabled`                     | Enable nitro resource management                                                          | `false`                                                             |
| `env.resourceMgmtMemFreeLimit.multiplier`                  | The multiplier of available memory to use                                                 | `0.05`                                                              |
| `env.blockValidatorMemFreeLimit.enabled`                   | Enable block validator memory management                                                  | `false`                                                             |
| `env.blockValidatorMemFreeLimit.multiplier`                | The multiplier of available memory to use                                                 | `0.05`                                                              |
| `persistence.enabled`                                      | Enable persistence                                                                        | `true`                                                              |
| `persistence.size`                                         | Size of the persistent volume claim                                                       | `500Gi`                                                             |
| `persistence.storageClassName`                             | Storage class of the persistent volume claim                                              | `nil`                                                               |
| `persistence.accessModes`                                  | Access modes of the persistent volume claim                                               | `["ReadWriteOnce"]`                                                 |
| `blobPersistence.enabled`                                  | Enable blob persistence                                                                   | `false`                                                             |
| `blobPersistence.size`                                     | Size of the blob persistent volume claim                                                  | `100Gi`                                                             |
| `blobPersistence.storageClassName`                         | Storage class of the blob persistent volume claim                                         | `nil`                                                               |
| `blobPersistence.accessModes`                              | Access modes of the blob persistent volume claim                                          | `["ReadWriteOnce"]`                                                 |
| `serviceMonitor.enabled`                                   | Enable service monitor CRD for prometheus operator                                        | `false`                                                             |
| `serviceMonitor.portName`                                  | Name of the port to monitor                                                               | `metrics`                                                           |
| `serviceMonitor.path`                                      | Path to monitor                                                                           | `/debug/metrics/prometheus`                                         |
| `serviceMonitor.interval`                                  | Interval to monitor                                                                       | `5s`                                                                |
| `serviceMonitor.additionalLabels`                          | Additional labels for the service monitor                                                 | `{}`                                                                |
| `serviceMonitor.relabelings`                               | Add relabelings for the metrics being scraped                                             | `[]`                                                                |
| `perReplicaService.enabled`                                | Enable a service for each sts replica                                                     | `false`                                                             |
| `perReplicaService.publishNotReadyAddresses`               | Publish not ready addresses                                                               | `true`                                                              |
| `perReplicaService.annotations`                            | Annotations for the per replica service. Supports templating with .ordinal for pod index  | `{}`                                                                |
| `perReplicaService.type`                                   | Service type for per replica services. If not set, uses service.type                      | `nil`                                                               |
| `perReplicaService.loadBalancerClass`                      | Load balancer class for per replica services                                              | `nil`                                                               |
| `perReplicaService.loadBalancerSourceRanges`               | Load balancer source ranges for per replica services                                      | `nil`                                                               |
| `perReplicaHeadlessService.enabled`                        | Enable a headless service for each sts replica                                            | `false`                                                             |
| `perReplicaHeadlessService.publishNotReadyAddresses`       | Publish not ready addresses                                                               | `true`                                                              |
| `perReplicaHeadlessService.annotations`                    | Annotations for the per replica headless service                                          | `{}`                                                                |
| `headlessService.enabled`                                  | Enable headless service                                                                   | `true`                                                              |
| `headlessService.publishNotReadyAddresses`                 | Publish not ready addresses                                                               | `true`                                                              |
| `headlessService.annotations`                              | Annotations for the headless service                                                      | `{}`                                                                |
| `jwtSecret.enabled`                                        | Enable a jwt secret for use with the stateless validator                                  | `false`                                                             |
| `jwtSecret.value`                                          | Value of the jwt secret for use with the stateless validator                              | `""`                                                                |
| `auth.enabled`                                             | Enable auth for the stateless validator                                                   | `false`                                                             |
| `pdb.enabled`                                              | Enable pod disruption budget                                                              | `false`                                                             |
| `pdb.minAvailable`                                         | Minimum number of pods available                                                          | `75%`                                                               |
| `pdb.maxUnavailable`                                       | Maximum number of pods unavailable                                                        | `""`                                                                |
| `serviceAccount.create`                                    | Create a service account                                                                  | `true`                                                              |
| `serviceAccount.annotations`                               | Annotations for the service account                                                       | `{}`                                                                |
| `serviceAccount.name`                                      | Name of the service account                                                               | `""`                                                                |
| `podAnnotations`                                           | Annotations for the pod                                                                   | `{}`                                                                |
| `podLabels`                                                | Labels for the pod                                                                        | `{}`                                                                |
| `podSecurityContext.fsGroup`                               | Group id for the pod                                                                      | `1000`                                                              |
| `podSecurityContext.runAsGroup`                            | Group id for the user                                                                     | `1000`                                                              |
| `podSecurityContext.runAsNonRoot`                          | Run as non root                                                                           | `true`                                                              |
| `podSecurityContext.runAsUser`                             | User id for the user                                                                      | `1000`                                                              |
| `podSecurityContext.fsGroupChangePolicy`                   | Policy for the fs group                                                                   | `OnRootMismatch`                                                    |
| `securityContext`                                          | Security context for the container                                                        | `{}`                                                                |
| `priorityClassName`                                        | Priority class name                                                                       | `""`                                                                |
| `service.type`                                             | Service type                                                                              | `ClusterIP`                                                         |
| `service.publishNotReadyAddresses`                         | Publish not ready addresses                                                               | `false`                                                             |
| `service.loadBalancerClass`                                | Load balancer class for the service                                                       | `nil`                                                               |
| `service.loadBalancerSourceRanges`                         | Load balancer source ranges for the service                                               | `nil`                                                               |
| `resources`                                                | Resources for the container                                                               | `{}`                                                                |
| `nodeSelector`                                             | Node selector for the pod                                                                 | `{}`                                                                |
| `tolerations`                                              | Tolerations for the pod                                                                   | `[]`                                                                |
| `affinity`                                                 | Affinity for the pod                                                                      | `{}`                                                                |
| `additionalVolumeClaims`                                   | Additional volume claims for the pod                                                      | `[]`                                                                |
| `extraVolumes`                                             | Additional volumes for the pod                                                            | `[]`                                                                |
| `extraVolumeMounts`                                        | Additional volume mounts for the pod                                                      | `[]`                                                                |
| `extraPorts`                                               | Additional ports for the pod                                                              | `[]`                                                                |
| `wallet.mountPath`                                         | Path to mount the wallets                                                                 | `/wallet/`                                                          |
| `wallet.files`                                             | Key value pair of wallet name and contents (ethers json format)                           | `{}`                                                                |
| `enableAutoConfigProcessing`                               | Enable intelligent automatic configuration processing                                     | `true`                                                              |
| `configmap.enabled`                                        | Enable a configmap for the nitro container                                                | `true`                                                              |
| `configmap.removeKeys`                                     | List of keys to remove from the config (dot-separated paths, e.g., "metrics-server.port") | `[]`                                                                |
| `configmap.data`                                           | See Configuration Options for the full list of options                                    |                                                                     |
| `configmap.data.conf.env-prefix`                           | Environment variable prefix                                                               | `NITRO`                                                             |
| `configmap.data.http.addr`                                 | Address to bind http service to                                                           | `0.0.0.0`                                                           |
| `configmap.data.http.api`                                  | List of apis to enable                                                                    | `["arb","eth","net","web3","txpool","arbdebug"]`                    |
| `configmap.data.http.corsdomain`                           | CORS domain                                                                               | `*`                                                                 |
| `configmap.data.http.port`                                 | Port to bind http service to                                                              | `8547`                                                              |
| `configmap.data.http.rpcprefix`                            | Prefix for rpc calls                                                                      | `/rpc`                                                              |
| `configmap.data.http.vhosts`                               | Vhosts to allow                                                                           | `*`                                                                 |
| `configmap.data.parent-chain.id`                           | ID of the parent chain                                                                    | `1`                                                                 |
| `configmap.data.parent-chain.connection.url`               | URL of the parent chain                                                                   | `""`                                                                |
| `configmap.data.chain.id`                                  | ID of the chain                                                                           | `42161`                                                             |
| `configmap.data.log-type`                                  | Type of log                                                                               | `json`                                                              |
| `configmap.data.metrics`                                   | Enable metrics                                                                            | `false`                                                             |
| `configmap.data.metrics-server.addr`                       | Address to bind metrics server to                                                         | `0.0.0.0`                                                           |
| `configmap.data.metrics-server.port`                       | Port to bind metrics server to                                                            | `6070`                                                              |
| `configmap.data.persistent.chain`                          | Path to persistent chain data                                                             | `/home/user/data/`                                                  |
| `configmap.data.ws.addr`                                   | Address to bind ws service to                                                             | `0.0.0.0`                                                           |
| `configmap.data.ws.api`                                    | List of apis to enable                                                                    | `["net","web3","eth","arb"]`                                        |
| `configmap.data.ws.port`                                   | Port to bind ws service to                                                                | `8548`                                                              |
| `configmap.data.ws.rpcprefix`                              | Prefix for rpc calls                                                                      | `/ws`                                                               |
| `configmap.data.validation.wasm.allowed-wasm-module-roots` | Default flags as of v3.0.0                                                                | `["/home/user/nitro-legacy/machines","/home/user/target/machines"]` |

### Stateless Validator

| Name                                                                                | Description                                                                                       | Value                         |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ----------------------------- |
| `validator.enabled`                                                                 | Enable the stateless validator                                                                    | `false`                       |
| `validator.splitvalidator.deployments`                                              | List of deployments for the split validator. Each deploymeny can have its own image, config, etc. | `[]`                          |
| `validator.splitvalidator.global.replicaCount`                                      | Number of replicas for the split validator                                                        | `1`                           |
| `validator.splitvalidator.global.nodeSelector`                                      | Node selector for the split validator                                                             | `{kubernetes.io/arch: amd64}` |
| `validator.splitvalidator.global.lifecycle`                                         | Lifecycle hooks configuration                                                                     | `{}`                          |
| `validator.splitvalidator.global.image.repository`                                  | Docker image repository for the split validator                                                   | `""`                          |
| `validator.splitvalidator.global.image.tag`                                         | Docker image tag for the split validator                                                          | `""`                          |
| `validator.splitvalidator.global.useConfigmap`                                      | Use the configmap for the validator container                                                     | `true`                        |
| `validator.splitvalidator.global.configmap.data.auth.addr`                          | Address to bind auth service to                                                                   | `0.0.0.0`                     |
| `validator.splitvalidator.global.configmap.data.auth.port`                          | Port to bind auth service to                                                                      | `8549`                        |
| `validator.splitvalidator.global.configmap.data.auth.origins`                       | Origins to allow to access auth service                                                           | `*`                           |
| `validator.splitvalidator.global.configmap.data.auth.jwtsecret`                     | Path to jwt secret for auth service                                                               | `/secrets/jwtsecret`          |
| `validator.splitvalidator.global.configmap.data.metrics`                            | Enable metrics                                                                                    | `false`                       |
| `validator.splitvalidator.global.configmap.data.metrics-server.addr`                | Address to bind metrics server to                                                                 | `0.0.0.0`                     |
| `validator.splitvalidator.global.configmap.data.metrics-server.port`                | Port to bind metrics server to                                                                    | `6070`                        |
| `validator.splitvalidator.global.configmap.data.log-type`                           | Type of logs                                                                                      | `json`                        |
| `validator.splitvalidator.global.extraArgs`                                         | Extra arguments for the validator container                                                       | `[]`                          |
| `validator.splitvalidator.global.auth.enabled`                                      | Enable the auth service for the validator statefulset                                             | `true`                        |
| `validator.splitvalidator.global.auth.port`                                         | Port to bind auth service to                                                                      | `8549`                        |
| `validator.splitvalidator.global.metrics.enabled`                                   | Enable metrics for the validator statefulset                                                      | `false`                       |
| `validator.splitvalidator.global.metrics.port`                                      | Port to bind metrics server to                                                                    | `6070`                        |
| `validator.splitvalidator.global.extraLabels`                                       | Extra labels for the validator statefulset                                                        | `{}`                          |
| `validator.splitvalidator.global.serviceMonitor.enabled`                            | Enable service monitor CRD for prometheus operator                                                | `false`                       |
| `validator.splitvalidator.global.serviceMonitor.portName`                           | Name of the port to monitor                                                                       | `metrics`                     |
| `validator.splitvalidator.global.serviceMonitor.path`                               | Path to monitor                                                                                   | `/debug/metrics/prometheus`   |
| `validator.splitvalidator.global.serviceMonitor.interval`                           | Interval to monitor                                                                               | `5s`                          |
| `validator.splitvalidator.global.serviceMonitor.additionalLabels`                   | Additional labels for the service monitor                                                         | `{}`                          |
| `validator.splitvalidator.global.serviceMonitor.relabelings`                        | Add relabelings for the metrics being scraped                                                     | `[]`                          |
| `validator.splitvalidator.global.livenessProbe.enabled`                             | Enable the liveness probe for the validator statefulset                                           | `true`                        |
| `validator.splitvalidator.global.livenessProbe.tcpSocket.port`                      | Port to probe                                                                                     | `auth`                        |
| `validator.splitvalidator.global.livenessProbe.initialDelaySeconds`                 | Initial delay for the liveness probe                                                              | `30`                          |
| `validator.splitvalidator.global.livenessProbe.periodSeconds`                       | Period for the liveness probe                                                                     | `10`                          |
| `validator.splitvalidator.global.pdb.enabled`                                       | Enable pod disruption budget                                                                      | `true`                        |
| `validator.splitvalidator.global.pdb.minAvailable`                                  | Minimum number of pods available                                                                  | `""`                          |
| `validator.splitvalidator.global.pdb.maxUnavailable`                                | Maximum number of pods unavailable                                                                | `100%`                        |
| `validator.splitvalidator.global.keda.enabled`                                      | Enable keda                                                                                       | `false`                       |
| `validator.splitvalidator.global.keda.scaledObject`                                 | Scaled object for keda                                                                            | `{}`                          |
| `validator.splitvalidator.global.hpa.enabled`                                       | Enable horizontal pod autoscaler                                                                  | `false`                       |
| `validator.splitvalidator.global.hpa.minReplicas`                                   | Minimum number of replicas                                                                        | `1`                           |
| `validator.splitvalidator.global.hpa.maxReplicas`                                   | Maximum number of replicas                                                                        | `10`                          |
| `validator.splitvalidator.global.hpa.metrics[0].type`                               | Type of metric to monitor                                                                         | `Resource`                    |
| `validator.splitvalidator.global.hpa.metrics[0].resource.name`                      | Name of the resource to monitor (cpu/memory)                                                      | `cpu`                         |
| `validator.splitvalidator.global.hpa.metrics[0].resource.target.type`               | Type of target                                                                                    | `Utilization`                 |
| `validator.splitvalidator.global.hpa.metrics[0].resource.target.averageUtilization` | Target average utilization of the resource                                                        | `80`                          |
| `validator.splitvalidator.global.hpa.behavior.scaleUp.stabilizationWindowSeconds`   | Stabilization window for scaling up                                                               | `300`                         |
| `validator.splitvalidator.global.hpa.behavior.scaleUp.selectPolicy`                 | Policy to use when scaling up                                                                     | `Max`                         |
| `validator.splitvalidator.global.hpa.behavior.scaleUp.policies[0].type`             | Type of scale up policy                                                                           | `Percent`                     |
| `validator.splitvalidator.global.hpa.behavior.scaleUp.policies[0].value`            | Percentage of pods to scale up                                                                    | `50`                          |
| `validator.splitvalidator.global.hpa.behavior.scaleUp.policies[0].periodSeconds`    | Period for scaling up                                                                             | `60`                          |
| `validator.splitvalidator.global.hpa.behavior.scaleDown.stabilizationWindowSeconds` | Stabilization window for scaling down                                                             | `300`                         |
| `validator.splitvalidator.global.hpa.behavior.scaleDown.selectPolicy`               | Policy to use when scaling down                                                                   | `Min`                         |
| `validator.splitvalidator.global.hpa.behavior.scaleDown.policies[0].type`           | Type of scale down policy                                                                         | `Percent`                     |
| `validator.splitvalidator.global.hpa.behavior.scaleDown.policies[0].value`          | Percentage of pods to scale down                                                                  | `50`                          |
| `validator.splitvalidator.global.hpa.behavior.scaleDown.policies[0].periodSeconds`  | Period for scaling down                                                                           | `60`                          |
| `validator.splitvalidator.global.readinessProbe.enabled`                            | Enable the readiness probe for the validator statefulset                                          | `true`                        |
| `validator.splitvalidator.global.readinessProbe.tcpSocket.port`                     | Port to probe                                                                                     | `auth`                        |
| `validator.splitvalidator.global.readinessProbe.initialDelaySeconds`                | Initial delay for the readiness probe                                                             | `3`                           |
| `validator.splitvalidator.global.readinessProbe.periodSeconds`                      | Period for the readiness probe                                                                    | `3`                           |
| `validator.splitvalidator.global.startupProbe.enabled`                              | Enable the startup probe for the validator statefulset                                            | `false`                       |
| `validator.splitvalidator.global.resources`                                         | Resources for the validator container                                                             | `{}`                          |
| `validator.splitvalidator.global.extraEnv`                                          | Extra environment variables for the validator container                                           | `{}`                          |
| `validator.splitvalidator.global.extraPorts`                                        | Additional ports for the stateless validator pod                                                  | `[]`                          |
| `validator.splitvalidator.global.podAnnotations`                                    | Annotations for the stateless validator pod                                                       | `{}`                          |
| `validator.splitvalidator.global.priorityClassName`                                 | Priority class name for the stateless validator pod                                               | `""`                          |

## Configuration Options
The following table lists the exhaustive configurable parameters that can be applied as part of the configmap (nested under `configmap.data`) or as standalone cli flags.

Option | Description | Default
--- | --- | ---

## Notes
