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
Chart defaults are for launching an arbitrum one node. At a minimum, you must provide a parent chain url and an init method(downloading from snapshot is in the example).

```console
helm install <my-release> offchainlabs/nitro \
--set configmap.data.parent-chain.connection.url=<ETH_RPC_URL> \
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

| Name                                         | Description                                                  | Value                                                       |
| -------------------------------------------- | ------------------------------------------------------------ | ----------------------------------------------------------- |
| `replicaCount`                               | Number of replicas to deploy                                 | `1`                                                         |
| `image.repository`                           | Docker image repository                                      | `offchainlabs/nitro-node`                                   |
| `image.pullPolicy`                           | Docker image pull policy                                     | `Always`                                                    |
| `image.tag`                                  | Docker image tag. Overrides the chart appVersion.            | `""`                                                        |
| `imagePullSecrets`                           | Docker registry pull secret names as an array                | `[]`                                                        |
| `nameOverride`                               | String to partially override nitro.fullname                  | `""`                                                        |
| `fullnameOverride`                           | String to fully override nitro.fullname                      | `""`                                                        |
| `commandOverride`                            | Command override for the nitro container                     | `{}`                                                        |
| `livenessProbe`                              | Liveness probe configuration                                 | `{}`                                                        |
| `readinessProbe`                             | Readiness probe configuration                                | `{}`                                                        |
| `startupProbe.enabled`                       | Enable built in startup probe                                | `true`                                                      |
| `startupProbe.failureThreshold`              | Number of failures before pod is considered unhealthy        | `2419200`                                                   |
| `startupProbe.periodSeconds`                 | Number of seconds between startup probes                     | `1`                                                         |
| `updateStrategy.type`                        | Update strategy type                                         | `RollingUpdate`                                             |
| `updateStrategy.rollingUpdate.partition`     | Partition to update                                          | `0`                                                         |
| `persistence.enabled`                        | Enable persistence                                           | `true`                                                      |
| `persistence.size`                           | Size of the persistent volume claim                          | `500Gi`                                                     |
| `persistence.storageClassName`               | Storage class of the persistent volume claim                 | `nil`                                                       |
| `serviceMonitor.enabled`                     | Enable service monitor CRD for prometheus operator           | `false`                                                     |
| `serviceMonitor.portName`                    | Name of the port to monitor                                  | `metrics`                                                   |
| `serviceMonitor.path`                        | Path to monitor                                              | `/debug/metrics/prometheus`                                 |
| `serviceMonitor.interval`                    | Interval to monitor                                          | `5s`                                                        |
| `serviceMonitor.relabelings`                 | Add relabelings for the metrics being scraped                | `{}`                                                        |
| `perReplicaService.enabled`                  | Enable a service for each sts replica                        | `false`                                                     |
| `jwtSecret.enabled`                          | Enable a jwt secret for use with the stateless validator     | `false`                                                     |
| `jwtSecret.value`                            | Value of the jwt secret for use with the stateless validator | `""`                                                        |
| `auth.enabled`                               | Enable auth for the stateless validator                      | `false`                                                     |
| `pdb.enabled`                                | Enable pod disruption budget                                 | `false`                                                     |
| `pdb.minAvailable`                           | Minimum number of pods available                             | `75%`                                                       |
| `pdb.maxUnavailable`                         | Maximum number of pods unavailable                           | `""`                                                        |
| `serviceAccount.create`                      | Create a service account                                     | `true`                                                      |
| `serviceAccount.annotations`                 | Annotations for the service account                          | `{}`                                                        |
| `serviceAccount.name`                        | Name of the service account                                  | `""`                                                        |
| `podAnnotations`                             | Annotations for the pod                                      | `{}`                                                        |
| `podSecurityContext.fsGroup`                 | Group id for the pod                                         | `1000`                                                      |
| `securityContext`                            | Security context for the container                           | `{}`                                                        |
| `service.type`                               | Service type                                                 | `ClusterIP`                                                 |
| `resources`                                  | Resources for the container                                  | `{}`                                                        |
| `nodeSelector`                               | Node selector for the pod                                    | `{}`                                                        |
| `tolerations`                                | Tolerations for the pod                                      | `[]`                                                        |
| `affinity`                                   | Affinity for the pod                                         | `{}`                                                        |
| `additionalVolumeClaims`                     | Additional volume claims for the pod                         | `[]`                                                        |
| `extraPorts`                                 | Additional ports for the pod                                 | `[]`                                                        |
| `configmap.enabled`                          | Enable a configmap for the nitro container                   | `true`                                                      |
| `configmap.data`                             | See Configuration Options for the full list of options       |                                                             |
| `configmap.data.conf.env-prefix`             | Environment variable prefix                                  | `NITRO`                                                     |
| `configmap.data.http.addr`                   | Address to bind http service to                              | `0.0.0.0`                                                   |
| `configmap.data.http.api`                    | List of apis to enable                                       | `["arb","personal","eth","net","web3","txpool","arbdebug"]` |
| `configmap.data.http.corsdomain`             | CORS domain                                                  | `*`                                                         |
| `configmap.data.http.port`                   | Port to bind http service to                                 | `8547`                                                      |
| `configmap.data.http.rpcprefix`              | Prefix for rpc calls                                         | `/rpc`                                                      |
| `configmap.data.http.vhosts`                 | Vhosts to allow                                              | `*`                                                         |
| `configmap.data.parent-chain.id`             | ID of the parent chain                                       | `1`                                                         |
| `configmap.data.parent-chain.connection.url` | URL of the parent chain                                      | `""`                                                        |
| `configmap.data.chain.id`                    | ID of the chain                                              | `42161`                                                     |
| `configmap.data.log-type`                    | Type of log                                                  | `json`                                                      |
| `configmap.data.metrics`                     | Enable metrics                                               | `false`                                                     |
| `configmap.data.metrics-server.addr`         | Address to bind metrics server to                            | `0.0.0.0`                                                   |
| `configmap.data.metrics-server.port`         | Port to bind metrics server to                               | `6070`                                                      |
| `configmap.data.persistent.chain`            | Path to persistent chain data                                | `/home/user/data/`                                          |
| `configmap.data.ws.addr`                     | Address to bind ws service to                                | `0.0.0.0`                                                   |
| `configmap.data.ws.api`                      | List of apis to enable                                       | `["net","web3","eth","arb"]`                                |
| `configmap.data.ws.port`                     | Port to bind ws service to                                   | `8548`                                                      |
| `configmap.data.ws.rpcprefix`                | Prefix for rpc calls                                         | `/ws`                                                       |

### Stateless Validator

| Name                                                       | Description                                              | Value                       |
| ---------------------------------------------------------- | -------------------------------------------------------- | --------------------------- |
| `validator.image.repository`                               | Docker image repository                                  | `""`                        |
| `validator.image.tag`                                      | Docker image tag                                         | `""`                        |
| `validator.enabled`                                        | Enable the stateless validator                           | `false`                     |
| `validator.configmap.data.auth.addr`                       | Address to bind auth service to                          | `0.0.0.0`                   |
| `validator.configmap.data.auth.port`                       | Port to bind auth service to                             | `8549`                      |
| `validator.configmap.data.auth.origins`                    | Origins to allow to access auth service                  | `*`                         |
| `validator.configmap.data.auth.jwtsecret`                  | Path to jwt secret for auth service                      | `/secrets/jwtsecret`        |
| `validator.configmap.data.metrics`                         | Enable metrics                                           | `false`                     |
| `validator.configmap.data.metrics-server.addr`             | Address to bind metrics server to                        | `0.0.0.0`                   |
| `validator.configmap.data.metrics-server.port`             | Port to bind metrics server to                           | `6070`                      |
| `validator.extraArgs`                                      | Extra arguments for the validator container              | `[]`                        |
| `validator.serviceMonitor.enabled`                         | Enable service monitor CRD for prometheus operator       | `false`                     |
| `validator.serviceMonitor.portName`                        | Name of the port to monitor                              | `metrics`                   |
| `validator.serviceMonitor.path`                            | Path to monitor                                          | `/debug/metrics/prometheus` |
| `validator.serviceMonitor.interval`                        | Interval to monitor                                      | `5s`                        |
| `validator.serviceMonitor.relabelings`                     | Add relabelings for the metrics being scraped            | `{}`                        |
| `validator.statefulset.useConfigmap`                       | Use the configmap for the validator container            | `true`                      |
| `validator.statefulset.auth.enabled`                       | Enable the auth service for the validator statefulset    | `true`                      |
| `validator.statefulset.auth.port`                          | Port to bind auth service to                             | `8549`                      |
| `validator.statefulset.extraLabels`                        | Extra labels for the liveness probe                      | `{}`                        |
| `validator.statefulset.livenessProbe.enabled`              | Enable the liveness probe for the validator statefulset  | `true`                      |
| `validator.statefulset.livenessProbe.tcpSocket.port`       | Port to probe                                            | `auth`                      |
| `validator.statefulset.livenessProbe.initialDelaySeconds`  | Initial delay for the liveness probe                     | `30`                        |
| `validator.statefulset.livenessProbe.periodSeconds`        | Period for the liveness probe                            | `10`                        |
| `validator.statefulset.pdb.enabled`                        | Enable pod disruption budget                             | `false`                     |
| `validator.statefulset.pdb.minAvailable`                   | Minimum number of pods available                         | `75%`                       |
| `validator.statefulset.pdb.maxUnavailable`                 | Maximum number of pods unavailable                       | `""`                        |
| `validator.statefulset.readinessProbe.enabled`             | Enable the readiness probe for the validator statefulset | `true`                      |
| `validator.statefulset.readinessProbe.tcpSocket.port`      | Port to probe                                            | `auth`                      |
| `validator.statefulset.readinessProbe.initialDelaySeconds` | Initial delay for the readiness probe                    | `3`                         |
| `validator.statefulset.readinessProbe.periodSeconds`       | Period for the readiness probe                           | `3`                         |
| `validator.statefulset.startupProbe.enabled`               | Enable the startup probe for the validator statefulset   | `false`                     |
| `validator.statefulset.resources`                          | Resources for the validator container                    | `{}`                        |
| `validator.statefulset.extraEnv`                           | Extra environment variables for the validator container  | `{}`                        |
| `validator.statefulset.extraPorts`                         | Additional ports for the stateless validator pod         | `[]`                        |
| `validator.statefulset.podAnnotations`                     | Annotations for the stateless validator pod              | `{}`                        |

## Configuration Options
The following table lists the exhaustive configurable parameters that can be applied as part of the configmap (nested under `configmap.data`) or as standalone cli flags.

Option | Description | Default
--- | --- | ---
`auth.addr` | string                                                                                AUTH-RPC server listening interface | `127.0.0.1`
`auth.api` | strings                                                                                APIs offered over the AUTH-RPC interface | `[validation]`
`auth.jwtsecret` | string                                                                           Path to file holding JWT secret (32B hex) | None
`auth.origins` | strings                                                                            Origins from which to accept AUTH requests | `[localhost]`
`auth.port` | int                                                                                   AUTH-RPC server listening port | `8549`
`blocks-reexecutor.blocks-per-thread` | uint                                                        minimum number of blocks to execute per thread. When mode is random this acts as the size of random block range sample | `10000`
`blocks-reexecutor.enable` | enables re-execution of a range of blocks against historic state | None
`blocks-reexecutor.end-block` | uint                                                                last block number of the block range for re-execution | None
`blocks-reexecutor.mode` | string                                                                   mode to run the blocks-reexecutor on. Valid modes full and random. full - execute all the blocks in the given range. random - execute a random sample range of blocks with in a given range | `random`
`blocks-reexecutor.room` | int                                                                      number of threads to parallelize blocks re-execution | `10`
`blocks-reexecutor.start-block` | uint                                                              first block number of the block range for re-execution | None
`chain.dev-wallet.account` | string                                                                 account to use | `is first account in keystore`
`chain.dev-wallet.only-create-key` | if true, creates new key then exits | None
`chain.dev-wallet.password` | string                                                                wallet passphrase | `PASSWORD_NOT_SET`
`chain.dev-wallet.pathname` | string                                                                pathname for wallet | None
`chain.dev-wallet.private-key` | string                                                             private key for wallet | None
`chain.id` | uint                                                                                   L2 chain ID (determines Arbitrum network) | None
`chain.info-files` | strings                                                                        L2 chain info json files | None
`chain.info-ipfs-download-path` | string                                                            path to save temp downloaded file | `/tmp/`
`chain.info-ipfs-url` | string                                                                      url to download chain info file | None
`chain.info-json` | string                                                                          L2 chain info in json string format | None
`chain.name` | string                                                                               L2 chain name (determines Arbitrum network) | None
`conf.dump` | print out currently active configuration file | None
`conf.env-prefix` | string                                                                          environment variables with given prefix will be loaded as configuration values | None
`conf.file` | strings                                                                               name of configuration file | None
`conf.reload-interval` | duration                                                                   how often to reload configuration (0=disable periodic reloading) | None
`conf.s3.access-key` | string                                                                       S3 access key | None
`conf.s3.bucket` | string                                                                           S3 bucket | None
`conf.s3.object-key` | string                                                                       S3 object key | None
`conf.s3.region` | string                                                                           S3 region | None
`conf.s3.secret-key` | string                                                                       S3 secret key | None
`conf.string` | string                                                                              configuration as JSON string | None
`execution.caching.archive` | retain past block state | None
`execution.caching.block-age` | duration                                                            minimum age of recent blocks to keep in memory | `30m0s`
`execution.caching.block-count` | uint                                                              minimum number of recent blocks to keep in memory | `128`
`execution.caching.database-cache` | int                                                            amount of memory in megabytes to cache database contents with | `2048`
`execution.caching.max-amount-of-gas-to-skip-state-saving` | uint                                   maximum amount of gas in blocks to skip saving state to Persistent storage (archive node only) -- warning: this option seems to cause issues | None
`execution.caching.max-number-of-blocks-to-skip-state-saving` | uint32                              maximum number of blocks to skip state saving to persistent storage (archive node only) -- warning: this option seems to cause issues | None
`execution.caching.snapshot-cache` | int                                                            amount of memory in megabytes to cache state snapshots with | `400`
`execution.caching.snapshot-restore-gas-limit` | uint                                               maximum gas rolled back to recover snapshot | `300000000000`
`execution.caching.trie-clean-cache` | int                                                          amount of memory in megabytes to cache unchanged state trie nodes with | `600`
`execution.caching.trie-dirty-cache` | int                                                          amount of memory in megabytes to cache state diffs against disk with (larger cache lowers database growth) | `1024`
`execution.caching.trie-time-limit` | duration                                                      maximum block processing time before trie is written to hard-disk | `1h0m0s`
`execution.dangerous.reorg-to-block` | int                                                          DANGEROUS! forces a reorg to an old block height. To be used for testing only. -1 to disable | `-1`
`execution.enable-prefetch-block` | enable prefetching of blocks | `true`
`execution.forwarder.connection-timeout` | duration                                                 total time to wait before cancelling connection | `30s`
`execution.forwarder.idle-connection-timeout` | duration                                            time until idle connections are closed | `15s`
`execution.forwarder.max-idle-connections` | int                                                    maximum number of idle connections to keep open | `1`
`execution.forwarder.redis-url` | string                                                            the Redis URL to recomend target via | None
`execution.forwarder.retry-interval` | duration                                                     minimal time between update retries | `100ms`
`execution.forwarder.update-interval` | duration                                                    forwarding target update interval | `1s`
`execution.forwarding-target` | string                                                              transaction forwarding target URL, or "null" to disable forwarding (iff not sequencer) | None
`execution.parent-chain-reader.dangerous.wait-for-tx-approval-safe-poll` | duration                 Dangerous! only meant to be used by system tests | None
`execution.parent-chain-reader.enable` | enable reader connection | `true`
`execution.parent-chain-reader.old-header-timeout` | duration                                       warns if the latest l1 block is at least this old | `5m0s`
`execution.parent-chain-reader.poll-interval` | duration                                            interval when polling endpoint | `15s`
`execution.parent-chain-reader.poll-only` | do not attempt to subscribe to header events | None
`execution.parent-chain-reader.subscribe-err-interval` | duration                                   interval for subscribe error | `5m0s`
`execution.parent-chain-reader.tx-timeout` | duration                                               timeout when waiting for a transaction | `5m0s`
`execution.parent-chain-reader.use-finality-data` | use l1 data about finalized/safe blocks | `true`
`execution.recording-database.trie-clean-cache` | int                                               like trie-clean-cache for the separate, recording database (used for validation) | `16`
`execution.recording-database.trie-dirty-cache` | int                                               like trie-dirty-cache for the separate, recording database (used for validation) | `1024`
`execution.rpc.allow-method` | strings                                                              list of whitelisted rpc methods | None
`execution.rpc.arbdebug.block-range-bound` | uint                                                   bounds the number of blocks arbdebug calls may return | `256`
`execution.rpc.arbdebug.timeout-queue-bound` | uint                                                 bounds the length of timeout queues arbdebug calls may return | `512`
`execution.rpc.bloom-bits-blocks` | uint                                                            number of blocks a single bloom bit section vector holds | `16384`
`execution.rpc.bloom-confirms` | uint                                                               number of confirmation blocks before a bloom section is considered final | `256`
`execution.rpc.classic-redirect` | string                                                           url to redirect classic requests, use "error:[CODE:]MESSAGE" to return specified error instead of redirecting | None
`execution.rpc.classic-redirect-timeout` | duration                                                 timeout for forwarded classic requests, where 0 = no timeout | None
`execution.rpc.evm-timeout` | duration                                                              timeout used for eth_call (0=infinite) | `5s`
`execution.rpc.feehistory-max-block-count` | uint                                                   max number of blocks a fee history request may cover | `1024`
`execution.rpc.filter-log-cache-size` | int                                                         log filter system maximum number of cached blocks | `32`
`execution.rpc.filter-timeout` | duration                                                           log filter system maximum time filters stay active | `5m0s`
`execution.rpc.gas-cap` | uint                                                                      cap on computation gas that can be used in eth_call/estimateGas (0=infinite) | `50000000`
`execution.rpc.max-recreate-state-depth` | int                                                      maximum depth for recreating state, measured in l2 gas (0=don't recreate state, -1=infinite, -2=use default value for archive or non-archive node (whichever is configured)) | `-2`
`execution.rpc.tx-allow-unprotected` | allow transactions that aren't EIP-155 replay protected to be submitted over the RPC | `true`
`execution.rpc.tx-fee-cap` | float                                                                  cap on transaction fee (in ether) that can be sent via the RPC APIs (0 = no cap) | `1`
`execution.secondary-forwarding-target` | strings                                                   secondary transaction forwarding target URL | None
`execution.sequencer.enable` | act and post to l1 as sequencer | None
`execution.sequencer.forwarder.connection-timeout` | duration                                       total time to wait before cancelling connection | `30s`
`execution.sequencer.forwarder.idle-connection-timeout` | duration                                  time until idle connections are closed | `1m0s`
`execution.sequencer.forwarder.max-idle-connections` | int                                          maximum number of idle connections to keep open | `100`
`execution.sequencer.forwarder.redis-url` | string                                                  the Redis URL to recomend target via | None
`execution.sequencer.forwarder.retry-interval` | duration                                           minimal time between update retries | `100ms`
`execution.sequencer.forwarder.update-interval` | duration                                          forwarding target update interval | `1s`
`execution.sequencer.max-acceptable-timestamp-delta` | duration                                     maximum acceptable time difference between the local time and the latest L1 block's timestamp | `1h0m0s`
`execution.sequencer.max-block-speed` | duration                                                    minimum delay between blocks (sets a maximum speed of block production) | `250ms`
`execution.sequencer.max-revert-gas-reject` | uint                                                  maximum gas executed in a revert for the sequencer to reject the transaction instead of posting it (anti-DOS) | `31000`
`execution.sequencer.max-tx-data-size` | int                                                        maximum transaction size the sequencer will accept | `95000`
`execution.sequencer.nonce-cache-size` | int                                                        size of the tx sender nonce cache | `1024`
`execution.sequencer.nonce-failure-cache-expiry` | duration                                         maximum amount of time to wait for a predecessor before rejecting a tx with nonce too high | `1s`
`execution.sequencer.nonce-failure-cache-size` | int                                                number of transactions with too high of a nonce to keep in memory while waiting for their predecessor | `1024`
`execution.sequencer.queue-size` | int                                                              size of the pending tx queue | `1024`
`execution.sequencer.queue-timeout` | duration                                                      maximum amount of time transaction can wait in queue | `12s`
`execution.sequencer.sender-whitelist` | string                                                     comma separated whitelist of authorized senders (if empty, everyone is allowed) | None
`execution.tx-lookup-limit` | uint                                                                  retain the ability to lookup transactions by hash for the past N blocks (0 = all blocks) | `126230400`
`execution.tx-pre-checker.required-state-age` | int                                                 how long ago should the storage conditions from eth_SendRawTransactionConditional be true, 0 = don't check old state | `2`
`execution.tx-pre-checker.required-state-max-blocks` | uint                                         maximum number of blocks to look back while looking for the <required-state-age> seconds old state, 0 = don't limit the search | `4`
`execution.tx-pre-checker.strictness` | uint                                                        how strict to be when checking txs before forwarding them. 0 = accept anything, 10 = should never reject anything that'd succeed, 20 = likely won't reject anything that'd succeed, 30 = full validation which may reject txs that would succeed | None
`file-logging.buf-size` | int                                                                       size of intermediate log records buffer | `512`
`file-logging.compress` | enable compression of old log files | `true`
`file-logging.enable` | enable logging to file | `true`
`file-logging.file` | string                                                                        path to log file | `nitro.log`
`file-logging.local-time` | if true: local time will be used in old log filename timestamps | None
`file-logging.max-age` | int                                                                        maximum number of days to retain old log files based on the timestamp encoded in their filename (0 = no limit) | None
`file-logging.max-backups` | int                                                                    maximum number of old log files to retain (0 = no limit) | `20`
`file-logging.max-size` | int                                                                       log file size in Mb that will trigger log file rotation (0 = trigger disabled) | `5`
`graphql.corsdomain` | strings                                                                      Comma separated list of domains from which to accept cross origin requests (browser enforced) | None
`graphql.enable` | Enable graphql endpoint on the rpc endpoint | None
`graphql.vhosts` | strings                                                                          Comma separated list of virtual hostnames from which to accept requests (server enforced). Accepts '*' wildcard | `[localhost]`
`http.addr` | string                                                                                HTTP-RPC server listening interface | None
`http.api` | strings                                                                                APIs offered over the HTTP-RPC interface | `[net,web3,eth,arb]`
`http.corsdomain` | strings                                                                         Comma separated list of domains from which to accept cross origin requests (browser enforced) | None
`http.port` | int                                                                                   HTTP-RPC server listening port | `8547`
`http.rpcprefix` | string                                                                           HTTP path path prefix on which JSON-RPC is served. Use '/' to serve on all paths | None
`http.server-timeouts.idle-timeout` | duration                                                      the maximum amount of time to wait for the next request when keep-alives are enabled (http.Server.IdleTimeout) | `2m0s`
`http.server-timeouts.read-header-timeout` | duration                                               the amount of time allowed to read the request headers (http.Server.ReadHeaderTimeout) | `30s`
`http.server-timeouts.read-timeout` | duration                                                      the maximum duration for reading the entire request (http.Server.ReadTimeout) | `30s`
`http.server-timeouts.write-timeout` | duration                                                     the maximum duration before timing out writes of the response (http.Server.WriteTimeout) | `30s`
`http.vhosts` | strings                                                                             Comma separated list of virtual hostnames from which to accept requests (server enforced). Accepts '*' wildcard | `[localhost]`
`init.accounts-per-sync` | uint                                                                     during init - sync database every X accounts. Lower value for low-memory systems. 0 disables. | `100000`
`init.dev-init` | init with dev data (1 account with balance) instead of file import | None
`init.dev-init-address` | string                                                                    Address of dev-account. Leave empty to use the dev-wallet. | None
`init.dev-init-blocknum` | uint                                                                     Number of preinit blocks. Must exist in ancient database. | None
`init.download-path` | string                                                                       path to save temp downloaded file | `/tmp/`
`init.download-poll` | duration                                                                     how long to wait between polling attempts | `1m0s`
`init.empty` | init with empty state | None
`init.force` | if true: in case database exists init code will be reexecuted and genesis block compared to database | None
`init.import-file` | string                                                                         path for json data to import | None
`init.prune` | string                                                                               pruning for a given use: "full" for full nodes serving RPC requests, or "validator" for validators | None
`init.prune-bloom-size` | uint                                                                      the amount of memory in megabytes to use for the pruning bloom filter (higher values prune better) | `2048`
`init.recreate-missing-state-from` | uint                                                           block number to start recreating missing states from (0 = disabled) | None
`init.reset-to-message` | int                                                                       forces a reset to an old message height. Also set max-reorg-resequence-depth=0 to force re-reading messages | `-1`
`init.then-quit` | quit after init is done | None
`init.url` | string                                                                                 url to download initializtion data - will poll if download fails | None
`ipc.path` | string                                                                                 Requested location to place the IPC endpoint. An empty path disables IPC. | None
`log-level` | int                                                                                   log level | `3`
`log-type` | string                                                                                 log type (plaintext or json) | `plaintext`
`metrics` | enable metrics | None
`metrics-server.addr` | string                                                                      metrics server address | `127.0.0.1`
`metrics-server.port` | int                                                                         metrics server port | `6070`
`metrics-server.update-interval` | duration                                                         metrics server update interval | `3s`
`node.batch-poster.compression-level` | int                                                         batch compression level | `11`
`node.batch-poster.das-retention-period` | duration                                                 In AnyTrust mode, the period which DASes are requested to retain the stored batches. | `360h0m0s`
`node.batch-poster.data-poster.allocate-mempool-balance` | if true, don't put transactions in the mempool that spend a total greater than the batch poster's balance | `true`
`node.batch-poster.data-poster.dangerous.clear-dbstorage` | clear database storage | None
`node.batch-poster.data-poster.elapsed-time-base` | duration                                        unit to measure the time elapsed since creation of transaction used for maximum fee cap calculation | `10m0s`
`node.batch-poster.data-poster.elapsed-time-importance` | float                                     weight given to the units of time elapsed used for maximum fee cap calculation | `10`
`node.batch-poster.data-poster.external-signer.address` | string                                    external signer address | None
`node.batch-poster.data-poster.external-signer.client-cert` | string                                rpc client cert | None
`node.batch-poster.data-poster.external-signer.client-private-key` | string                         rpc client private key | None
`node.batch-poster.data-poster.external-signer.method` | string                                     external signer method | `eth_signTransaction`
`node.batch-poster.data-poster.external-signer.root-ca` | string                                    external signer root CA | None
`node.batch-poster.data-poster.external-signer.url` | string                                        external signer url | None
`node.batch-poster.data-poster.legacy-storage-encoding` | encodes items in a legacy way (as it was before dropping generics) | None
`node.batch-poster.data-poster.max-fee-cap-formula` | string                                        mathematical formula to calculate maximum fee cap gwei the result of which would be float64. This expression is expected to be evaluated please refer https://github.com/Knetic/govaluate/blob/master/MANUAL.md to find all available mathematical operators. Currently available variables to construct the formula are BacklogOfBatches, UrgencyGWei, ElapsedTime, ElapsedTimeBase, ElapsedTimeImportance, and TargetPriceGWei (default "((BacklogOfBatches * UrgencyGWei) ** 2) + ((ElapsedTime/ElapsedTimeBase) ** 2) * ElapsedTimeImportance + TargetPriceGWei") | None
`node.batch-poster.data-poster.max-mempool-transactions` | uint                                     the maximum number of transactions to have queued in the mempool at once (0 = unlimited) | `20`
`node.batch-poster.data-poster.max-queued-transactions` | int                                       the maximum number of unconfirmed transactions to track at once (0 = unlimited) | None
`node.batch-poster.data-poster.max-tip-cap-gwei` | float                                            the maximum tip cap to post transactions at | `5`
`node.batch-poster.data-poster.min-fee-cap-gwei` | float                                            the minimum fee cap to post transactions at | None
`node.batch-poster.data-poster.min-tip-cap-gwei` | float                                            the minimum tip cap to post transactions at | `0.05`
`node.batch-poster.data-poster.nonce-rbf-soft-confs` | uint                                         the maximum probable reorg depth, used to determine when a transaction will no longer likely need replaced-by-fee | `1`
`node.batch-poster.data-poster.redis-signer.dangerous.disable-signature-verification` | disable message signature verification | None
`node.batch-poster.data-poster.redis-signer.fallback-verification-key` | string                     a fallback key used for message verification | None
`node.batch-poster.data-poster.redis-signer.signing-key` | string                                   a 32-byte (64-character) hex string used to sign messages, or a path to a file containing it | None
`node.batch-poster.data-poster.replacement-times` | string                                          comma-separated list of durations since first posting to attempt a replace-by-fee | `5m,10m,20m,30m,1h,2h,4h,6h,8h,12h,16h,18h,20h,22h`
`node.batch-poster.data-poster.target-price-gwei` | float                                           the target price to use for maximum fee cap calculation | `60`
`node.batch-poster.data-poster.urgency-gwei` | float                                                the urgency to use for maximum fee cap calculation | `2`
`node.batch-poster.data-poster.use-db-storage` | uses database storage when enabled | `true`
`node.batch-poster.data-poster.use-noop-storage` | uses noop storage, it doesn't store anything | None
`node.batch-poster.data-poster.wait-for-l1-finality` | only treat a transaction as confirmed after L1 finality has been achieved (recommended) | `true`
`node.batch-poster.disable-das-fallback-store-data-on-chain` | If unable to batch to DAS, disable fallback storing data on chain | None
`node.batch-poster.enable` | enable posting batches to l1 | None
`node.batch-poster.error-delay` | duration                                                          how long to delay after error posting batch | `10s`
`node.batch-poster.extra-batch-gas` | uint                                                          use this much more gas than estimation says is necessary to post batches | `50000`
`node.batch-poster.gas-refunder-address` | string                                                   The gas refunder contract address (optional) | None
`node.batch-poster.ignore-blob-price` | if the parent chain supports 4844 blobs and ignore-blob-price is true, post 4844 blobs even if it's not price efficient | None
`node.batch-poster.l1-block-bound` | string                                                         only post messages to batches when they're within the max future block/timestamp as of this L1 block tag ("safe", "finalized", "latest", or "ignore" to ignore this check) | None
`node.batch-poster.l1-block-bound-bypass` | duration                                                post batches even if not within the layer 1 future bounds if we're within this margin of the max delay | `1h0m0s`
`node.batch-poster.max-4844-batch-size` | int                                                       maximum 4844 blob enabled batch size | `779288`
`node.batch-poster.max-delay` | duration                                                            maximum batch posting delay | `1h0m0s`
`node.batch-poster.max-size` | int                                                                  maximum batch size | `100000`
`node.batch-poster.parent-chain-wallet.account` | string                                            account to use | `is first account in keystore`
`node.batch-poster.parent-chain-wallet.only-create-key` | if true, creates new key then exits | None
`node.batch-poster.parent-chain-wallet.password` | string                                           wallet passphrase | `PASSWORD_NOT_SET`
`node.batch-poster.parent-chain-wallet.pathname` | string                                           pathname for wallet | `batch-poster-wallet`
`node.batch-poster.parent-chain-wallet.private-key` | string                                        private key for wallet | None
`node.batch-poster.poll-interval` | duration                                                        how long to wait after no batches are ready to be posted before checking again | `10s`
`node.batch-poster.post-4844-blobs` | if the parent chain supports 4844 blobs and they're well priced, post EIP-4844 blobs | None
`node.batch-poster.redis-lock.background-lock` | should node always try grabing lock in background | None
`node.batch-poster.redis-lock.enable` | if false, always treat this as locked and don't write the lock to redis | `true`
`node.batch-poster.redis-lock.key` | string                                                         key for lock | None
`node.batch-poster.redis-lock.lockout-duration` | duration                                          how long lock is held | `1m0s`
`node.batch-poster.redis-lock.my-id` | string                                                       this node's id prefix when acquiring the lock (optional) | None
`node.batch-poster.redis-lock.refresh-duration` | duration                                          how long between consecutive calls to redis | `10s`
`node.batch-poster.redis-url` | string                                                              if non-empty, the Redis URL to store queued transactions in | None
`node.batch-poster.use-access-lists` | post batches with access lists to reduce gas usage (disabled for L3s) | `true`
`node.batch-poster.wait-for-max-delay` | wait for the max batch delay, even if the batch is full | None
`node.blob-client.beacon-chain-url` | string                                                        Beacon Chain url to use for fetching blobs | None
`node.blob-client.blob-directory` | string                                                          Full path of the directory to save fetched blobs | None
`node.block-validator.current-module-root` | string                                                 current wasm module root ('current' read from chain, 'latest' from machines/latest dir, or provide hash) | `current`
`node.block-validator.dangerous.reset-block-validation` | resets block-by-block validation, starting again at genesis | None
`node.block-validator.enable` | enable block-by-block validation | None
`node.block-validator.failure-is-fatal` | failing a validation is treated as a fatal error | `true`
`node.block-validator.forward-blocks` | uint                                                        prepare entries for up to that many blocks ahead of validation (small footprint) | `1024`
`node.block-validator.memory-free-limit` | string                                                   minimum free-memory limit after reaching which the blockvalidator pauses validation. Enabled by default as 1GB, to disable provide empty string | `default`
`node.block-validator.pending-upgrade-module-root` | string                                         pending upgrade wasm module root to additionally validate (hash, 'latest' or empty) | `latest`
`node.block-validator.prerecorded-blocks` | uint                                                    record that many blocks ahead of validation (larger footprint) | `20`
`node.block-validator.validation-poll` | duration                                                   poll time to check validations | `1s`
`node.block-validator.validation-server-configs-list` | string                                      array of validation rpc configs given as a json string. time duration should be supplied in number indicating nanoseconds | `default`
`node.block-validator.validation-server.arg-log-limit` | uint                                       limit size of arguments in log entries | `2048`
`node.block-validator.validation-server.connection-wait` | duration                                 how long to wait for initial connection | None
`node.block-validator.validation-server.jwtsecret` | string                                         path to file with jwtsecret for validation - ignored if url is self or self-auth | None
`node.block-validator.validation-server.retries` | uint                                             number of retries in case of failure(0 mean one attempt) | `3`
`node.block-validator.validation-server.retry-delay` | duration                                     delay between retries | None
`node.block-validator.validation-server.retry-errors` | string                                      Errors matching this regular expression are automatically retried | `websocket: close.*|dial tcp .*|.*i/o timeout|.*connection reset by peer|.*connection refused`
`node.block-validator.validation-server.timeout` | duration                                         per-response timeout (0-disabled) | None
`node.block-validator.validation-server.url` | string                                               url of server, use self for loopback websocket, self-auth for loopback with authentication | `self-auth`
`node.dangerous.no-l1-listener` | DANGEROUS! disables listening to L1. To be used in test nodes only | None
`node.dangerous.no-sequencer-coordinator` | DANGEROUS! allows sequencing without sequencer-coordinator | None
`node.data-availability.enable` | enable Anytrust Data Availability mode | None
`node.data-availability.ipfs-storage.enable` | enable storage/retrieval of sequencer batch data from IPFS | None
`node.data-availability.ipfs-storage.peers` | strings                                               list of IPFS peers to connect to, eg /ip4/1.2.3.4/tcp/12345/p2p/abc...xyz | None
`node.data-availability.ipfs-storage.pin-after-get` | pin sequencer batch data in IPFS | `true`
`node.data-availability.ipfs-storage.pin-percentage` | float                                        percent of sequencer batch data to pin, as a floating point number in the range 0.0 to 100.0 | `100`
`node.data-availability.ipfs-storage.profiles` | string                                             comma separated list of IPFS profiles to use, see https://docs.ipfs.tech/how-to/default-profile | None
`node.data-availability.ipfs-storage.read-timeout` | duration                                       timeout for IPFS reads, since by default it will wait forever. Treat timeout as not found | `1m0s`
`node.data-availability.ipfs-storage.repo-dir` | string                                             directory to use to store the local IPFS repo | None
`node.data-availability.panic-on-error` | whether the Data Availability Service should fail immediately on errors (not recommended) | None
`node.data-availability.parent-chain-connection-attempts` | int                                     parent chain RPC connection attempts (spaced out at least 1 second per attempt, 0 to retry infinitely), only used in standalone daserver; when running as part of a node that node's parent chain configuration is used | `15`
`node.data-availability.parent-chain-node-url` | string                                             URL for parent chain node, only used in standalone daserver; when running as part of a node that node's L1 configuration is used | None
`node.data-availability.request-timeout` | duration                                                 Data Availability Service timeout duration for Store requests | `5s`
`node.data-availability.rest-aggregator.enable` | enable retrieval of sequencer batch data from a list of remote REST endpoints; if other DAS storage types are enabled, this mode is used as a fallback | None
`node.data-availability.rest-aggregator.max-per-endpoint-stats` | int                               number of stats entries (latency and success rate) to keep for each REST endpoint; controls whether strategy is faster or slower to respond to changing conditions | `20`
`node.data-availability.rest-aggregator.online-url-list` | string                                   a URL to a list of URLs of REST das endpoints that is checked at startup; additive with the url option | None
`node.data-availability.rest-aggregator.online-url-list-fetch-interval` | duration                  time interval to periodically fetch url list from online-url-list | `1h0m0s`
`node.data-availability.rest-aggregator.simple-explore-exploit-strategy.exploit-iterations` | int   number of consecutive GetByHash calls to the aggregator where each call will cause it to select from REST endpoints in order of best latency and success rate, before switching to explore mode | `1000`
`node.data-availability.rest-aggregator.simple-explore-exploit-strategy.explore-iterations` | int   number of consecutive GetByHash calls to the aggregator where each call will cause it to randomly select from REST endpoints until one returns successfully, before switching to exploit mode | `20`
`node.data-availability.rest-aggregator.strategy` | string                                          strategy to use to determine order and parallelism of calling REST endpoint URLs; valid options are 'simple-explore-exploit' | `simple-explore-exploit`
`node.data-availability.rest-aggregator.strategy-update-interval` | duration                        how frequently to update the strategy with endpoint latency and error rate data | `10s`
`node.data-availability.rest-aggregator.sync-to-storage.check-already-exists` | check if the data already exists in this DAS's storage. Must be disabled for fast sync with an IPFS backend | `true`
`node.data-availability.rest-aggregator.sync-to-storage.delay-on-error` | duration                  time to wait if encountered an error before retrying | `1s`
`node.data-availability.rest-aggregator.sync-to-storage.eager` | eagerly sync batch data to this DAS's storage from the rest endpoints, using L1 as the index of batch data hashes; otherwise only sync lazily | None
`node.data-availability.rest-aggregator.sync-to-storage.eager-lower-bound-block` | uint             when eagerly syncing, start indexing forward from this L1 block. Only used if there is no sync state | None
`node.data-availability.rest-aggregator.sync-to-storage.ignore-write-errors` | log only on failures to write when syncing; otherwise treat it as an error | `true`
`node.data-availability.rest-aggregator.sync-to-storage.parent-chain-blocks-per-read` | uint        when eagerly syncing, max l1 blocks to read per poll | `100`
`node.data-availability.rest-aggregator.sync-to-storage.retention-period` | duration                period to retain synced data (defaults to forever) | `2562047h47m16.854775807s`
`node.data-availability.rest-aggregator.sync-to-storage.state-dir` | string                         directory to store the sync state in, ie the block number currently synced up to, so that we don't sync from scratch each time | None
`node.data-availability.rest-aggregator.urls` | strings                                             list of URLs including 'http://' or 'https://' prefixes and port numbers to REST DAS endpoints; additive with the online-url-list option | None
`node.data-availability.rest-aggregator.wait-before-try-next` | duration                            time to wait until trying the next set of REST endpoints while waiting for a response; the next set of REST endpoints is determined by the strategy selected | `2s`
`node.data-availability.rpc-aggregator.assumed-honest` | int                                        Number of assumed honest backends (H). If there are N backends, K=N+1-H valid responses are required to consider an Store request to be successful. | None
`node.data-availability.rpc-aggregator.backends` | string                                           JSON RPC backend configuration | None
`node.data-availability.rpc-aggregator.enable` | enable storage/retrieval of sequencer batch data from a list of RPC endpoints; this should only be used by the batch poster and not in combination with other DAS storage types | None
`node.data-availability.sequencer-inbox-address` | string                                           parent chain address of SequencerInbox contract | None
`node.delayed-sequencer.enable` | enable delayed sequencer | None
`node.delayed-sequencer.finalize-distance` | int                                                    how many blocks in the past L1 block is considered final (ignored when using Merge finality) | `20`
`node.delayed-sequencer.require-full-finality` | whether to wait for full finality before sequencing delayed messages | None
`node.delayed-sequencer.use-merge-finality` | whether to use The Merge's notion of finality before sequencing delayed messages | `true`
`node.feed.input.enable-compression` | enable per message deflate compression support | `true`
`node.feed.input.reconnect-initial-backoff` | duration                                              initial duration to wait before reconnect | `1s`
`node.feed.input.reconnect-maximum-backoff` | duration                                              maximum duration to wait before reconnect | `1m4s`
`node.feed.input.require-chain-id` | require chain id to be present on connect | None
`node.feed.input.require-feed-version` | require feed version to be present on connect | None
`node.feed.input.secondary-url` | strings                                                           list of secondary URLs of sequencer feed source. Would be started in the order they appear in the list when primary feeds fails | None
`node.feed.input.timeout` | duration                                                                duration to wait before timing out connection to sequencer feed | `20s`
`node.feed.input.url` | strings                                                                     list of primary URLs of sequencer feed source | None
`node.feed.input.verify.accept-sequencer` | accept verified message from sequencer | `true`
`node.feed.input.verify.allowed-addresses` | strings                                                a list of allowed addresses | None
`node.feed.input.verify.dangerous.accept-missing` | accept empty as valid signature | `true`
`node.feed.output.addr` | string                                                                    address to bind the relay feed output to | None
`node.feed.output.backlog.segment-limit` | int                                                      the maximum number of messages each segment within the backlog can contain | `240`
`node.feed.output.client-delay` | duration                                                          delay the first messages sent to each client by this amount | None
`node.feed.output.client-timeout` | duration                                                        duration to wait before timing out connections to client | `15s`
`node.feed.output.connection-limits.enable` | enable broadcaster per-client connection limiting | None
`node.feed.output.connection-limits.per-ip-limit` | int                                             limit clients, as identified by IPv4/v6 address, to this many connections to this relay | `5`
`node.feed.output.connection-limits.per-ipv6-cidr-48-limit` | int                                   limit ipv6 clients, as identified by IPv6 address masked with /48, to this many connections to this relay | `20`
`node.feed.output.connection-limits.per-ipv6-cidr-64-limit` | int                                   limit ipv6 clients, as identified by IPv6 address masked with /64, to this many connections to this relay | `10`
`node.feed.output.connection-limits.reconnect-cooldown-period` | duration                           time to wait after a relay client disconnects before the disconnect is registered with respect to the limit for this client | None
`node.feed.output.disable-signing` | don't sign feed messages | `true`
`node.feed.output.enable` | enable broadcaster | None
`node.feed.output.enable-compression` | enable per message deflate compression support | None
`node.feed.output.handshake-timeout` | duration                                                     duration to wait before timing out HTTP to WS upgrade | `1s`
`node.feed.output.limit-catchup` | only supply catchup buffer if requested sequence number is reasonable | None
`node.feed.output.log-connect` | log every client connect | None
`node.feed.output.log-disconnect` | log every client disconnect | None
`node.feed.output.max-catchup` | int                                                                the maximum size of the catchup buffer (-1 means unlimited) | `-1`
`node.feed.output.max-send-queue` | int                                                             maximum number of messages allowed to accumulate before client is disconnected | `4096`
`node.feed.output.ping` | duration                                                                  duration for ping interval | `5s`
`node.feed.output.port` | string                                                                    port to bind the relay feed output to | `9642`
`node.feed.output.queue` | int                                                                      queue size for HTTP to WS upgrade | `100`
`node.feed.output.read-timeout` | duration                                                          duration to wait before timing out reading data (i.e. pings) from clients | `1s`
`node.feed.output.require-compression` | require clients to use compression | None
`node.feed.output.require-version` | don't connect if client version not present | None
`node.feed.output.signed` | sign broadcast messages | None
`node.feed.output.workers` | int                                                                    number of threads to reserve for HTTP to WS upgrade | `100`
`node.feed.output.write-timeout` | duration                                                         duration to wait before timing out writing data to clients | `2s`
`node.inbox-reader.check-delay` | duration                                                          the maximum time to wait between inbox checks (if not enough new blocks are found) | `1m0s`
`node.inbox-reader.default-blocks-to-read` | uint                                                   the default number of blocks to read at once (will vary based on traffic by default) | `100`
`node.inbox-reader.delay-blocks` | uint                                                             number of latest blocks to ignore to reduce reorgs | None
`node.inbox-reader.hard-reorg` | erase future transactions in addition to overwriting existing ones on reorg | None
`node.inbox-reader.max-blocks-to-read` | uint                                                       if adjust-blocks-to-read is enabled, the maximum number of blocks to read at once | `2000`
`node.inbox-reader.min-blocks-to-read` | uint                                                       the minimum number of blocks to read at once (when caught up lowers load on L1) | `1`
`node.inbox-reader.read-mode` | string                                                              mode to only read latest or safe or finalized L1 blocks. Enabling safe or finalized disables feed input and output. Defaults to latest. Takes string input, valid strings- latest, safe, finalized | `latest`
`node.inbox-reader.target-messages-read` | uint                                                     if adjust-blocks-to-read is enabled, the target number of messages to read at once | `500`
`node.maintenance.lock.background-lock` | should node always try grabing lock in background | None
`node.maintenance.lock.enable` | if false, always treat this as locked and don't write the lock to redis | `true`
`node.maintenance.lock.key` | string                                                                key for lock | None
`node.maintenance.lock.lockout-duration` | duration                                                 how long lock is held | `1m0s`
`node.maintenance.lock.my-id` | string                                                              this node's id prefix when acquiring the lock (optional) | None
`node.maintenance.lock.refresh-duration` | duration                                                 how long between consecutive calls to redis | `10s`
`node.maintenance.time-of-day` | string                                                             UTC 24-hour time of day to run maintenance (currently only db compaction) at (e.g. 15:00) | None
`node.message-pruner.enable` | enable message pruning | `true`
`node.message-pruner.min-batches-left` | uint                                                       min number of batches not pruned | `2`
`node.message-pruner.prune-interval` | duration                                                     interval for running message pruner | `1m0s`
`node.parent-chain-reader.dangerous.wait-for-tx-approval-safe-poll` | duration                      Dangerous! only meant to be used by system tests | None
`node.parent-chain-reader.enable` | enable reader connection | `true`
`node.parent-chain-reader.old-header-timeout` | duration                                            warns if the latest l1 block is at least this old | `5m0s`
`node.parent-chain-reader.poll-interval` | duration                                                 interval when polling endpoint | `15s`
`node.parent-chain-reader.poll-only` | do not attempt to subscribe to header events | None
`node.parent-chain-reader.subscribe-err-interval` | duration                                        interval for subscribe error | `5m0s`
`node.parent-chain-reader.tx-timeout` | duration                                                    timeout when waiting for a transaction | `5m0s`
`node.parent-chain-reader.use-finality-data` | use l1 data about finalized/safe blocks | `true`
`node.seq-coordinator.chosen-healthcheck-addr` | string                                             if non-empty, launch an HTTP service binding to this address that returns status code 200 when chosen and 503 otherwise | None
`node.seq-coordinator.enable` | enable sequence coordinator | None
`node.seq-coordinator.handoff-timeout` | duration                                                   the maximum amount of time to spend waiting for another sequencer to accept the lockout when handing it off on shutdown or db compaction | `30s`
`node.seq-coordinator.lockout-duration` | duration | `1m0s`
`node.seq-coordinator.lockout-spare` | duration | `30s`
`node.seq-coordinator.msg-per-poll` | uint                                                          will only be marked as wanting the lockout if not too far behind | `2000`
`node.seq-coordinator.my-url` | string                                                              url for this sequencer if it is the chosen | `<?INVALID-URL?>`
`node.seq-coordinator.redis-url` | string                                                           the Redis URL to coordinate via | None
`node.seq-coordinator.release-retries` | int                                                        the number of times to retry releasing the wants lockout and chosen one status on shutdown | `4`
`node.seq-coordinator.retry-interval` | duration | `50ms`
`node.seq-coordinator.safe-shutdown-delay` | duration                                               if non-zero will add delay after transferring control | `5s`
`node.seq-coordinator.seq-num-duration` | duration | `24h0m0s`
`node.seq-coordinator.signer.ecdsa.accept-sequencer` | accept verified message from sequencer | `true`
`node.seq-coordinator.signer.ecdsa.allowed-addresses` | strings                                     a list of allowed addresses | None
`node.seq-coordinator.signer.ecdsa.dangerous.accept-missing` | accept empty as valid signature | `true`
`node.seq-coordinator.signer.symmetric-fallback` | if to fall back to symmetric hmac | None
`node.seq-coordinator.signer.symmetric-sign` | if to sign with symmetric hmac | None
`node.seq-coordinator.signer.symmetric.dangerous.disable-signature-verification` | disable message signature verification | None
`node.seq-coordinator.signer.symmetric.fallback-verification-key` | string                          a fallback key used for message verification | None
`node.seq-coordinator.signer.symmetric.signing-key` | string                                        a 32-byte (64-character) hex string used to sign messages, or a path to a file containing it | None
`node.seq-coordinator.update-interval` | duration | `250ms`
`node.sequencer` | enable sequencer | None
`node.staker.confirmation-blocks` | int                                                             confirmation blocks | `12`
`node.staker.contract-wallet-address` | string                                                      validator smart contract wallet public address | None
`node.staker.dangerous.ignore-rollup-wasm-module-root` | DANGEROUS! make assertions even when the wasm module root is wrong | None
`node.staker.dangerous.without-block-validator` | DANGEROUS! allows running an L1 validator without a block validator | None
`node.staker.data-poster.allocate-mempool-balance` | if true, don't put transactions in the mempool that spend a total greater than the batch poster's balance | `true`
`node.staker.data-poster.dangerous.clear-dbstorage` | clear database storage | None
`node.staker.data-poster.elapsed-time-base` | duration                                              unit to measure the time elapsed since creation of transaction used for maximum fee cap calculation | `10m0s`
`node.staker.data-poster.elapsed-time-importance` | float                                           weight given to the units of time elapsed used for maximum fee cap calculation | `10`
`node.staker.data-poster.external-signer.address` | string                                          external signer address | None
`node.staker.data-poster.external-signer.client-cert` | string                                      rpc client cert | None
`node.staker.data-poster.external-signer.client-private-key` | string                               rpc client private key | None
`node.staker.data-poster.external-signer.method` | string                                           external signer method | `eth_signTransaction`
`node.staker.data-poster.external-signer.root-ca` | string                                          external signer root CA | None
`node.staker.data-poster.external-signer.url` | string                                              external signer url | None
`node.staker.data-poster.legacy-storage-encoding` | encodes items in a legacy way (as it was before dropping generics) | None
`node.staker.data-poster.max-fee-cap-formula` | string                                              mathematical formula to calculate maximum fee cap gwei the result of which would be float64. This expression is expected to be evaluated please refer https://github.com/Knetic/govaluate/blob/master/MANUAL.md to find all available mathematical operators. Currently available variables to construct the formula are BacklogOfBatches, UrgencyGWei, ElapsedTime, ElapsedTimeBase, ElapsedTimeImportance, and TargetPriceGWei (default "((BacklogOfBatches * UrgencyGWei) ** 2) + ((ElapsedTime/ElapsedTimeBase) ** 2) * ElapsedTimeImportance + TargetPriceGWei") | None
`node.staker.data-poster.max-mempool-transactions` | uint                                           the maximum number of transactions to have queued in the mempool at once (0 = unlimited) | `1`
`node.staker.data-poster.max-queued-transactions` | int                                             the maximum number of unconfirmed transactions to track at once (0 = unlimited) | None
`node.staker.data-poster.max-tip-cap-gwei` | float                                                  the maximum tip cap to post transactions at | `5`
`node.staker.data-poster.min-fee-cap-gwei` | float                                                  the minimum fee cap to post transactions at | None
`node.staker.data-poster.min-tip-cap-gwei` | float                                                  the minimum tip cap to post transactions at | `0.05`
`node.staker.data-poster.nonce-rbf-soft-confs` | uint                                               the maximum probable reorg depth, used to determine when a transaction will no longer likely need replaced-by-fee | `1`
`node.staker.data-poster.redis-signer.dangerous.disable-signature-verification` | disable message signature verification | None
`node.staker.data-poster.redis-signer.fallback-verification-key` | string                           a fallback key used for message verification | None
`node.staker.data-poster.redis-signer.signing-key` | string                                         a 32-byte (64-character) hex string used to sign messages, or a path to a file containing it | None
`node.staker.data-poster.replacement-times` | string                                                comma-separated list of durations since first posting to attempt a replace-by-fee | `5m,10m,20m,30m,1h,2h,4h,6h,8h,12h,16h,18h,20h,22h`
`node.staker.data-poster.target-price-gwei` | float                                                 the target price to use for maximum fee cap calculation | `60`
`node.staker.data-poster.urgency-gwei` | float                                                      the urgency to use for maximum fee cap calculation | `2`
`node.staker.data-poster.use-db-storage` | uses database storage when enabled | `true`
`node.staker.data-poster.use-noop-storage` | uses noop storage, it doesn't store anything | None
`node.staker.data-poster.wait-for-l1-finality` | only treat a transaction as confirmed after L1 finality has been achieved (recommended) | `true`
`node.staker.disable-challenge` | disable validator challenge | None
`node.staker.enable` | enable validator | `true`
`node.staker.extra-gas` | uint                                                                      use this much more gas than estimation says is necessary to post transactions | `50000`
`node.staker.gas-refunder-address` | string                                                         The gas refunder contract address (optional) | None
`node.staker.make-assertion-interval` | duration                                                    if configured with the makeNodes strategy, how often to create new assertions (bypassed in case of a dispute) | `1h0m0s`
`node.staker.only-create-wallet-contract` | only create smart wallet contract and exit | None
`node.staker.parent-chain-wallet.account` | string                                                  account to use | `is first account in keystore`
`node.staker.parent-chain-wallet.only-create-key` | if true, creates new key then exits | None
`node.staker.parent-chain-wallet.password` | string                                                 wallet passphrase | `PASSWORD_NOT_SET`
`node.staker.parent-chain-wallet.pathname` | string                                                 pathname for wallet | `validator-wallet`
`node.staker.parent-chain-wallet.private-key` | string                                              private key for wallet | None
`node.staker.posting-strategy.high-gas-delay-blocks` | int                                          high gas delay blocks | None
`node.staker.posting-strategy.high-gas-threshold` | float                                           high gas threshold | None
`node.staker.redis-url` | string                                                                    redis url for L1 validator | None
`node.staker.staker-interval` | duration                                                            how often the L1 validator should check the status of the L1 rollup and maybe take action with its stake | `1m0s`
`node.staker.start-validation-from-staked` | assume staked nodes are valid | `true`
`node.staker.strategy` | string                                                                     L1 validator strategy, either watchtower, defensive, stakeLatest, or makeNodes | `Watchtower`
`node.staker.use-smart-contract-wallet` | use a smart contract wallet instead of an EOA address | None
`node.sync-monitor.block-build-lag` | uint                                                          allowed lag between messages read and blocks built | `20`
`node.sync-monitor.block-build-sequencer-inbox-lag` | uint                                          allowed lag between messages read from sequencer inbox and blocks built | None
`node.sync-monitor.coordinator-msg-lag` | uint                                                      allowed lag between local and remote messages | `15`
`node.sync-monitor.finalized-block-wait-for-block-validator` | wait for block validator to complete before returning finalized block number | None
`node.sync-monitor.safe-block-wait-for-block-validator` | wait for block validator to complete before returning safe block number | None
`node.transaction-streamer.execute-message-loop-delay` | duration                                   delay when polling calls to execute messages | `100ms`
`node.transaction-streamer.max-broadcaster-queue-size` | int                                        maximum cache of pending broadcaster messages | `50000`
`node.transaction-streamer.max-reorg-resequence-depth` | int                                        maximum number of messages to attempt to resequence on reorg (0 = never resequence, -1 = always resequence) | `1024`
`p2p.bootnodes` | strings                                                                           P2P bootnodes | None
`p2p.bootnodes-v5` | strings                                                                        P2P bootnodes v5 | None
`p2p.discovery-v4` | P2P discovery v4 | None
`p2p.discovery-v5` | P2P discovery v5 | None
`p2p.listen-addr` | string                                                                          P2P listen address | None
`p2p.max-peers` | int                                                                               P2P max peers | `50`
`p2p.no-dial` | P2P no dial | `true`
`p2p.no-discovery` | P2P no discovery | `true`
`parent-chain.connection.arg-log-limit` | uint                                                      limit size of arguments in log entries | `2048`
`parent-chain.connection.connection-wait` | duration                                                how long to wait for initial connection | `1m0s`
`parent-chain.connection.jwtsecret` | string                                                        path to file with jwtsecret for validation - ignored if url is self or self-auth | None
`parent-chain.connection.retries` | uint                                                            number of retries in case of failure(0 mean one attempt) | `2`
`parent-chain.connection.retry-delay` | duration                                                    delay between retries | None
`parent-chain.connection.retry-errors` | string                                                     Errors matching this regular expression are automatically retried | None
`parent-chain.connection.timeout` | duration                                                        per-response timeout (0-disabled) | `1m0s`
`parent-chain.connection.url` | string                                                              url of server, use self for loopback websocket, self-auth for loopback with authentication | None
`parent-chain.id` | uint                                                                            if set other than 0, will be used to validate database and L1 connection | None
`parent-chain.wallet.account` | string                                                              account to use | `is first account in keystore`
`parent-chain.wallet.only-create-key` | if true, creates new key then exits | None
`parent-chain.wallet.password` | string                                                             wallet passphrase | `PASSWORD_NOT_SET`
`parent-chain.wallet.pathname` | string                                                             pathname for wallet | `wallet`
`parent-chain.wallet.private-key` | string                                                          private key for wallet | None
`persistent.ancient` | string                                                                       directory of ancient where the chain freezer can be opened | None
`persistent.chain` | string                                                                         directory to store chain state | None
`persistent.db-engine` | string                                                                     backing database implementation to use ('leveldb' or 'pebble') | `leveldb`
`persistent.global-config` | string                                                                 directory to store global config | `.arbitrum`
`persistent.handles` | int                                                                          number of file descriptor handles to use for the database | `512`
`persistent.log-dir` | string                                                                       directory to store log file | None
`pprof` | enable pprof | None
`pprof-cfg.addr` | string                                                                           pprof server address | `127.0.0.1`
`pprof-cfg.port` | int                                                                              pprof server port | `6071`
`rpc.batch-request-limit` | int                                                                     the maximum number of requests in a batch (0 means no limit) | `1000`
`rpc.max-batch-response-size` | int                                                                 the maximum response size for a JSON-RPC request measured in bytes (0 means no limit) | `10000000`
`validation.api-auth` | validate is an authenticated API | `true`
`validation.api-public` | validate is a public API | None
`validation.arbitrator.execution-run-timeout` | duration                                            timeout before discarding execution run | `15m0s`
`validation.arbitrator.execution.cached-challenge-machines` | int                                   how many machines to store in cache while working on a challenge (should be even) | `4`
`validation.arbitrator.execution.initial-steps` | uint                                              initial steps between machines | `100000`
`validation.arbitrator.output-path` | string                                                        path to write machines to | `./target/output`
`validation.arbitrator.workers` | int                                                               number of concurrent validation threads | None
`validation.jit.cranelift` | use Cranelift instead of LLVM when validating blocks using the jit-accelerated block validator | `true`
`validation.jit.wasm-memory-usage-limit` | int                                                      if memory used by a jit wasm exceeds this limit, a warning is logged | `4294967296`
`validation.jit.workers` | int                                                                      number of concurrent validation threads | None
`validation.use-jit` | use jit for validation | `true`
`validation.wasm.allowed-wasm-module-roots` | strings                                               list of WASM module roots to check if the on-chain WASM module root belongs to on node startup | None
`validation.wasm.enable-wasmroots-check` | enable check for compatibility of on-chain WASM module root with node | `true`
`validation.wasm.root-path` | string                                                                path to machine folders, each containing wasm files (machine.wavm.br, replay.wasm) | None
`ws.addr` | string                                                                                  WS-RPC server listening interface | None
`ws.api` | strings                                                                                  APIs offered over the WS-RPC interface | `[net,web3,eth,arb]`
`ws.expose-all` | expose private api via websocket | None
`ws.origins` | strings                                                                              Origins from which to accept websockets requests | None
`ws.port` | int                                                                                     WS-RPC server listening port | `8548`
`ws.rpcprefix` | string                                                                             WS path path prefix on which JSON-RPC is served. Use '/' to serve on all paths | None

## Notes
