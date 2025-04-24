# Arbitrum Nitro

A Helm chart for Arbitrum Nitro. For full details on running a node, please see the official [Arbitrum Documentation](https://docs.arbitrum.io/node-running/quickstart-running-a-node).

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

| Name                                                       | Description                                                                     | Value                                                               |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| `lifecycle`                                                | Lifecycle hooks configuration                                                   | `{}`                                                                |
| `extraEnv`                                                 | Additional environment variables for the container                              | `{}`                                                                |
| `replicaCount`                                             | Number of replicas to deploy                                                    | `1`                                                                 |
| `image.repository`                                         | Docker image repository                                                         | `offchainlabs/nitro-node`                                           |
| `image.pullPolicy`                                         | Docker image pull policy                                                        | `Always`                                                            |
| `image.tag`                                                | Docker image tag. Overrides the chart appVersion.                               | `""`                                                                |
| `imagePullSecrets`                                         | Docker registry pull secret names as an array                                   | `[]`                                                                |
| `nameOverride`                                             | String to partially override nitro.fullname                                     | `""`                                                                |
| `fullnameOverride`                                         | String to fully override nitro.fullname                                         | `""`                                                                |
| `commandOverride`                                          | Command override for the nitro container                                        | `{}`                                                                |
| `livenessProbe`                                            | Liveness probe configuration                                                    | `{}`                                                                |
| `readinessProbe`                                           | Readiness probe configuration                                                   | `{}`                                                                |
| `startupProbe.enabled`                                     | Enable built in startup probe                                                   | `true`                                                              |
| `startupProbe.failureThreshold`                            | Number of failures before pod is considered unhealthy                           | `2419200`                                                           |
| `startupProbe.periodSeconds`                               | Number of seconds between startup probes                                        | `1`                                                                 |
| `startupProbe.command`                                     | Command to run for the startup probe. If empty, the built in probe will be used | `""`                                                                |
| `updateStrategy.type`                                      | Update strategy type                                                            | `RollingUpdate`                                                     |
| `env.splitvalidator.goMemLimit.enabled`                    | Enable setting the garbage cleanup limit in Go for the split validator          | `true`                                                              |
| `env.splitvalidator.goMemLimit.multiplier`                 | The multiplier of available memory to use for the split validator               | `0.75`                                                              |
| `env.nitro.goMemLimit.enabled`                             | Enable setting the garbage cleanup limit in Go for nitro                        | `true`                                                              |
| `env.nitro.goMemLimit.multiplier`                          | The multiplier of available memory to use for nitro                             | `0.9`                                                               |
| `env.resourceMgmtMemFreeLimit.enabled`                     | Enable nitro resource management                                                | `false`                                                             |
| `env.resourceMgmtMemFreeLimit.multiplier`                  | The multiplier of available memory to use                                       | `0.05`                                                              |
| `env.blockValidatorMemFreeLimit.enabled`                   | Enable block validator memory management                                        | `false`                                                             |
| `env.blockValidatorMemFreeLimit.multiplier`                | The multiplier of available memory to use                                       | `0.05`                                                              |
| `persistence.enabled`                                      | Enable persistence                                                              | `true`                                                              |
| `persistence.size`                                         | Size of the persistent volume claim                                             | `500Gi`                                                             |
| `persistence.storageClassName`                             | Storage class of the persistent volume claim                                    | `nil`                                                               |
| `persistence.accessModes`                                  | Access modes of the persistent volume claim                                     | `["ReadWriteOnce"]`                                                 |
| `blobPersistence.enabled`                                  | Enable blob persistence                                                         | `false`                                                             |
| `blobPersistence.size`                                     | Size of the blob persistent volume claim                                        | `100Gi`                                                             |
| `blobPersistence.storageClassName`                         | Storage class of the blob persistent volume claim                               | `nil`                                                               |
| `blobPersistence.accessModes`                              | Access modes of the blob persistent volume claim                                | `["ReadWriteOnce"]`                                                 |
| `serviceMonitor.enabled`                                   | Enable service monitor CRD for prometheus operator                              | `false`                                                             |
| `serviceMonitor.portName`                                  | Name of the port to monitor                                                     | `metrics`                                                           |
| `serviceMonitor.path`                                      | Path to monitor                                                                 | `/debug/metrics/prometheus`                                         |
| `serviceMonitor.interval`                                  | Interval to monitor                                                             | `5s`                                                                |
| `serviceMonitor.additionalLabels`                          | Additional labels for the service monitor                                       | `{}`                                                                |
| `serviceMonitor.relabelings`                               | Add relabelings for the metrics being scraped                                   | `[]`                                                                |
| `perReplicaService.enabled`                                | Enable a service for each sts replica                                           | `false`                                                             |
| `perReplicaService.publishNotReadyAddresses`               | Publish not ready addresses                                                     | `true`                                                              |
| `perReplicaService.annotations`                            | Annotations for the per replica service                                         | `{}`                                                                |
| `perReplicaHeadlessService.enabled`                        | Enable a headless service for each sts replica                                  | `false`                                                             |
| `perReplicaHeadlessService.publishNotReadyAddresses`       | Publish not ready addresses                                                     | `true`                                                              |
| `perReplicaHeadlessService.annotations`                    | Annotations for the per replica headless service                                | `{}`                                                                |
| `headlessService.enabled`                                  | Enable headless service                                                         | `true`                                                              |
| `headlessService.publishNotReadyAddresses`                 | Publish not ready addresses                                                     | `true`                                                              |
| `headlessService.annotations`                              | Annotations for the headless service                                            | `{}`                                                                |
| `jwtSecret.enabled`                                        | Enable a jwt secret for use with the stateless validator                        | `false`                                                             |
| `jwtSecret.value`                                          | Value of the jwt secret for use with the stateless validator                    | `""`                                                                |
| `auth.enabled`                                             | Enable auth for the stateless validator                                         | `false`                                                             |
| `pdb.enabled`                                              | Enable pod disruption budget                                                    | `false`                                                             |
| `pdb.minAvailable`                                         | Minimum number of pods available                                                | `75%`                                                               |
| `pdb.maxUnavailable`                                       | Maximum number of pods unavailable                                              | `""`                                                                |
| `serviceAccount.create`                                    | Create a service account                                                        | `true`                                                              |
| `serviceAccount.annotations`                               | Annotations for the service account                                             | `{}`                                                                |
| `serviceAccount.name`                                      | Name of the service account                                                     | `""`                                                                |
| `podAnnotations`                                           | Annotations for the pod                                                         | `{}`                                                                |
| `podLabels`                                                | Labels for the pod                                                              | `{}`                                                                |
| `podSecurityContext.fsGroup`                               | Group id for the pod                                                            | `1000`                                                              |
| `podSecurityContext.runAsGroup`                            | Group id for the user                                                           | `1000`                                                              |
| `podSecurityContext.runAsNonRoot`                          | Run as non root                                                                 | `true`                                                              |
| `podSecurityContext.runAsUser`                             | User id for the user                                                            | `1000`                                                              |
| `podSecurityContext.fsGroupChangePolicy`                   | Policy for the fs group                                                         | `OnRootMismatch`                                                    |
| `securityContext`                                          | Security context for the container                                              | `{}`                                                                |
| `priorityClassName`                                        | Priority class name                                                             | `""`                                                                |
| `service.type`                                             | Service type                                                                    | `ClusterIP`                                                         |
| `service.publishNotReadyAddresses`                         | Publish not ready addresses                                                     | `false`                                                             |
| `resources`                                                | Resources for the container                                                     | `{}`                                                                |
| `nodeSelector`                                             | Node selector for the pod                                                       | `{}`                                                                |
| `tolerations`                                              | Tolerations for the pod                                                         | `[]`                                                                |
| `affinity`                                                 | Affinity for the pod                                                            | `{}`                                                                |
| `additionalVolumeClaims`                                   | Additional volume claims for the pod                                            | `[]`                                                                |
| `extraVolumes`                                             | Additional volumes for the pod                                                  | `[]`                                                                |
| `extraVolumeMounts`                                        | Additional volume mounts for the pod                                            | `[]`                                                                |
| `extraPorts`                                               | Additional ports for the pod                                                    | `[]`                                                                |
| `wallet.mountPath`                                         | Path to mount the wallets                                                       | `/wallet/`                                                          |
| `wallet.files`                                             | Key value pair of wallet name and contents (ethers json format)                 | `{}`                                                                |
| `enableAutoConfigProcessing`                               | Enable intelligent automatic configuration processing                           | `true`                                                              |
| `configmap.enabled`                                        | Enable a configmap for the nitro container                                      | `true`                                                              |
| `configmap.data`                                           | See Configuration Options for the full list of options                          |                                                                     |
| `configmap.data.conf.env-prefix`                           | Environment variable prefix                                                     | `NITRO`                                                             |
| `configmap.data.http.addr`                                 | Address to bind http service to                                                 | `0.0.0.0`                                                           |
| `configmap.data.http.api`                                  | List of apis to enable                                                          | `["arb","personal","eth","net","web3","txpool","arbdebug"]`         |
| `configmap.data.http.corsdomain`                           | CORS domain                                                                     | `*`                                                                 |
| `configmap.data.http.port`                                 | Port to bind http service to                                                    | `8547`                                                              |
| `configmap.data.http.rpcprefix`                            | Prefix for rpc calls                                                            | `/rpc`                                                              |
| `configmap.data.http.vhosts`                               | Vhosts to allow                                                                 | `*`                                                                 |
| `configmap.data.parent-chain.id`                           | ID of the parent chain                                                          | `1`                                                                 |
| `configmap.data.parent-chain.connection.url`               | URL of the parent chain                                                         | `""`                                                                |
| `configmap.data.chain.id`                                  | ID of the chain                                                                 | `42161`                                                             |
| `configmap.data.log-type`                                  | Type of log                                                                     | `json`                                                              |
| `configmap.data.metrics`                                   | Enable metrics                                                                  | `false`                                                             |
| `configmap.data.metrics-server.addr`                       | Address to bind metrics server to                                               | `0.0.0.0`                                                           |
| `configmap.data.metrics-server.port`                       | Port to bind metrics server to                                                  | `6070`                                                              |
| `configmap.data.persistent.chain`                          | Path to persistent chain data                                                   | `/home/user/data/`                                                  |
| `configmap.data.ws.addr`                                   | Address to bind ws service to                                                   | `0.0.0.0`                                                           |
| `configmap.data.ws.api`                                    | List of apis to enable                                                          | `["net","web3","eth","arb"]`                                        |
| `configmap.data.ws.port`                                   | Port to bind ws service to                                                      | `8548`                                                              |
| `configmap.data.ws.rpcprefix`                              | Prefix for rpc calls                                                            | `/ws`                                                               |
| `configmap.data.validation.wasm.allowed-wasm-module-roots` | Default flags as of v3.0.0                                                      | `["/home/user/nitro-legacy/machines","/home/user/target/machines"]` |

### Stateless Validator

| Name                                                                                | Description                                                                                       | Value                         |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- | ----------------------------- |
| `validator.enabled`                                                                 | Enable the stateless validator                                                                    | `true`                        |
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
`auth.addr` | string                                                                                       AUTH-RPC server listening interface | `127.0.0.1`
`auth.api` | strings                                                                                       APIs offered over the AUTH-RPC interface | `[validation]`
`auth.jwtsecret` | string                                                                                  Path to file holding JWT secret (32B hex) | None
`auth.origins` | strings                                                                                   Origins from which to accept AUTH requests | `[localhost]`
`auth.port` | int                                                                                          AUTH-RPC server listening port | `8549`
`blocks-reexecutor.enable` | enables re-execution of a range of blocks against historic state | None
`blocks-reexecutor.end-block` | uint                                                                       last block number of the block range for re-execution | None
`blocks-reexecutor.min-blocks-per-thread` | uint                                                           minimum number of blocks to execute per thread. When mode is random this acts as the size of random block range sample | None
`blocks-reexecutor.mode` | string                                                                          mode to run the blocks-reexecutor on. Valid modes full and random. full - execute all the blocks in the given range. random - execute a random sample range of blocks with in a given range | `random`
`blocks-reexecutor.room` | int                                                                             number of threads to parallelize blocks re-execution | `10`
`blocks-reexecutor.start-block` | uint                                                                     first block number of the block range for re-execution | None
`blocks-reexecutor.trie-clean-limit` | int                                                                 memory allowance (MB) to use for caching trie nodes in memory | None
`chain.dev-wallet.account` | string                                                                        account to use | `is first account in keystore`
`chain.dev-wallet.only-create-key` | if true, creates new key then exits | None
`chain.dev-wallet.password` | string                                                                       wallet passphrase | `PASSWORD_NOT_SET`
`chain.dev-wallet.pathname` | string                                                                       pathname for wallet | None
`chain.dev-wallet.private-key` | string                                                                    private key for wallet | None
`chain.id` | uint                                                                                          L2 chain ID (determines Arbitrum network) | None
`chain.info-files` | strings                                                                               L2 chain info json files | None
`chain.info-json` | string                                                                                 L2 chain info in json string format | None
`chain.name` | string                                                                                      L2 chain name (determines Arbitrum network) | None
`conf.dump` | print out currently active configuration file | None
`conf.env-prefix` | string                                                                                 environment variables with given prefix will be loaded as configuration values | None
`conf.file` | strings                                                                                      name of configuration file | None
`conf.reload-interval` | duration                                                                          how often to reload configuration (0=disable periodic reloading) | None
`conf.s3.access-key` | string                                                                              S3 access key | None
`conf.s3.bucket` | string                                                                                  S3 bucket | None
`conf.s3.object-key` | string                                                                              S3 object key | None
`conf.s3.region` | string                                                                                  S3 region | None
`conf.s3.secret-key` | string                                                                              S3 secret key | None
`conf.string` | string                                                                                     configuration as JSON string | None
`ensure-rollup-deployment` | before starting the node, wait until the transaction that deployed rollup is finalized | `true`
`execution.block-metadata-api-blocks-limit` | uint                                                         maximum number of blocks allowed to be queried for blockMetadata per arb_getRawBlockMetadata query. Enabled by default, set 0 to disable the limit | `100`
`execution.block-metadata-api-cache-size` | uint                                                           size (in bytes) of lru cache storing the blockMetadata to service arb_getRawBlockMetadata | `104857600`
`execution.caching.archive` | retain past block state | None
`execution.caching.block-age` | duration                                                                   minimum age of recent blocks to keep in memory | `30m0s`
`execution.caching.block-count` | uint                                                                     minimum number of recent blocks to keep in memory | `128`
`execution.caching.database-cache` | int                                                                   amount of memory in megabytes to cache database contents with | `2048`
`execution.caching.disable-stylus-cache-metrics-collection` | disable metrics collection for the stylus cache | None
`execution.caching.max-amount-of-gas-to-skip-state-saving` | uint                                          maximum amount of gas in blocks to skip saving state to Persistent storage (archive node only) -- warning: this option seems to cause issues | None
`execution.caching.max-number-of-blocks-to-skip-state-saving` | uint32                                     maximum number of blocks to skip state saving to persistent storage (archive node only) -- warning: this option seems to cause issues | None
`execution.caching.snapshot-cache` | int                                                                   amount of memory in megabytes to cache state snapshots with | `400`
`execution.caching.snapshot-restore-gas-limit` | uint                                                      maximum gas rolled back to recover snapshot | `300000000000`
`execution.caching.state-history` | uint                                                                   number of recent blocks to retain state history for (path state-scheme only) | `345600`
`execution.caching.state-scheme` | string                                                                  scheme to use for state trie storage (hash, path) | `hash`
`execution.caching.stylus-lru-cache-capacity` | uint32                                                     capacity, in megabytes, of the LRU cache that keeps initialized stylus programs | `256`
`execution.caching.trie-cap-limit` | uint32                                                                amount of memory in megabytes to be used in the TrieDB Cap operation during maintenance | `100`
`execution.caching.trie-clean-cache` | int                                                                 amount of memory in megabytes to cache unchanged state trie nodes with | `600`
`execution.caching.trie-dirty-cache` | int                                                                 amount of memory in megabytes to cache state diffs against disk with (larger cache lowers database growth) | `1024`
`execution.caching.trie-time-limit` | duration                                                             maximum block processing time before trie is written to hard-disk | `1h0m0s`
`execution.enable-prefetch-block` | enable prefetching of blocks | `true`
`execution.forwarder.connection-timeout` | duration                                                        total time to wait before cancelling connection | `30s`
`execution.forwarder.idle-connection-timeout` | duration                                                   time until idle connections are closed | `15s`
`execution.forwarder.max-idle-connections` | int                                                           maximum number of idle connections to keep open | `1`
`execution.forwarder.redis-url` | string                                                                   the Redis URL to recomend target via | None
`execution.forwarder.retry-interval` | duration                                                            minimal time between update retries | `100ms`
`execution.forwarder.update-interval` | duration                                                           forwarding target update interval | `1s`
`execution.forwarding-target` | string                                                                     transaction forwarding target URL, or "null" to disable forwarding (iff not sequencer) | None
`execution.parent-chain-reader.dangerous.wait-for-tx-approval-safe-poll` | duration                        Dangerous! only meant to be used by system tests | None
`execution.parent-chain-reader.enable` | enable reader connection | `true`
`execution.parent-chain-reader.old-header-timeout` | duration                                              warns if the latest l1 block is at least this old | `5m0s`
`execution.parent-chain-reader.poll-interval` | duration                                                   interval when polling endpoint | `15s`
`execution.parent-chain-reader.poll-only` | do not attempt to subscribe to header events | None
`execution.parent-chain-reader.poll-timeout` | duration                                                    timeout when polling endpoint | `5s`
`execution.parent-chain-reader.subscribe-err-interval` | duration                                          interval for subscribe error | `5m0s`
`execution.parent-chain-reader.tx-timeout` | duration                                                      timeout when waiting for a transaction | `5m0s`
`execution.parent-chain-reader.use-finality-data` | use l1 data about finalized/safe blocks | `true`
`execution.recording-database.max-prepared` | int                                                          max references to store in the recording database | `1000`
`execution.recording-database.trie-clean-cache` | int                                                      like trie-clean-cache for the separate, recording database (used for validation) | `16`
`execution.recording-database.trie-dirty-cache` | int                                                      like trie-dirty-cache for the separate, recording database (used for validation) | `1024`
`execution.rpc.allow-method` | strings                                                                     list of whitelisted rpc methods | None
`execution.rpc.arbdebug.block-range-bound` | uint                                                          bounds the number of blocks arbdebug calls may return | `256`
`execution.rpc.arbdebug.timeout-queue-bound` | uint                                                        bounds the length of timeout queues arbdebug calls may return | `512`
`execution.rpc.bloom-bits-blocks` | uint                                                                   number of blocks a single bloom bit section vector holds | `16384`
`execution.rpc.bloom-confirms` | uint                                                                      number of confirmation blocks before a bloom section is considered final | `256`
`execution.rpc.classic-redirect` | string                                                                  url to redirect classic requests, use "error:[CODE:]MESSAGE" to return specified error instead of redirecting | None
`execution.rpc.classic-redirect-timeout` | duration                                                        timeout for forwarded classic requests, where 0 = no timeout | None
`execution.rpc.evm-timeout` | duration                                                                     timeout used for eth_call (0=infinite) | `5s`
`execution.rpc.feehistory-max-block-count` | uint                                                          max number of blocks a fee history request may cover | `1024`
`execution.rpc.filter-log-cache-size` | int                                                                log filter system maximum number of cached blocks | `32`
`execution.rpc.filter-timeout` | duration                                                                  log filter system maximum time filters stay active | `5m0s`
`execution.rpc.gas-cap` | uint                                                                             cap on computation gas that can be used in eth_call/estimateGas (0=infinite) | `50000000`
`execution.rpc.max-recreate-state-depth` | int                                                             maximum depth for recreating state, measured in l2 gas (0=don't recreate state, -1=infinite, -2=use default value for archive or non-archive node (whichever is configured)) | `-2`
`execution.rpc.tx-allow-unprotected` | allow transactions that aren't EIP-155 replay protected to be submitted over the RPC | `true`
`execution.rpc.tx-fee-cap` | float                                                                         cap on transaction fee (in ether) that can be sent via the RPC APIs (0 = no cap) | `1`
`execution.secondary-forwarding-target` | strings                                                          secondary transaction forwarding target URL | None
`execution.sequencer.enable` | act and post to l1 as sequencer | None
`execution.sequencer.enable-profiling` | enable CPU profiling and tracing | None
`execution.sequencer.expected-surplus-hard-threshold` | string                                             if expected surplus is lower than this value, new incoming transactions will be denied | `default`
`execution.sequencer.expected-surplus-soft-threshold` | string                                             if expected surplus is lower than this value, warnings are posted | `default`
`execution.sequencer.forwarder.connection-timeout` | duration                                              total time to wait before cancelling connection | `30s`
`execution.sequencer.forwarder.idle-connection-timeout` | duration                                         time until idle connections are closed | `1m0s`
`execution.sequencer.forwarder.max-idle-connections` | int                                                 maximum number of idle connections to keep open | `100`
`execution.sequencer.forwarder.redis-url` | string                                                         the Redis URL to recomend target via | None
`execution.sequencer.forwarder.retry-interval` | duration                                                  minimal time between update retries | `100ms`
`execution.sequencer.forwarder.update-interval` | duration                                                 forwarding target update interval | `1s`
`execution.sequencer.max-acceptable-timestamp-delta` | duration                                            maximum acceptable time difference between the local time and the latest L1 block's timestamp | `1h0m0s`
`execution.sequencer.max-block-speed` | duration                                                           minimum delay between blocks (sets a maximum speed of block production) | `250ms`
`execution.sequencer.max-revert-gas-reject` | uint                                                         maximum gas executed in a revert for the sequencer to reject the transaction instead of posting it (anti-DOS) | None
`execution.sequencer.max-tx-data-size` | int                                                               maximum transaction size the sequencer will accept | `95000`
`execution.sequencer.nonce-cache-size` | int                                                               size of the tx sender nonce cache | `1024`
`execution.sequencer.nonce-failure-cache-expiry` | duration                                                maximum amount of time to wait for a predecessor before rejecting a tx with nonce too high | `1s`
`execution.sequencer.nonce-failure-cache-size` | int                                                       number of transactions with too high of a nonce to keep in memory while waiting for their predecessor | `1024`
`execution.sequencer.queue-size` | int                                                                     size of the pending tx queue | `1024`
`execution.sequencer.queue-timeout` | duration                                                             maximum amount of time transaction can wait in queue | `12s`
`execution.sequencer.sender-whitelist` | strings                                                           comma separated whitelist of authorized senders (if empty, everyone is allowed) | None
`execution.sequencer.timeboost.auction-contract-address` | string                                          Address of the proxy pointing to the ExpressLaneAuction contract | None
`execution.sequencer.timeboost.auctioneer-address` | string                                                Address of the Timeboost Autonomous Auctioneer | None
`execution.sequencer.timeboost.early-submission-grace` | duration                                          period of time before the next round where submissions for the next round will be queued | `2s`
`execution.sequencer.timeboost.enable` | enable timeboost based on express lane auctions | None
`execution.sequencer.timeboost.express-lane-advantage` | duration                                          specify the express lane advantage | `200ms`
`execution.sequencer.timeboost.max-future-sequence-distance` | uint                                        maximum allowed difference (in terms of sequence numbers) between a future express lane tx and the current sequence count of a round | `1000`
`execution.sequencer.timeboost.queue-timeout-in-blocks` | uint                                             maximum amount of time (measured in blocks) that Express Lane transactions can wait in the sequencer's queue | `5`
`execution.sequencer.timeboost.redis-update-events-channel-size` | uint                                    size of update events' buffered channels in timeboost redis coordinator | `500`
`execution.sequencer.timeboost.redis-url` | string                                                         the Redis URL for expressLaneService to coordinate via | `unset`
`execution.sequencer.timeboost.sequencer-http-endpoint` | string                                           this sequencer's http endpoint | `http://localhost:8547`
`execution.stylus-target.amd64` | string                                                                   stylus programs compilation target for amd64 linux | `x86_64-linux-unknown+sse4.2+lzcnt+bmi`
`execution.stylus-target.arm64` | string                                                                   stylus programs compilation target for arm64 linux | `arm64-linux-unknown+neon`
`execution.stylus-target.extra-archs` | strings                                                            Comma separated list of extra architectures to cross-compile stylus program to and cache in wasm store (additionally to local target). Currently must include at least wavm. (supported targets: wavm, arm64, amd64, host) | `[wavm]`
`execution.stylus-target.host` | string                                                                    stylus programs compilation target for system other than 64-bit ARM or 64-bit x86 | None
`execution.sync-monitor.finalized-block-wait-for-block-validator` | wait for block validator to complete before returning finalized block number | None
`execution.sync-monitor.safe-block-wait-for-block-validator` | wait for block validator to complete before returning safe block number | None
`execution.tx-lookup-limit` | uint                                                                         retain the ability to lookup transactions by hash for the past N blocks (0 = all blocks) | `126230400`
`execution.tx-pre-checker.required-state-age` | int                                                        how long ago should the storage conditions from eth_SendRawTransactionConditional be true, 0 = don't check old state | `2`
`execution.tx-pre-checker.required-state-max-blocks` | uint                                                maximum number of blocks to look back while looking for the <required-state-age> seconds old state, 0 = don't limit the search | `4`
`execution.tx-pre-checker.strictness` | uint                                                               how strict to be when checking txs before forwarding them. 0 = accept anything, 10 = should never reject anything that'd succeed, 20 = likely won't reject anything that'd succeed, 30 = full validation which may reject txs that would succeed | `20`
`file-logging.buf-size` | int                                                                              size of intermediate log records buffer | `512`
`file-logging.compress` | enable compression of old log files | `true`
`file-logging.enable` | enable logging to file | `true`
`file-logging.file` | string                                                                               path to log file | `nitro.log`
`file-logging.local-time` | if true: local time will be used in old log filename timestamps | None
`file-logging.max-age` | int                                                                               maximum number of days to retain old log files based on the timestamp encoded in their filename (0 = no limit) | None
`file-logging.max-backups` | int                                                                           maximum number of old log files to retain (0 = no limit) | `20`
`file-logging.max-size` | int                                                                              log file size in Mb that will trigger log file rotation (0 = trigger disabled) | `5`
`graphql.corsdomain` | strings                                                                             Comma separated list of domains from which to accept cross origin requests (browser enforced) | None
`graphql.enable` | Enable graphql endpoint on the rpc endpoint | None
`graphql.vhosts` | strings                                                                                 Comma separated list of virtual hostnames from which to accept requests (server enforced). Accepts '*' wildcard | `[localhost]`
`http.addr` | string                                                                                       HTTP-RPC server listening interface | None
`http.api` | strings                                                                                       APIs offered over the HTTP-RPC interface | `[net,web3,eth,arb]`
`http.corsdomain` | strings                                                                                Comma separated list of domains from which to accept cross origin requests (browser enforced) | None
`http.port` | int                                                                                          HTTP-RPC server listening port | `8547`
`http.rpcprefix` | string                                                                                  HTTP path path prefix on which JSON-RPC is served. Use '/' to serve on all paths | None
`http.server-timeouts.idle-timeout` | duration                                                             the maximum amount of time to wait for the next request when keep-alives are enabled (http.Server.IdleTimeout) | `2m0s`
`http.server-timeouts.read-header-timeout` | duration                                                      the amount of time allowed to read the request headers (http.Server.ReadHeaderTimeout) | `30s`
`http.server-timeouts.read-timeout` | duration                                                             the maximum duration for reading the entire request (http.Server.ReadTimeout) | `30s`
`http.server-timeouts.write-timeout` | duration                                                            the maximum duration before timing out writes of the response (http.Server.WriteTimeout) | `30s`
`http.vhosts` | strings                                                                                    Comma separated list of virtual hostnames from which to accept requests (server enforced). Accepts '*' wildcard | `[localhost]`
`init.accounts-per-sync` | uint                                                                            during init - sync database every X accounts. Lower value for low-memory systems. 0 disables. | `100000`
`init.dev-init` | init with dev data (1 account with balance) instead of file import | None
`init.dev-init-address` | string                                                                           Address of dev-account. Leave empty to use the dev-wallet. | None
`init.dev-init-blocknum` | uint                                                                            Number of preinit blocks. Must exist in ancient database. | None
`init.dev-max-code-size` | uint                                                                            Max code size for dev accounts | None
`init.download-path` | string                                                                              path to save temp downloaded file | `/tmp/`
`init.download-poll` | duration                                                                            how long to wait between polling attempts | `1m0s`
`init.empty` | init with empty state | None
`init.force` | if true: in case database exists init code will be reexecuted and genesis block compared to database | None
`init.genesis-json-file` | string                                                                          path for genesis json file | None
`init.import-file` | string                                                                                path for json data to import | None
`init.import-wasm` | if set, import the wasm directory when downloading a database (contains executable code - only use with highly trusted source) | None
`init.latest` | string                                                                                     if set, searches for the latest snapshot of the given kind (accepted values: "archive" | "pruned" | "genesis") | None
`init.latest-base` | string                                                                                base url used when searching for the latest | `https://snapshot.arbitrum.foundation/`
`init.prune` | string                                                                                      pruning for a given use: "full" for full nodes serving RPC requests, or "validator" for validators | None
`init.prune-bloom-size` | uint                                                                             the amount of memory in megabytes to use for the pruning bloom filter (higher values prune better) | `2048`
`init.prune-threads` | int                                                                                 the number of threads to use when pruning | `10`
`init.prune-trie-clean-cache` | int                                                                        amount of memory in megabytes to cache unchanged state trie nodes with when traversing state database during pruning | `600`
`init.rebuild-local-wasm` | string                                                                         rebuild local wasm database on boot if needed (otherwise-will be done lazily). Three modes are supported  "auto"- (enabled by default) if any previous rebuilding attempt was successful then rebuilding is disabled else continues to rebuild, "force"- force rebuilding which would commence rebuilding despite the status of previous attempts, "false"- do not rebuild on startup (default "auto") | None
`init.recreate-missing-state-from` | uint                                                                  block number to start recreating missing states from (0 = disabled) | None
`init.reorg-to-batch` | int                                                                                rolls back the blockchain to a specified batch number | `-1`
`init.reorg-to-block-batch` | int                                                                          rolls back the blockchain to the first batch at or before a given block number | `-1`
`init.reorg-to-message-batch` | int                                                                        rolls back the blockchain to the first batch at or before a given message index | `-1`
`init.then-quit` | quit after init is done | None
`init.url` | string                                                                                        url to download initialization data - will poll if download fails | None
`init.validate-checksum` | if true: validate the checksum after downloading the snapshot | `true`
`ipc.path` | string                                                                                        Requested location to place the IPC endpoint. An empty path disables IPC. | None
`log-level` | string                                                                                       log level, valid values are CRIT, ERROR, WARN, INFO, DEBUG, TRACE | `INFO`
`log-type` | string                                                                                        log type (plaintext or json) | `plaintext`
`metrics` | enable metrics | None
`metrics-server.addr` | string                                                                             metrics server address | `127.0.0.1`
`metrics-server.port` | int                                                                                metrics server port | `6070`
`metrics-server.update-interval` | duration                                                                metrics server update interval | `3s`
`node.batch-poster.check-batch-correctness` | setting this to true will run the batch against an inbox multiplexer and verifies that it produces the correct set of messages | `true`
`node.batch-poster.compression-level` | int                                                                batch compression level | `11`
`node.batch-poster.dangerous.allow-posting-first-batch-when-sequencer-message-count-mismatch` | allow posting the first batch even if sequence number doesn't match chain (useful after force-inclusion) | None
`node.batch-poster.das-retention-period` | duration                                                        In AnyTrust mode, the period which DASes are requested to retain the stored batches. | `360h0m0s`
`node.batch-poster.data-poster.allocate-mempool-balance` | if true, don't put transactions in the mempool that spend a total greater than the batch poster's balance | `true`
`node.batch-poster.data-poster.blob-tx-replacement-times` | durationSlice                                  comma-separated list of durations since first posting a blob transaction to attempt a replace-by-fee | `[5m0s,10m0s,30m0s,1h0m0s,4h0m0s,8h0m0s,16h0m0s,22h0m0s]`
`node.batch-poster.data-poster.dangerous.clear-dbstorage` | clear database storage | None
`node.batch-poster.data-poster.disable-new-tx` | disable posting new transactions, data poster will still keep confirming existing batches | None
`node.batch-poster.data-poster.elapsed-time-base` | duration                                               unit to measure the time elapsed since creation of transaction used for maximum fee cap calculation | `10m0s`
`node.batch-poster.data-poster.elapsed-time-importance` | float                                            weight given to the units of time elapsed used for maximum fee cap calculation | `10`
`node.batch-poster.data-poster.external-signer.address` | string                                           external signer address | None
`node.batch-poster.data-poster.external-signer.client-cert` | string                                       rpc client cert | None
`node.batch-poster.data-poster.external-signer.client-private-key` | string                                rpc client private key | None
`node.batch-poster.data-poster.external-signer.insecure-skip-verify` | skip TLS certificate verification | None
`node.batch-poster.data-poster.external-signer.method` | string                                            external signer method | `eth_signTransaction`
`node.batch-poster.data-poster.external-signer.root-ca` | string                                           external signer root CA | None
`node.batch-poster.data-poster.external-signer.url` | string                                               external signer url | None
`node.batch-poster.data-poster.legacy-storage-encoding` | encodes items in a legacy way (as it was before dropping generics) | None
`node.batch-poster.data-poster.max-blob-tx-tip-cap-gwei` | float                                           the maximum tip cap to post EIP-4844 blob carrying transactions at | `1`
`node.batch-poster.data-poster.max-fee-bid-multiple-bips` | uint                                           the maximum multiple of the current price to bid for a transaction's fees (may be exceeded due to min rbf increase, 0 = unlimited) | `100000`
`node.batch-poster.data-poster.max-fee-cap-formula` | string                                               mathematical formula to calculate maximum fee cap gwei the result of which would be float64. This expression is expected to be evaluated please refer https://github.com/Knetic/govaluate/blob/master/MANUAL.md to find all available mathematical operators. Currently available variables to construct the formula are BacklogOfBatches, UrgencyGWei, ElapsedTime, ElapsedTimeBase, ElapsedTimeImportance, and TargetPriceGWei (default "((BacklogOfBatches * UrgencyGWei) ** 2) + ((ElapsedTime/ElapsedTimeBase) ** 2) * ElapsedTimeImportance + TargetPriceGWei") | None
`node.batch-poster.data-poster.max-mempool-transactions` | uint                                            the maximum number of transactions to have queued in the mempool at once (0 = unlimited) | `18`
`node.batch-poster.data-poster.max-mempool-weight` | uint                                                  the maximum number of weight (weight = min(1, tx.blobs)) to have queued in the mempool at once (0 = unlimited) | `18`
`node.batch-poster.data-poster.max-queued-transactions` | int                                              the maximum number of unconfirmed transactions to track at once (0 = unlimited) | None
`node.batch-poster.data-poster.max-tip-cap-gwei` | float                                                   the maximum tip cap to post transactions at | `1.2`
`node.batch-poster.data-poster.min-blob-tx-tip-cap-gwei` | float                                           the minimum tip cap to post EIP-4844 blob carrying transactions at | `1`
`node.batch-poster.data-poster.min-tip-cap-gwei` | float                                                   the minimum tip cap to post transactions at | `0.05`
`node.batch-poster.data-poster.nonce-rbf-soft-confs` | uint                                                the maximum probable reorg depth, used to determine when a transaction will no longer likely need replaced-by-fee | `1`
`node.batch-poster.data-poster.redis-signer.dangerous.disable-signature-verification` | disable message signature verification | None
`node.batch-poster.data-poster.redis-signer.fallback-verification-key` | string                            a fallback key used for message verification | None
`node.batch-poster.data-poster.redis-signer.signing-key` | string                                          a 32-byte (64-character) hex string used to sign messages, or a path to a file containing it | None
`node.batch-poster.data-poster.replacement-times` | durationSlice                                          comma-separated list of durations since first posting to attempt a replace-by-fee | `[5m0s,10m0s,20m0s,30m0s,1h0m0s,2h0m0s,4h0m0s,6h0m0s,8h0m0s,12h0m0s,16h0m0s,18h0m0s,20h0m0s,22h0m0s]`
`node.batch-poster.data-poster.target-price-gwei` | float                                                  the target price to use for maximum fee cap calculation | `60`
`node.batch-poster.data-poster.urgency-gwei` | float                                                       the urgency to use for maximum fee cap calculation | `2`
`node.batch-poster.data-poster.use-db-storage` | uses database storage when enabled | `true`
`node.batch-poster.data-poster.use-noop-storage` | uses noop storage, it doesn't store anything | None
`node.batch-poster.data-poster.wait-for-l1-finality` | only treat a transaction as confirmed after L1 finality has been achieved (recommended) | `true`
`node.batch-poster.delay-buffer-threshold-margin` | uint                                                   the number of blocks to post the batch before reaching the delay buffer threshold | `25`
`node.batch-poster.disable-dap-fallback-store-data-on-chain` | If unable to batch to DA provider, disable fallback storing data on chain | None
`node.batch-poster.enable` | enable posting batches to l1 | None
`node.batch-poster.error-delay` | duration                                                                 how long to delay after error posting batch | `10s`
`node.batch-poster.extra-batch-gas` | uint                                                                 use this much more gas than estimation says is necessary to post batches | `50000`
`node.batch-poster.gas-estimate-base-fee-multiple-bips` | uint                                             for gas estimation, use this multiple of the basefee (measured in basis points) as the max fee per gas | `15000`
`node.batch-poster.gas-refunder-address` | string                                                          The gas refunder contract address (optional) | None
`node.batch-poster.ignore-blob-price` | if the parent chain supports 4844 blobs and ignore-blob-price is true, post 4844 blobs even if it's not price efficient | None
`node.batch-poster.l1-block-bound` | string                                                                only post messages to batches when they're within the max future block/timestamp as of this L1 block tag ("safe", "finalized", "latest", or "ignore" to ignore this check) | None
`node.batch-poster.l1-block-bound-bypass` | duration                                                       post batches even if not within the layer 1 future bounds if we're within this margin of the max delay | `1h0m0s`
`node.batch-poster.max-4844-batch-size` | int                                                              maximum estimated compressed 4844 blob enabled batch size | `388144`
`node.batch-poster.max-delay` | duration                                                                   maximum batch posting delay | `1h0m0s`
`node.batch-poster.max-empty-batch-delay` | duration                                                       maximum empty batch posting delay, batch poster will only be able to post an empty batch if this time period building a batch has passed | `72h0m0s`
`node.batch-poster.max-size` | int                                                                         maximum estimated compressed batch size | `100000`
`node.batch-poster.parent-chain-wallet.account` | string                                                   account to use | `is first account in keystore`
`node.batch-poster.parent-chain-wallet.only-create-key` | if true, creates new key then exits | None
`node.batch-poster.parent-chain-wallet.password` | string                                                  wallet passphrase | `PASSWORD_NOT_SET`
`node.batch-poster.parent-chain-wallet.pathname` | string                                                  pathname for wallet | `batch-poster-wallet`
`node.batch-poster.parent-chain-wallet.private-key` | string                                               private key for wallet | None
`node.batch-poster.poll-interval` | duration                                                               how long to wait after no batches are ready to be posted before checking again | `10s`
`node.batch-poster.post-4844-blobs` | if the parent chain supports 4844 blobs and they're well priced, post EIP-4844 blobs | None
`node.batch-poster.redis-lock.background-lock` | should node always try grabing lock in background | None
`node.batch-poster.redis-lock.enable` | if false, always treat this as locked and don't write the lock to redis | `true`
`node.batch-poster.redis-lock.key` | string                                                                key for lock | None
`node.batch-poster.redis-lock.lockout-duration` | duration                                                 how long lock is held | `1m0s`
`node.batch-poster.redis-lock.my-id` | string                                                              this node's id prefix when acquiring the lock (optional) | None
`node.batch-poster.redis-lock.refresh-duration` | duration                                                 how long between consecutive calls to redis | `10s`
`node.batch-poster.redis-url` | string                                                                     if non-empty, the Redis URL to store queued transactions in | None
`node.batch-poster.reorg-resistance-margin` | duration                                                     do not post batch if its within this duration from layer 1 minimum bounds. Requires l1-block-bound option not be set to "ignore" | `10m0s`
`node.batch-poster.use-access-lists` | post batches with access lists to reduce gas usage (disabled for L3s) | `true`
`node.batch-poster.wait-for-max-delay` | wait for the max batch delay, even if the batch is full | None
`node.block-metadata-fetcher.api-blocks-limit` | uint                                                      maximum number of blocks allowed to be queried for blockMetadata per arb_getRawBlockMetadata query. This should be set lesser than or equal to the limit on the api provider side (default 100) | None
`node.block-metadata-fetcher.enable` | enable syncing blockMetadata using a bulk blockMetadata api. If the source doesn't have the missing blockMetadata, we keep retyring in every sync-interval (default=5mins) duration | None
`node.block-metadata-fetcher.source.arg-log-limit` | uint                                                  limit size of arguments in log entries | `2048`
`node.block-metadata-fetcher.source.connection-wait` | duration                                            how long to wait for initial connection | None
`node.block-metadata-fetcher.source.jwtsecret` | string                                                    path to file with jwtsecret for validation - ignored if url is self or self-auth | None
`node.block-metadata-fetcher.source.retries` | uint                                                        number of retries in case of failure(0 mean one attempt) | `3`
`node.block-metadata-fetcher.source.retry-delay` | duration                                                delay between retries | None
`node.block-metadata-fetcher.source.retry-errors` | string                                                 Errors matching this regular expression are automatically retried | `websocket: close.*|dial tcp .*|.*i/o timeout|.*connection reset by peer|.*connection refused`
`node.block-metadata-fetcher.source.timeout` | duration                                                    per-response timeout (0-disabled) | None
`node.block-metadata-fetcher.source.url` | string                                                          url of server, use self for loopback websocket, self-auth for loopback with authentication | `self-auth`
`node.block-metadata-fetcher.source.websocket-message-size-limit` | int                                    websocket message size limit used by the RPC client. 0 means no limit | `268435456`
`node.block-metadata-fetcher.sync-interval` | duration                                                     interval at which blockMetadata are synced regularly | `5m0s`
`node.block-validator.batch-cache-limit` | uint32                                                          limit number of old batches to keep in block-validator | `20`
`node.block-validator.block-inputs-file-path` | string                                                     directory to write block validation inputs files | `./target/validation_inputs`
`node.block-validator.current-module-root` | string                                                        current wasm module root ('current' read from chain, 'latest' from machines/latest dir, or provide hash) | `current`
`node.block-validator.dangerous.reset-block-validation` | resets block-by-block validation, starting again at genesis | None
`node.block-validator.enable` | enable block-by-block validation | None
`node.block-validator.failure-is-fatal` | failing a validation is treated as a fatal error | `true`
`node.block-validator.forward-blocks` | uint                                                               prepare entries for up to that many blocks ahead of validation (stores batch-copy per block) | `128`
`node.block-validator.memory-free-limit` | string                                                          minimum free-memory limit after reaching which the blockvalidator pauses validation. Enabled by default as 1GB, to disable provide empty string | `default`
`node.block-validator.pending-upgrade-module-root` | string                                                pending upgrade wasm module root to additionally validate (hash, 'latest' or empty) | `latest`
`node.block-validator.prerecorded-blocks` | uint                                                           record that many blocks ahead of validation (larger footprint) | `20`
`node.block-validator.recording-iter-limit` | uint                                                         limit on block recordings sent per iteration | `20`
`node.block-validator.redis-validation-client-config.create-streams` | create redis streams if it does not exist | `true`
`node.block-validator.redis-validation-client-config.name` | string                                        validation client name | `redis validation client`
`node.block-validator.redis-validation-client-config.producer-config.check-result-interval` | duration     interval in which producer checks pending messages whether consumer processing them is inactive | `5s`
`node.block-validator.redis-validation-client-config.producer-config.request-timeout` | duration           timeout after which the message in redis stream is considered as errored, this prevents workers from working on wrong requests indefinitely | `3h0m0s`
`node.block-validator.redis-validation-client-config.redis-url` | string                                   redis url | None
`node.block-validator.redis-validation-client-config.room` | int32                                         validation client room | `2`
`node.block-validator.redis-validation-client-config.stream-prefix` | string                               prefix for stream name | None
`node.block-validator.redis-validation-client-config.stylus-archs` | strings                               archs required for stylus workers | `[wavm]`
`node.block-validator.validation-poll` | duration                                                          poll time to check validations | `1s`
`node.block-validator.validation-server-configs-list` | string                                             array of execution rpc configs given as a json string. time duration should be supplied in number indicating nanoseconds | `default`
`node.block-validator.validation-server.arg-log-limit` | uint                                              limit size of arguments in log entries | `2048`
`node.block-validator.validation-server.connection-wait` | duration                                        how long to wait for initial connection | None
`node.block-validator.validation-server.jwtsecret` | string                                                path to file with jwtsecret for validation - ignored if url is self or self-auth | None
`node.block-validator.validation-server.retries` | uint                                                    number of retries in case of failure(0 mean one attempt) | `3`
`node.block-validator.validation-server.retry-delay` | duration                                            delay between retries | None
`node.block-validator.validation-server.retry-errors` | string                                             Errors matching this regular expression are automatically retried | `websocket: close.*|dial tcp .*|.*i/o timeout|.*connection reset by peer|.*connection refused`
`node.block-validator.validation-server.timeout` | duration                                                per-response timeout (0-disabled) | None
`node.block-validator.validation-server.url` | string                                                      url of server, use self for loopback websocket, self-auth for loopback with authentication | `self-auth`
`node.block-validator.validation-server.websocket-message-size-limit` | int                                websocket message size limit used by the RPC client. 0 means no limit | `268435456`
`node.bold.api` | enable api | None
`node.bold.api-db-path` | string                                                                           bold api db path | `bold-api-db`
`node.bold.api-host` | string                                                                              bold api host | `127.0.0.1`
`node.bold.api-port` | uint16                                                                              bold api port | `9393`
`node.bold.assertion-confirming-interval` | duration                                                       confirm assertion interval | `1m0s`
`node.bold.assertion-posting-interval` | duration                                                          assertion posting interval | `15m0s`
`node.bold.assertion-scanning-interval` | duration                                                         scan assertion interval | `1m0s`
`node.bold.auto-deposit` | auto-deposit stake token whenever making a move in BoLD that does not have enough stake token balance | `true`
`node.bold.auto-increase-allowance` | auto-increase spending allowance of the stake token by the rollup and challenge manager contracts | `true`
`node.bold.check-staker-switch-interval` | duration                                                        how often to check if staker can switch to bold | `1m0s`
`node.bold.delegated-staking.custom-withdrawal-address` | string                                           enable a custom withdrawal address for staking on the rollup contract, useful for delegated stakers | None
`node.bold.delegated-staking.enable` | enable delegated staking by having the validator call newStake on startup | None
`node.bold.enable` | enable bold challenge protocol | None
`node.bold.enable-fast-confirmation` | enable fast confirmation | None
`node.bold.max-get-log-blocks` | int                                                                       maximum size for chunk of blocks when using get logs rpc | `5000`
`node.bold.minimum-gap-to-parent-assertion` | duration                                                     minimum duration to wait since the parent assertion was created to post a new assertion | `1m0s`
`node.bold.rpc-block-number` | string                                                                      define the block number to use for reading data onchain, either latest, safe, or finalized | `finalized`
`node.bold.start-validation-from-staked` | assume staked nodes are valid | `true`
`node.bold.state-provider-config.check-batch-finality` | check batch finality | `true`
`node.bold.state-provider-config.machine-leaves-cache-path` | string                                       path to machine cache | `machine-hashes-cache`
`node.bold.state-provider-config.validator-name` | string                                                  name identifier for cosmetic purposes | `default-validator`
`node.bold.strategy` | string                                                                              define the bold validator staker strategy, either watchtower, defensive, stakeLatest, or makeNodes | `Watchtower`
`node.bold.track-challenge-parent-assertion-hashes` | strings                                              only track challenges/edges with these parent assertion hashes | None
`node.dangerous.disable-blob-reader` | DANGEROUS! disables the EIP-4844 blob reader, which is necessary to read batches | None
`node.dangerous.no-l1-listener` | DANGEROUS! disables listening to L1. To be used in test nodes only | None
`node.dangerous.no-sequencer-coordinator` | DANGEROUS! allows sequencing without sequencer-coordinator | None
`node.data-availability.enable` | enable Anytrust Data Availability mode | None
`node.data-availability.panic-on-error` | whether the Data Availability Service should fail immediately on errors (not recommended) | None
`node.data-availability.parent-chain-connection-attempts` | int                                            parent chain RPC connection attempts (spaced out at least 1 second per attempt, 0 to retry infinitely), only used in standalone daserver; when running as part of a node that node's parent chain configuration is used | `15`
`node.data-availability.parent-chain-node-url` | string                                                    URL for parent chain node, only used in standalone daserver; when running as part of a node that node's L1 configuration is used | None
`node.data-availability.request-timeout` | duration                                                        Data Availability Service timeout duration for Store requests | `5s`
`node.data-availability.rest-aggregator.enable` | enable retrieval of sequencer batch data from a list of remote REST endpoints; if other DAS storage types are enabled, this mode is used as a fallback | None
`node.data-availability.rest-aggregator.max-per-endpoint-stats` | int                                      number of stats entries (latency and success rate) to keep for each REST endpoint; controls whether strategy is faster or slower to respond to changing conditions | `20`
`node.data-availability.rest-aggregator.online-url-list` | string                                          a URL to a list of URLs of REST das endpoints that is checked at startup; additive with the url option | None
`node.data-availability.rest-aggregator.online-url-list-fetch-interval` | duration                         time interval to periodically fetch url list from online-url-list | `1h0m0s`
`node.data-availability.rest-aggregator.simple-explore-exploit-strategy.exploit-iterations` | uint32       number of consecutive GetByHash calls to the aggregator where each call will cause it to select from REST endpoints in order of best latency and success rate, before switching to explore mode | `1000`
`node.data-availability.rest-aggregator.simple-explore-exploit-strategy.explore-iterations` | uint32       number of consecutive GetByHash calls to the aggregator where each call will cause it to randomly select from REST endpoints until one returns successfully, before switching to exploit mode | `20`
`node.data-availability.rest-aggregator.strategy` | string                                                 strategy to use to determine order and parallelism of calling REST endpoint URLs; valid options are 'simple-explore-exploit' | `simple-explore-exploit`
`node.data-availability.rest-aggregator.strategy-update-interval` | duration                               how frequently to update the strategy with endpoint latency and error rate data | `10s`
`node.data-availability.rest-aggregator.sync-to-storage.delay-on-error` | duration                         time to wait if encountered an error before retrying | `1s`
`node.data-availability.rest-aggregator.sync-to-storage.eager` | eagerly sync batch data to this DAS's storage from the rest endpoints, using L1 as the index of batch data hashes; otherwise only sync lazily | None
`node.data-availability.rest-aggregator.sync-to-storage.eager-lower-bound-block` | uint                    when eagerly syncing, start indexing forward from this L1 block. Only used if there is no sync state | None
`node.data-availability.rest-aggregator.sync-to-storage.ignore-write-errors` | log only on failures to write when syncing; otherwise treat it as an error | `true`
`node.data-availability.rest-aggregator.sync-to-storage.parent-chain-blocks-per-read` | uint               when eagerly syncing, max l1 blocks to read per poll | `100`
`node.data-availability.rest-aggregator.sync-to-storage.retention-period` | duration                       period to request storage to retain synced data | `360h0m0s`
`node.data-availability.rest-aggregator.sync-to-storage.state-dir` | string                                directory to store the sync state in, ie the block number currently synced up to, so that we don't sync from scratch each time | None
`node.data-availability.rest-aggregator.sync-to-storage.sync-expired-data` | sync even data that is expired; needed for mirror configuration | `true`
`node.data-availability.rest-aggregator.urls` | strings                                                    list of URLs including 'http://' or 'https://' prefixes and port numbers to REST DAS endpoints; additive with the online-url-list option | None
`node.data-availability.rest-aggregator.wait-before-try-next` | duration                                   time to wait until trying the next set of REST endpoints while waiting for a response; the next set of REST endpoints is determined by the strategy selected | `2s`
`node.data-availability.rpc-aggregator.assumed-honest` | int                                               Number of assumed honest backends (H). If there are N backends, K=N+1-H valid responses are required to consider an Store request to be successful. | None
`node.data-availability.rpc-aggregator.backends` | backendConfigList                                       JSON RPC backend configuration. This can be specified on the command line as a JSON array, eg: [{"url": "...", "pubkey": "..."},...], or as a JSON array in the config file. | `null`
`node.data-availability.rpc-aggregator.enable` | enable storage of sequencer batch data from a list of RPC endpoints; this should only be used by the batch poster and not in combination with other DAS storage types | None
`node.data-availability.rpc-aggregator.enable-chunked-store` | enable data to be sent to DAS in chunks instead of all at once | `true`
`node.data-availability.rpc-aggregator.max-store-chunk-body-size` | int                                    maximum HTTP POST body size to use for individual batch chunks, including JSON RPC overhead and an estimated overhead of 512B of headers | `524288`
`node.data-availability.sequencer-inbox-address` | string                                                  parent chain address of SequencerInbox contract | None
`node.delayed-sequencer.enable` | enable delayed sequencer | None
`node.delayed-sequencer.finalize-distance` | int                                                           how many blocks in the past L1 block is considered final (ignored when using Merge finality) | `20`
`node.delayed-sequencer.require-full-finality` | whether to wait for full finality before sequencing delayed messages | None
`node.delayed-sequencer.rescan-interval` | duration                                                        frequency to rescan for new delayed messages (the parent chain reader's poll-interval config is more important than this) | `1s`
`node.delayed-sequencer.use-merge-finality` | whether to use The Merge's notion of finality before sequencing delayed messages | `true`
`node.feed.input.enable-compression` | enable per message deflate compression support | `true`
`node.feed.input.reconnect-initial-backoff` | duration                                                     initial duration to wait before reconnect | `1s`
`node.feed.input.reconnect-maximum-backoff` | duration                                                     maximum duration to wait before reconnect | `1m4s`
`node.feed.input.require-chain-id` | require chain id to be present on connect | None
`node.feed.input.require-feed-version` | require feed version to be present on connect | None
`node.feed.input.secondary-url` | strings                                                                  list of secondary URLs of sequencer feed source. Would be started in the order they appear in the list when primary feeds fails | None
`node.feed.input.timeout` | duration                                                                       duration to wait before timing out connection to sequencer feed | `20s`
`node.feed.input.url` | strings                                                                            list of primary URLs of sequencer feed source | None
`node.feed.input.verify.accept-sequencer` | accept verified message from sequencer | `true`
`node.feed.input.verify.allowed-addresses` | strings                                                       a list of allowed addresses | None
`node.feed.input.verify.dangerous.accept-missing` | accept empty as valid signature | `true`
`node.feed.output.addr` | string                                                                           address to bind the relay feed output to | None
`node.feed.output.backlog.segment-limit` | int                                                             the maximum number of messages each segment within the backlog can contain | `240`
`node.feed.output.client-delay` | duration                                                                 delay the first messages sent to each client by this amount | None
`node.feed.output.client-timeout` | duration                                                               duration to wait before timing out connections to client | `15s`
`node.feed.output.connection-limits.enable` | enable broadcaster per-client connection limiting | None
`node.feed.output.connection-limits.per-ip-limit` | int                                                    limit clients, as identified by IPv4/v6 address, to this many connections to this relay | `5`
`node.feed.output.connection-limits.per-ipv6-cidr-48-limit` | int                                          limit ipv6 clients, as identified by IPv6 address masked with /48, to this many connections to this relay | `20`
`node.feed.output.connection-limits.per-ipv6-cidr-64-limit` | int                                          limit ipv6 clients, as identified by IPv6 address masked with /64, to this many connections to this relay | `10`
`node.feed.output.connection-limits.reconnect-cooldown-period` | duration                                  time to wait after a relay client disconnects before the disconnect is registered with respect to the limit for this client | None
`node.feed.output.disable-signing` | don't sign feed messages | `true`
`node.feed.output.enable` | enable broadcaster | None
`node.feed.output.enable-compression` | enable per message deflate compression support | None
`node.feed.output.handshake-timeout` | duration                                                            duration to wait before timing out HTTP to WS upgrade | `1s`
`node.feed.output.limit-catchup` | only supply catchup buffer if requested sequence number is reasonable | None
`node.feed.output.log-connect` | log every client connect | None
`node.feed.output.log-disconnect` | log every client disconnect | None
`node.feed.output.max-catchup` | int                                                                       the maximum size of the catchup buffer (-1 means unlimited) | `-1`
`node.feed.output.max-send-queue` | int                                                                    maximum number of messages allowed to accumulate before client is disconnected | `4096`
`node.feed.output.ping` | duration                                                                         duration for ping interval | `5s`
`node.feed.output.port` | string                                                                           port to bind the relay feed output to | `9642`
`node.feed.output.queue` | int                                                                             queue size for HTTP to WS upgrade | `100`
`node.feed.output.read-timeout` | duration                                                                 duration to wait before timing out reading data (i.e. pings) from clients | `1s`
`node.feed.output.require-compression` | require clients to use compression | None
`node.feed.output.require-version` | don't connect if client version not present | None
`node.feed.output.signed` | sign broadcast messages | None
`node.feed.output.workers` | int                                                                           number of threads to reserve for HTTP to WS upgrade | `100`
`node.feed.output.write-timeout` | duration                                                                duration to wait before timing out writing data to clients | `2s`
`node.inbox-reader.check-delay` | duration                                                                 the maximum time to wait between inbox checks (if not enough new blocks are found) | `1m0s`
`node.inbox-reader.default-blocks-to-read` | uint                                                          the default number of blocks to read at once (will vary based on traffic by default) | `100`
`node.inbox-reader.delay-blocks` | uint                                                                    number of latest blocks to ignore to reduce reorgs | None
`node.inbox-reader.max-blocks-to-read` | uint                                                              if adjust-blocks-to-read is enabled, the maximum number of blocks to read at once | `2000`
`node.inbox-reader.min-blocks-to-read` | uint                                                              the minimum number of blocks to read at once (when caught up lowers load on L1) | `1`
`node.inbox-reader.read-mode` | string                                                                     mode to only read latest or safe or finalized L1 blocks. Enabling safe or finalized disables feed input and output. Defaults to latest. Takes string input, valid strings- latest, safe, finalized | `latest`
`node.inbox-reader.target-messages-read` | uint                                                            if adjust-blocks-to-read is enabled, the target number of messages to read at once | `500`
`node.maintenance.lock.background-lock` | should node always try grabing lock in background | None
`node.maintenance.lock.enable` | if false, always treat this as locked and don't write the lock to redis | `true`
`node.maintenance.lock.key` | string                                                                       key for lock | None
`node.maintenance.lock.lockout-duration` | duration                                                        how long lock is held | `1m0s`
`node.maintenance.lock.my-id` | string                                                                     this node's id prefix when acquiring the lock (optional) | None
`node.maintenance.lock.refresh-duration` | duration                                                        how long between consecutive calls to redis | `10s`
`node.maintenance.time-of-day` | string                                                                    UTC 24-hour time of day to run maintenance at (e.g. 15:00) | None
`node.maintenance.triggerable` | maintenance is triggerable via rpc | None
`node.message-pruner.enable` | enable message pruning | `true`
`node.message-pruner.min-batches-left` | uint                                                              min number of batches not pruned | `1000`
`node.message-pruner.prune-interval` | duration                                                            interval for running message pruner | `1m0s`
`node.parent-chain-reader.dangerous.wait-for-tx-approval-safe-poll` | duration                             Dangerous! only meant to be used by system tests | None
`node.parent-chain-reader.enable` | enable reader connection | `true`
`node.parent-chain-reader.old-header-timeout` | duration                                                   warns if the latest l1 block is at least this old | `5m0s`
`node.parent-chain-reader.poll-interval` | duration                                                        interval when polling endpoint | `15s`
`node.parent-chain-reader.poll-only` | do not attempt to subscribe to header events | None
`node.parent-chain-reader.poll-timeout` | duration                                                         timeout when polling endpoint | `5s`
`node.parent-chain-reader.subscribe-err-interval` | duration                                               interval for subscribe error | `5m0s`
`node.parent-chain-reader.tx-timeout` | duration                                                           timeout when waiting for a transaction | `5m0s`
`node.parent-chain-reader.use-finality-data` | use l1 data about finalized/safe blocks | `true`
`node.seq-coordinator.block-metadata-duration` | duration | `240h0m0s`
`node.seq-coordinator.chosen-healthcheck-addr` | string                                                    if non-empty, launch an HTTP service binding to this address that returns status code 200 when chosen and 503 otherwise | None
`node.seq-coordinator.delete-finalized-msgs` | enable deleting of finalized messages from redis | `true`
`node.seq-coordinator.enable` | enable sequence coordinator | None
`node.seq-coordinator.handoff-timeout` | duration                                                          the maximum amount of time to spend waiting for another sequencer to accept the lockout when handing it off on shutdown or db compaction | `30s`
`node.seq-coordinator.lockout-duration` | duration | `1m0s`
`node.seq-coordinator.lockout-spare` | duration | `30s`
`node.seq-coordinator.msg-per-poll` | uint                                                                 will only be marked as wanting the lockout if not too far behind | `2000`
`node.seq-coordinator.my-url` | string                                                                     url for this sequencer if it is the chosen | `<?INVALID-URL?>`
`node.seq-coordinator.new-redis-url` | string                                                              switch to the new Redis URL to coordinate via | None
`node.seq-coordinator.redis-url` | string                                                                  the Redis URL to coordinate via | None
`node.seq-coordinator.release-retries` | int                                                               the number of times to retry releasing the wants lockout and chosen one status on shutdown | `4`
`node.seq-coordinator.retry-interval` | duration | `50ms`
`node.seq-coordinator.safe-shutdown-delay` | duration                                                      if non-zero will add delay after transferring control | `5s`
`node.seq-coordinator.seq-num-duration` | duration | `240h0m0s`
`node.seq-coordinator.signer.ecdsa.accept-sequencer` | accept verified message from sequencer | `true`
`node.seq-coordinator.signer.ecdsa.allowed-addresses` | strings                                            a list of allowed addresses | None
`node.seq-coordinator.signer.ecdsa.dangerous.accept-missing` | accept empty as valid signature | `true`
`node.seq-coordinator.signer.symmetric-fallback` | if to fall back to symmetric hmac | None
`node.seq-coordinator.signer.symmetric-sign` | if to sign with symmetric hmac | None
`node.seq-coordinator.signer.symmetric.dangerous.disable-signature-verification` | disable message signature verification | None
`node.seq-coordinator.signer.symmetric.fallback-verification-key` | string                                 a fallback key used for message verification | None
`node.seq-coordinator.signer.symmetric.signing-key` | string                                               a 32-byte (64-character) hex string used to sign messages, or a path to a file containing it | None
`node.seq-coordinator.update-interval` | duration | `250ms`
`node.sequencer` | enable sequencer | None
`node.staker.confirmation-blocks` | int                                                                    confirmation blocks | `12`
`node.staker.contract-wallet-address` | string                                                             validator smart contract wallet public address | None
`node.staker.dangerous.ignore-rollup-wasm-module-root` | DANGEROUS! make assertions even when the wasm module root is wrong | None
`node.staker.dangerous.without-block-validator` | DANGEROUS! allows running an L1 validator without a block validator | None
`node.staker.data-poster.allocate-mempool-balance` | if true, don't put transactions in the mempool that spend a total greater than the batch poster's balance | `true`
`node.staker.data-poster.blob-tx-replacement-times` | durationSlice                                        comma-separated list of durations since first posting a blob transaction to attempt a replace-by-fee | `[5m0s,10m0s,30m0s,1h0m0s,4h0m0s,8h0m0s,16h0m0s,22h0m0s]`
`node.staker.data-poster.dangerous.clear-dbstorage` | clear database storage | None
`node.staker.data-poster.disable-new-tx` | disable posting new transactions, data poster will still keep confirming existing batches | None
`node.staker.data-poster.elapsed-time-base` | duration                                                     unit to measure the time elapsed since creation of transaction used for maximum fee cap calculation | `10m0s`
`node.staker.data-poster.elapsed-time-importance` | float                                                  weight given to the units of time elapsed used for maximum fee cap calculation | `10`
`node.staker.data-poster.external-signer.address` | string                                                 external signer address | None
`node.staker.data-poster.external-signer.client-cert` | string                                             rpc client cert | None
`node.staker.data-poster.external-signer.client-private-key` | string                                      rpc client private key | None
`node.staker.data-poster.external-signer.insecure-skip-verify` | skip TLS certificate verification | None
`node.staker.data-poster.external-signer.method` | string                                                  external signer method | `eth_signTransaction`
`node.staker.data-poster.external-signer.root-ca` | string                                                 external signer root CA | None
`node.staker.data-poster.external-signer.url` | string                                                     external signer url | None
`node.staker.data-poster.legacy-storage-encoding` | encodes items in a legacy way (as it was before dropping generics) | None
`node.staker.data-poster.max-blob-tx-tip-cap-gwei` | float                                                 the maximum tip cap to post EIP-4844 blob carrying transactions at | `1`
`node.staker.data-poster.max-fee-bid-multiple-bips` | uint                                                 the maximum multiple of the current price to bid for a transaction's fees (may be exceeded due to min rbf increase, 0 = unlimited) | `100000`
`node.staker.data-poster.max-fee-cap-formula` | string                                                     mathematical formula to calculate maximum fee cap gwei the result of which would be float64. This expression is expected to be evaluated please refer https://github.com/Knetic/govaluate/blob/master/MANUAL.md to find all available mathematical operators. Currently available variables to construct the formula are BacklogOfBatches, UrgencyGWei, ElapsedTime, ElapsedTimeBase, ElapsedTimeImportance, and TargetPriceGWei (default "((BacklogOfBatches * UrgencyGWei) ** 2) + ((ElapsedTime/ElapsedTimeBase) ** 2) * ElapsedTimeImportance + TargetPriceGWei") | None
`node.staker.data-poster.max-mempool-transactions` | uint                                                  the maximum number of transactions to have queued in the mempool at once (0 = unlimited) | `1`
`node.staker.data-poster.max-mempool-weight` | uint                                                        the maximum number of weight (weight = min(1, tx.blobs)) to have queued in the mempool at once (0 = unlimited) | `1`
`node.staker.data-poster.max-queued-transactions` | int                                                    the maximum number of unconfirmed transactions to track at once (0 = unlimited) | None
`node.staker.data-poster.max-tip-cap-gwei` | float                                                         the maximum tip cap to post transactions at | `1.2`
`node.staker.data-poster.min-blob-tx-tip-cap-gwei` | float                                                 the minimum tip cap to post EIP-4844 blob carrying transactions at | `1`
`node.staker.data-poster.min-tip-cap-gwei` | float                                                         the minimum tip cap to post transactions at | `0.05`
`node.staker.data-poster.nonce-rbf-soft-confs` | uint                                                      the maximum probable reorg depth, used to determine when a transaction will no longer likely need replaced-by-fee | `1`
`node.staker.data-poster.redis-signer.dangerous.disable-signature-verification` | disable message signature verification | None
`node.staker.data-poster.redis-signer.fallback-verification-key` | string                                  a fallback key used for message verification | None
`node.staker.data-poster.redis-signer.signing-key` | string                                                a 32-byte (64-character) hex string used to sign messages, or a path to a file containing it | None
`node.staker.data-poster.replacement-times` | durationSlice                                                comma-separated list of durations since first posting to attempt a replace-by-fee | `[5m0s,10m0s,20m0s,30m0s,1h0m0s,2h0m0s,4h0m0s,6h0m0s,8h0m0s,12h0m0s,16h0m0s,18h0m0s,20h0m0s,22h0m0s]`
`node.staker.data-poster.target-price-gwei` | float                                                        the target price to use for maximum fee cap calculation | `60`
`node.staker.data-poster.urgency-gwei` | float                                                             the urgency to use for maximum fee cap calculation | `2`
`node.staker.data-poster.use-db-storage` | uses database storage when enabled | `true`
`node.staker.data-poster.use-noop-storage` | uses noop storage, it doesn't store anything | None
`node.staker.data-poster.wait-for-l1-finality` | only treat a transaction as confirmed after L1 finality has been achieved (recommended) | `true`
`node.staker.disable-challenge` | disable validator challenge | None
`node.staker.enable` | enable validator | `true`
`node.staker.enable-fast-confirmation` | enable fast confirmation | None
`node.staker.extra-gas` | uint                                                                             use this much more gas than estimation says is necessary to post transactions | `50000`
`node.staker.gas-refunder-address` | string                                                                The gas refunder contract address (optional) | None
`node.staker.log-query-batch-size` | uint                                                                  range ro query from eth_getLogs | None
`node.staker.make-assertion-interval` | duration                                                           if configured with the makeNodes strategy, how often to create new assertions (bypassed in case of a dispute) | `1h0m0s`
`node.staker.only-create-wallet-contract` | only create smart wallet contract and exit | None
`node.staker.parent-chain-wallet.account` | string                                                         account to use | `is first account in keystore`
`node.staker.parent-chain-wallet.only-create-key` | if true, creates new key then exits | None
`node.staker.parent-chain-wallet.password` | string                                                        wallet passphrase | `PASSWORD_NOT_SET`
`node.staker.parent-chain-wallet.pathname` | string                                                        pathname for wallet | `validator-wallet`
`node.staker.parent-chain-wallet.private-key` | string                                                     private key for wallet | None
`node.staker.posting-strategy.high-gas-delay-blocks` | int                                                 high gas delay blocks | None
`node.staker.posting-strategy.high-gas-threshold` | float                                                  high gas threshold | None
`node.staker.redis-url` | string                                                                           redis url for L1 validator | None
`node.staker.staker-interval` | duration                                                                   how often the L1 validator should check the status of the L1 rollup and maybe take action with its stake | `1m0s`
`node.staker.start-validation-from-staked` | assume staked nodes are valid | `true`
`node.staker.strategy` | string                                                                            L1 validator strategy, either watchtower, defensive, stakeLatest, or makeNodes | `Watchtower`
`node.staker.use-smart-contract-wallet` | use a smart contract wallet instead of an EOA address | None
`node.sync-monitor.msg-lag` | duration                                                                     allowed msg lag while still considered in sync | `1s`
`node.transaction-streamer.execute-message-loop-delay` | duration                                          delay when polling calls to execute messages | `100ms`
`node.transaction-streamer.max-broadcaster-queue-size` | int                                               maximum cache of pending broadcaster messages | `50000`
`node.transaction-streamer.max-reorg-resequence-depth` | int                                               maximum number of messages to attempt to resequence on reorg (0 = never resequence, -1 = always resequence) | `1024`
`node.transaction-streamer.track-block-metadata-from` | uint                                               this is the block number starting from which blockmetadata is being tracked in the local disk and is being published to the feed. This is also the starting position for bulk syncing of missing blockmetadata. Setting to zero (default value) disables this | None
`parent-chain.blob-client.authorization` | string                                                          Value to send with the HTTP Authorization: header for Beacon REST requests, must include both scheme and scheme parameters | None
`parent-chain.blob-client.beacon-url` | string                                                             Beacon Chain RPC URL to use for fetching blobs (normally on port 3500) | None
`parent-chain.blob-client.blob-directory` | string                                                         Full path of the directory to save fetched blobs | None
`parent-chain.blob-client.secondary-beacon-url` | string                                                   Backup beacon Chain RPC URL to use for fetching blobs (normally on port 3500) when unable to fetch from primary | None
`parent-chain.connection.arg-log-limit` | uint                                                             limit size of arguments in log entries | `2048`
`parent-chain.connection.connection-wait` | duration                                                       how long to wait for initial connection | `1m0s`
`parent-chain.connection.jwtsecret` | string                                                               path to file with jwtsecret for validation - ignored if url is self or self-auth | None
`parent-chain.connection.retries` | uint                                                                   number of retries in case of failure(0 mean one attempt) | `2`
`parent-chain.connection.retry-delay` | duration                                                           delay between retries | None
`parent-chain.connection.retry-errors` | string                                                            Errors matching this regular expression are automatically retried | None
`parent-chain.connection.timeout` | duration                                                               per-response timeout (0-disabled) | `1m0s`
`parent-chain.connection.url` | string                                                                     url of server, use self for loopback websocket, self-auth for loopback with authentication | None
`parent-chain.connection.websocket-message-size-limit` | int                                               websocket message size limit used by the RPC client. 0 means no limit | `268435456`
`parent-chain.id` | uint                                                                                   if set other than 0, will be used to validate database and L1 connection | None
`persistent.ancient` | string                                                                              directory of ancient where the chain freezer can be opened | None
`persistent.chain` | string                                                                                directory to store chain state | None
`persistent.db-engine` | string                                                                            backing database implementation to use. If set to empty string the database type will be autodetected and if no pre-existing database is found it will default to creating new pebble database ('leveldb', 'pebble' or '' = auto-detect) | None
`persistent.global-config` | string                                                                        directory to store global config | `.arbitrum`
`persistent.handles` | int                                                                                 number of file descriptor handles to use for the database | `512`
`persistent.log-dir` | string                                                                              directory to store log file | None
`persistent.pebble.experimental.block-size` | int                                                          target uncompressed size in bytes of each table block | `4096`
`persistent.pebble.experimental.bytes-per-sync` | int                                                      number of bytes to write to a SSTable before calling Sync on it in the background | `524288`
`persistent.pebble.experimental.compaction-debt-concurrency` | uint                                        controls the threshold of compaction debt at which additional compaction concurrency slots are added. For every multiple of this value in compaction debt bytes, an additional concurrent compaction is added. This works "on top" of l0-compaction-concurrency, so the higher of the count of compaction concurrency slots as determined by the two options is chosen. | `1073741824`
`persistent.pebble.experimental.disable-automatic-compactions` | disables automatic compactions | None
`persistent.pebble.experimental.force-writer-parallelism` | force parallelism in the sstable Writer for the metamorphic tests. Even with the MaxWriterConcurrency option set, pebble only enables parallelism in the sstable Writer if there is enough CPU available, and this option bypasses that. | None
`persistent.pebble.experimental.index-block-size` | int                                                    target uncompressed size in bytes of each index block. When the index block size is larger than this target, two-level indexes are automatically enabled. Setting this option to a large value (such as 2147483647) disables the automatic creation of two-level indexes. | `4096`
`persistent.pebble.experimental.l-base-max-bytes` | int                                                    The maximum number of bytes for LBase. The base level is the level which L0 is compacted into. The base level is determined dynamically based on the existing data in the LSM. The maximum number of bytes for other levels is computed dynamically based on the base level's maximum size. When the maximum number of bytes for a level is exceeded, compaction is requested. | `67108864`
`persistent.pebble.experimental.l0-compaction-concurrency` | int                                           threshold of L0 read-amplification at which compaction concurrency is enabled (if compaction-debt-concurrency was not already exceeded). Every multiple of this value enables another concurrent compaction up to max-concurrent-compactions. | `10`
`persistent.pebble.experimental.l0-compaction-file-threshold` | int                                        count of L0 files necessary to trigger an L0 compaction | `500`
`persistent.pebble.experimental.l0-compaction-threshold` | int                                             amount of L0 read-amplification necessary to trigger an L0 compaction | `4`
`persistent.pebble.experimental.l0-stop-writes-threshold` | int                                            hard limit on L0 read-amplification, computed as the number of L0 sublevels. Writes are stopped when this threshold is reached | `12`
`persistent.pebble.experimental.max-writer-concurrency` | int                                              maximum number of compression workers the compression queue is allowed to use. If max-writer-concurrency > 0, then the Writer will use parallelism, to compress and write blocks to disk. Otherwise, the writer will compress and write blocks to disk synchronously. | None
`persistent.pebble.experimental.mem-table-stop-writes-threshold` | int                                     hard limit on the number of queued of MemTables | `2`
`persistent.pebble.experimental.read-compaction-rate` | AllowedSeeks                                       controls the frequency of read triggered compactions by adjusting AllowedSeeks in manifest.FileMetadata: AllowedSeeks = FileSize / ReadCompactionRate | `16000`
`persistent.pebble.experimental.read-sampling-multiplier` | int                                            a multiplier for the readSamplingPeriod in iterator.maybeSampleRead() to control the frequency of read sampling to trigger a read triggered compaction. A value of -1 prevents sampling and disables read triggered compactions. Geth default is -1. The pebble default is 1 << 4. which gets multiplied with a constant of 1 << 16 to yield 1 << 20 (1MB). | `-1`
`persistent.pebble.experimental.target-byte-deletion-rate` | int                                           rate (in bytes per second) at which sstable file deletions are limited to (under normal circumstances). | None
`persistent.pebble.experimental.target-file-size` | int                                                    target file size for the level 0 | `2097152`
`persistent.pebble.experimental.target-file-size-equal-levels` | if true same target-file-size will be uses for all levels, otherwise target size for layer n = 2 * target size for layer n - 1 | None
`persistent.pebble.experimental.wal-bytes-per-sync` | int                                                  number of bytes to write to a write-ahead log (WAL) before calling Sync on it in the background | None
`persistent.pebble.experimental.wal-dir` | string                                                          absolute path of directory to store write-ahead logs (WALs) in. If empty, WALs will be stored in the same directory as sstables | None
`persistent.pebble.experimental.wal-min-sync-interval` | int                                               minimum duration in microseconds between syncs of the WAL. If WAL syncs are requested faster than this interval, they will be artificially delayed. | None
`persistent.pebble.max-concurrent-compactions` | int                                                       maximum number of concurrent compactions | `10`
`persistent.pebble.sync-mode` | if true sync mode is used (data needs to be written to WAL before the write is marked as completed) | None
`pprof` | enable pprof | None
`pprof-cfg.addr` | string                                                                                  pprof server address | `127.0.0.1`
`pprof-cfg.port` | int                                                                                     pprof server port | `6071`
`rpc.batch-request-limit` | int                                                                            the maximum number of requests in a batch (0 means no limit) | `1000`
`rpc.max-batch-response-size` | int                                                                        the maximum response size for a JSON-RPC request measured in bytes (0 means no limit) | `10000000`
`validation.api-auth` | validate is an authenticated API | `true`
`validation.api-public` | validate is a public API | None
`validation.arbitrator.execution-run-timeout` | duration                                                   timeout before discarding execution run | `15m0s`
`validation.arbitrator.execution.cached-challenge-machines` | uint                                         how many machines to store in cache while working on a challenge (should be even) | `4`
`validation.arbitrator.execution.initial-steps` | uint                                                     initial steps between machines | `100000`
`validation.arbitrator.output-path` | string                                                               path to write machines to | `./target/output`
`validation.arbitrator.redis-validation-server-config.buffer-reads` | buffer reads (read next while working) | `true`
`validation.arbitrator.redis-validation-server-config.consumer-config.idletime-to-autoclaim` | duration    After a message spends this amount of time in PEL (Pending Entries List i.e claimed by another consumer but not Acknowledged) it will be allowed to be autoclaimed by other consumers | `5m0s`
`validation.arbitrator.redis-validation-server-config.consumer-config.response-entry-timeout` | duration   timeout for response entry | `1h0m0s`
`validation.arbitrator.redis-validation-server-config.module-roots` | strings                              Supported module root hashes | None
`validation.arbitrator.redis-validation-server-config.redis-url` | string                                  url of redis server | None
`validation.arbitrator.redis-validation-server-config.stream-prefix` | string                              prefix for stream name | None
`validation.arbitrator.redis-validation-server-config.stream-timeout` | duration                           Timeout on polling for existence of redis streams | `10m0s`
`validation.arbitrator.redis-validation-server-config.workers` | int                                       number of validation threads (0 to use number of CPUs) | None
`validation.arbitrator.workers` | int                                                                      number of concurrent validation threads | None
`validation.jit.cranelift` | use Cranelift instead of LLVM when validating blocks using the jit-accelerated block validator | `true`
`validation.jit.max-execution-time` | duration                                                             if execution time used by a jit wasm exceeds this limit, a rpc error is returned | `10m0s`
`validation.jit.wasm-memory-usage-limit` | int                                                             if memory used by a jit wasm exceeds this limit, a warning is logged | `4294967296`
`validation.jit.workers` | int                                                                             number of concurrent validation threads | None
`validation.use-jit` | use jit for validation | `true`
`validation.wasm.allowed-wasm-module-roots` | strings                                                      list of WASM module roots or mahcine base paths to match against on-chain WasmModuleRoot | None
`validation.wasm.enable-wasmroots-check` | enable check for compatibility of on-chain WASM module root with node | `true`
`validation.wasm.root-path` | string                                                                       path to machine folders, each containing wasm files (machine.wavm.br, replay.wasm) | None
`ws.addr` | string                                                                                         WS-RPC server listening interface | None
`ws.api` | strings                                                                                         APIs offered over the WS-RPC interface | `[net,web3,eth,arb]`
`ws.expose-all` | expose private api via websocket | None
`ws.origins` | strings                                                                                     Origins from which to accept websockets requests | None
`ws.port` | int                                                                                            WS-RPC server listening port | `8548`
`ws.rpcprefix` | string                                                                                    WS path path prefix on which JSON-RPC is served. Use '/' to serve on all paths | None

## Notes
