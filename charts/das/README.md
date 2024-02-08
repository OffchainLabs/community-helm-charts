# Nitro DAS

A Helm chart for Arbitrum Nitro Data Availabity Servers and Mirrors. For full details on running a DAS, please see the official [Arbitrum Documentation](https://docs.arbitrum.io/node-running/how-tos/data-availability-committee/introduction).

> [!WARNING]
> There are many configuration options available for running a DAS and DAS Mirror. The chart defaults and intructions below are intended to get the server running. This is insufficient for production use. Please see the [Configuration Options](#configuration-options) section for the exhaustive list of options.

## Quickstart

```console
helm repo add offchainlabs https://charts.arbitrum.io
```

```console
helm install <my-release> offchainlabs/das
```

### Required Parameters
This chart supports running as a DAS mirror or a DAS as a member of a DAC. At a minimum, you must provide a parent chain node url, the sequencer inbox address, and a storage type. However, it is recommended to use multiple storage types for redundancy.

#### DAS Mirror
```console
helm install <my-release> offchainlabs/das \
--set configmap.data.data-availability.parent-chain-node-url=<PARENT_CHAIN_NODE_URL> \
--set configmap.data.data-availability.sequencer-inbox-address=<SEQUENCER_INBOX_ADDRESS> \
--set configmap.data.data-availability.local-file-storage.enable=true \
--set configmap.data.data-availability.local-file-storage.data-dir="/data/das-file-storage"
```

#### DAS
Running a DAS requires a bls key. The key can be provided as a secret or as a file. See the [Configuration Options](#configuration-options) section for more details.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: das-bls
data:
  das_bls: <BASE_64_ENCODED_PRIVATE_KEY>
  das_bls.pub: <BASE64_ENCODED_PUB_KEY
```

```console
helm install <my-release> offchainlabs/das \
--set configmap.data.data-availability.parent-chain-node-url=<PARENT_CHAIN_NODE_URL> \
--set configmap.data.data-availability.sequencer-inbox-address=<SEQUENCER_INBOX_ADDRESS> \
--set configmap.data.data-availability.local-file-storage.enable=true \
--set configmap.data.data-availability.local-file-storage.data-dir="/data/das-file-storage" \
--set dasecretName=das-bls
```

### Examples

Examples are included below of values files that may be useful as a starting point for production use cases.

#### DAS Mirror

```yaml
configmap:
  data:
    conf:
      env-prefix: "NITRO"
    data-availability:
      parent-chain-node-url: <PARENT_CHAIN_URL>
      sequencer-inbox-address: <SEQUENCER_INBOX_ADDRESS>
      local-db-storage:
        enable: true
        data-dir: "/data/das-db"
        discard-after-timeout: false
      local-file-storage:
        enable: true
        data-dir: "/data/das-storage"
      s3-storage:
        enable: true
        access-key: <S3_ACCESS_KEY>
        bucket: <S3_BUCKET_NAME>
        region: <S3_BUCKET_REGION>
      rest-aggregator:
        enable: true
        online-url-list: <DAS_URL_LIST> #URL with a list of active DAS endpoints such as https://nova.arbitrum.io/das-servers
        urls:
          - <INTERNAL_DAS_REST_ENDPOINT> #Useful to include an internal REST endpoint if also running a DAS
        sync-to-storage:
          eager: true
          eager-lower-bound-block: <PARENT_CHAIN_BLOCK_CHAIN_WAS_DEPLOYED>
          state-dir: /data/das-storage/syncState

extraEnv:
  - name: POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: NITRO_DATA__AVAILABILITY_S3__STORAGE_OBJECT__PREFIX
    value: "$(POD_NAME)/"
  - name: NITRO_DATA__AVAILABILITY_S3__STORAGE_SECRET__KEY
    valueFrom:
      secretKeyRef:
        name: das-s3-credentials
        key: secretKey
```

#### DAS

```yaml
configmap:
  data:
    conf:
      env-prefix: "NITRO"
    data-availability:
      parent-chain-node-url: <PARENT_CHAIN_URL>
      sequencer-inbox-address: <SEQUENCER_INBOX_ADDRESS>
      key:
        key-dir: "/data/das-key"
      local-db-storage:
        enable: true
        data-dir: "/data/das-db"
        discard-after-timeout: false
      local-file-storage:
        enable: true
        data-dir: "/data/das-storage"
      s3-storage:
        enable: true
        access-key: <S3_ACCESS_KEY>
        bucket: <S3_BUCKET_NAME>
        region: <S3_BUCKET_REGION>
      rest-aggregator:
        enable: true
        online-url-list: <DAS_URL_LIST> #URL with a list of active DAS endpoints such as https://nova.arbitrum.io/das-servers
        urls:
          - <INTERNAL_DAS_REST_ENDPOINT> #Useful to include an internal REST endpoint if also running a DAS
        sync-to-storage:
          eager: true
          eager-lower-bound-block: <PARENT_CHAIN_BLOCK_CHAIN_WAS_DEPLOYED>
          state-dir: /data/das-storage/syncState

dasecretName: <BLS_KEY_SECRET_NAME>

extraEnv:
  - name: POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: NITRO_DATA__AVAILABILITY_S3__STORAGE_OBJECT__PREFIX
    value: "$(POD_NAME)/"
  - name: NITRO_DATA__AVAILABILITY_S3__STORAGE_SECRET__KEY
    valueFrom:
      secretKeyRef:
        name: das-s3-credentials
        key: secretKey
```


## Parameters

### DAS Deployment Options

| Name                                            | Description                                                                 | Value                       |
| ----------------------------------------------- | --------------------------------------------------------------------------- | --------------------------- |
| `replicaCount`                                  | Number of replicas                                                          | `1`                         |
| `image.repository`                              | Docker image repository                                                     | `offchainlabs/nitro-node`   |
| `image.pullPolicy`                              | Docker image pull policy                                                    | `Always`                    |
| `image.tag`                                     | Docker image tag ovverrides the chart appVersion                            | `""`                        |
| `imagePullSecrets`                              | Docker registry pull secret                                                 | `[]`                        |
| `nameOverride`                                  | String to partially override das fullname                                   | `""`                        |
| `fullnameOverride`                              | String to fully override das fullname                                       | `""`                        |
| `diagnosticMode`                                | Enable diagnostics mode (sleep infinity)                                    | `false`                     |
| `commandOverride`                               | Command override for the das container                                      | `{}`                        |
| `livenessProbe`                                 | Liveness probe configuration                                                | `{}`                        |
| `readinessProbe`                                | Readiness probe configuration                                               | `{}`                        |
| `startupProbe.enabled`                          | Enable built in startup probe                                               | `true`                      |
| `startupProbe.failureThreshold`                 | Number of failures before pod is considered unhealthy                       | `2419200`                   |
| `startupProbe.periodSeconds`                    | Number of seconds between startup probes                                    | `1`                         |
| `persistence.localdbstorage`                    | This will only be created if local db storage is enabled in the configmap   |                             |
| `persistence.localdbstorage.size`               | Size of the persistent volume claim                                         | `100Gi`                     |
| `persistence.localdbstorage.storageClassName`   | Storage class of the persistent volume claim                                | `nil`                       |
| `persistence.localfilestorage`                  | This will only be created if local file storage is enabled in the configmap |                             |
| `persistence.localfilestorage.size`             | Size of the persistent volume claim                                         | `100Gi`                     |
| `persistence.localfilestorage.storageClassName` | Storage class of the persistent volume claim                                | `nil`                       |
| `serviceMonitor.enabled`                        | Enable service monitor CRD for prometheus operator                          | `false`                     |
| `serviceMonitor.portName`                       | Name of the port to monitor                                                 | `metrics`                   |
| `serviceMonitor.path`                           | Path to monitor                                                             | `/debug/metrics/prometheus` |
| `serviceMonitor.interval`                       | Interval to monitor                                                         | `5s`                        |
| `serviceMonitor.relabelings`                    | Add relabelings for the metrics being scraped                               | `{}`                        |
| `perReplicaService.enabled`                     | Enable per replica service                                                  | `false`                     |
| `headlessservice.enabled`                       | Enable headless service                                                     | `false`                     |
| `pdb.enabled`                                   | Enable pod disruption budget                                                | `false`                     |
| `pdb.minAvailable`                              | Minimum number of available pods                                            | `""`                        |
| `pdb.maxUnavailable`                            | Maximum number of unavailable pods                                          | `1`                         |
| `serviceAccount.create`                         | Create a service account                                                    | `true`                      |
| `serviceAccount.annotations`                    | Annotations for the service account                                         | `{}`                        |
| `serviceAccount.name`                           | Name of the service account                                                 | `""`                        |
| `podAnnotations`                                | Annotations for the das pod                                                 | `{}`                        |
| `podSecurityContext`                            | Security context for the das pod                                            | `{}`                        |
| `securityContext`                               | Security context for the das container                                      | `{}`                        |
| `service.type`                                  | Service type                                                                | `ClusterIP`                 |
| `resources`                                     | Resource requests and limits for the das container                          | `{}`                        |
| `nodeSelector`                                  | Node selector for the das pod                                               | `{}`                        |
| `tolerations`                                   | Tolerations for the das pod                                                 | `[]`                        |
| `affinity`                                      | Affinity for the das pod                                                    | `{}`                        |
| `dasecretName`                                  | Name of the das bls secret that contains the bls key                        | `""`                        |

### DAS Config options

| Name                                                                      | Description                                                                              | Value     |
| ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- | --------- |
| `configmap.enabled`                                                       | Enable configmap                                                                         | `true`    |
| `configmap.data`                                                          | Data for the configmap. See Configuration Options for the full list of available options |           |
| `configmap.data.log-type`                                                 | Log type                                                                                 | `json`    |
| `configmap.data.log-level`                                                | Log level                                                                                | `3`       |
| `configmap.data.enable-rest`                                              | Enable rest api                                                                          | `true`    |
| `configmap.data.rest-addr`                                                | Rest api address                                                                         | `0.0.0.0` |
| `configmap.data.rest-port`                                                | Rest api port                                                                            | `9877`    |
| `configmap.data.enable-rpc`                                               | Enable rpc api                                                                           | `true`    |
| `configmap.data.rpc-addr`                                                 | rpc api address                                                                          | `0.0.0.0` |
| `configmap.data.rpc-port`                                                 | rpc api port                                                                             | `9876`    |
| `configmap.data.data-availability.parent-chain-node-url`                  | Parent chain node url                                                                    | `""`      |
| `configmap.data.data-availability.sequencer-inbox-address`                | Sequencer inbox address                                                                  | `""`      |
| `configmap.data.data-availability.local-db-storage.enable`                | Enable local db storage                                                                  | `false`   |
| `configmap.data.data-availability.local-db-storage.data-dir`              | Data directory                                                                           | `""`      |
| `configmap.data.data-availability.local-db-storage.discard-after-timeout` | Discard after timeout                                                                    | `""`      |
| `configmap.data.data-availability.local-file-storage.enable`              | Enable local file storage                                                                | `false`   |
| `configmap.data.data-availability.local-file-storage.data-dir`            |                                                                                          | `""`      |
| `configmap.data.data-availability.s3-storage.enable`                      | Enable s3 storage                                                                        | `false`   |
| `configmap.data.data-availability.s3-storage.access-key`                  | s3 access key                                                                            | `""`      |
| `configmap.data.data-availability.s3-storage.bucket`                      | s3 bucket                                                                                | `""`      |
| `configmap.data.data-availability.s3-storage.discard-after-timeout`       | discard after timeout                                                                    | `""`      |
| `configmap.data.data-availability.s3-storage.object-prefix`               | object prefix                                                                            | `""`      |
| `configmap.data.data-availability.s3-storage.region`                      | region                                                                                   | `""`      |
| `configmap.data.data-availability.s3-storage.secret-key`                  | s3 secret key                                                                            | `""`      |
| `configmap.data.data-availability.ipfs-storage.enable`                    | Enable ipfs storage                                                                      | `false`   |
| `configmap.data.data-availability.ipfs-storage.profiles`                  | ipfs profiles                                                                            | `""`      |
| `configmap.data.data-availability.ipfs-storage.read-timeout`              | ipfs read timeout                                                                        | `1m0s`    |
| `configmap.data.data-availability.local-cache.enable`                     | Enable local cache                                                                       | `false`   |
| `configmap.data.data-availability.local-cache.expiration`                 | local cache expiration                                                                   | `1h0m0s`  |
| `configmap.data.metrics`                                                  | Enable metrics                                                                           | `false`   |
| `configmap.data.metrics-server.addr`                                      | Metrics server address                                                                   | `0.0.0.0` |
| `configmap.data.metrics-server.port`                                      | Metrics server port                                                                      | `6070`    |
| `configmap.data.metrics-server.update-interval`                           | Metrics server update interval                                                           | `5s`      |

## Configuration Options
The following table lists the exhaustive configurable parameters that can be applied as part of the configmap (nested under `configmap.data`) or as standalone cli flags.

Option | Description | Default
--- | --- | ---
`conf.dump` | print out currently active configuration file | None
`conf.env-prefix` | string                                                                     environment variables with given prefix will be loaded as configuration values | None
`conf.file` | strings                                                                          name of configuration file | None
`conf.reload-interval` | duration                                                              how often to reload configuration (0=disable periodic reloading) | None
`conf.s3.access-key` | string                                                                  S3 access key | None
`conf.s3.bucket` | string                                                                      S3 bucket | None
`conf.s3.object-key` | string                                                                  S3 object key | None
`conf.s3.region` | string                                                                      S3 region | None
`conf.s3.secret-key` | string                                                                  S3 secret key | None
`conf.string` | string                                                                         configuration as JSON string | None
`data-availability.disable-signature-checking` | disables signature checking on Data Availability Store requests (DANGEROUS, FOR TESTING ONLY) | None
`data-availability.enable` | enable Anytrust Data Availability mode | `true`
`data-availability.extra-signature-checking-public-key` | string                               public key to use to validate Data Availability Store requests in addition to the Sequencer's public key determined using sequencer-inbox-address, can be a file or the hex-encoded public key beginning with 0x; useful for testing | None
`data-availability.ipfs-storage.enable` | enable storage/retrieval of sequencer batch data from IPFS | None
`data-availability.ipfs-storage.peers` | strings                                               list of IPFS peers to connect to, eg /ip4/1.2.3.4/tcp/12345/p2p/abc...xyz | None
`data-availability.ipfs-storage.pin-after-get` | pin sequencer batch data in IPFS | `true`
`data-availability.ipfs-storage.pin-percentage` | float                                        percent of sequencer batch data to pin, as a floating point number in the range 0.0 to 100.0 | `100`
`data-availability.ipfs-storage.profiles` | string                                             comma separated list of IPFS profiles to use, see https://docs.ipfs.tech/how-to/default-profile | None
`data-availability.ipfs-storage.read-timeout` | duration                                       timeout for IPFS reads, since by default it will wait forever. Treat timeout as not found | `1m0s`
`data-availability.ipfs-storage.repo-dir` | string                                             directory to use to store the local IPFS repo | None
`data-availability.key.key-dir` | string                                                       the directory to read the bls keypair ('das_bls.pub' and 'das_bls') from; if using any of the DAS storage types exactly one of key-dir or priv-key must be specified | None
`data-availability.key.priv-key` | string                                                      the base64 BLS private key to use for signing DAS certificates; if using any of the DAS storage types exactly one of key-dir or priv-key must be specified | None
`data-availability.local-cache.enable` | Enable local in-memory caching of sequencer batch data | None
`data-availability.local-cache.expiration` | duration                                          Expiration time for in-memory cached sequencer batches | `1h0m0s`
`data-availability.local-db-storage.data-dir` | string                                         directory in which to store the database | None
`data-availability.local-db-storage.discard-after-timeout` | discard data after its expiry timeout | None
`data-availability.local-db-storage.enable` | enable storage/retrieval of sequencer batch data from a database on the local filesystem | None
`data-availability.local-db-storage.sync-from-storage-service` | enable db storage to be used as a source for regular sync storage | None
`data-availability.local-db-storage.sync-to-storage-service` | enable db storage to be used as a sink for regular sync storage | None
`data-availability.local-file-storage.data-dir` | string                                       local data directory | None
`data-availability.local-file-storage.enable` | enable storage/retrieval of sequencer batch data from a directory of files, one per batch | None
`data-availability.local-file-storage.sync-from-storage-service` | enable local storage to be used as a source for regular sync storage | None
`data-availability.local-file-storage.sync-to-storage-service` | enable local storage to be used as a sink for regular sync storage | None
`data-availability.panic-on-error` | whether the Data Availability Service should fail immediately on errors (not recommended) | None
`data-availability.parent-chain-connection-attempts` | int                                     parent chain RPC connection attempts (spaced out at least 1 second per attempt, 0 to retry infinitely), only used in standalone daserver; when running as part of a node that node's parent chain configuration is used | `15`
`data-availability.parent-chain-node-url` | string                                             URL for parent chain node, only used in standalone daserver; when running as part of a node that node's L1 configuration is used | None
`data-availability.redis-cache.enable` | enable Redis caching of sequencer batch data | None
`data-availability.redis-cache.expiration` | duration                                          Redis expiration | `1h0m0s`
`data-availability.redis-cache.key-config` | string                                            Redis key config | None
`data-availability.redis-cache.sync-from-storage-service` | enable Redis to be used as a source for regular sync storage | None
`data-availability.redis-cache.sync-to-storage-service` | enable Redis to be used as a sink for regular sync storage | None
`data-availability.redis-cache.url` | string                                                   Redis url | None
`data-availability.regular-sync-storage.enable` | enable regular storage syncing | None
`data-availability.regular-sync-storage.sync-interval` | duration                              interval for running regular storage sync | `5m0s`
`data-availability.rest-aggregator.enable` | enable retrieval of sequencer batch data from a list of remote REST endpoints; if other DAS storage types are enabled, this mode is used as a fallback | None
`data-availability.rest-aggregator.max-per-endpoint-stats` | int                               number of stats entries (latency and success rate) to keep for each REST endpoint; controls whether strategy is faster or slower to respond to changing conditions | `20`
`data-availability.rest-aggregator.online-url-list` | string                                   a URL to a list of URLs of REST das endpoints that is checked at startup; additive with the url option | None
`data-availability.rest-aggregator.online-url-list-fetch-interval` | duration                  time interval to periodically fetch url list from online-url-list | `1h0m0s`
`data-availability.rest-aggregator.simple-explore-exploit-strategy.exploit-iterations` | int   number of consecutive GetByHash calls to the aggregator where each call will cause it to select from REST endpoints in order of best latency and success rate, before switching to explore mode | `1000`
`data-availability.rest-aggregator.simple-explore-exploit-strategy.explore-iterations` | int   number of consecutive GetByHash calls to the aggregator where each call will cause it to randomly select from REST endpoints until one returns successfully, before switching to exploit mode | `20`
`data-availability.rest-aggregator.strategy` | string                                          strategy to use to determine order and parallelism of calling REST endpoint URLs; valid options are 'simple-explore-exploit' | `simple-explore-exploit`
`data-availability.rest-aggregator.strategy-update-interval` | duration                        how frequently to update the strategy with endpoint latency and error rate data | `10s`
`data-availability.rest-aggregator.sync-to-storage.check-already-exists` | check if the data already exists in this DAS's storage. Must be disabled for fast sync with an IPFS backend | `true`
`data-availability.rest-aggregator.sync-to-storage.delay-on-error` | duration                  time to wait if encountered an error before retrying | `1s`
`data-availability.rest-aggregator.sync-to-storage.eager` | eagerly sync batch data to this DAS's storage from the rest endpoints, using L1 as the index of batch data hashes; otherwise only sync lazily | None
`data-availability.rest-aggregator.sync-to-storage.eager-lower-bound-block` | uint             when eagerly syncing, start indexing forward from this L1 block. Only used if there is no sync state | None
`data-availability.rest-aggregator.sync-to-storage.ignore-write-errors` | log only on failures to write when syncing; otherwise treat it as an error | `true`
`data-availability.rest-aggregator.sync-to-storage.parent-chain-blocks-per-read` | uint        when eagerly syncing, max l1 blocks to read per poll | `100`
`data-availability.rest-aggregator.sync-to-storage.retention-period` | duration                period to retain synced data (defaults to forever) | `2562047h47m16.854775807s`
`data-availability.rest-aggregator.sync-to-storage.state-dir` | string                         directory to store the sync state in, ie the block number currently synced up to, so that we don't sync from scratch each time | None
`data-availability.rest-aggregator.urls` | strings                                             list of URLs including 'http://' or 'https://' prefixes and port numbers to REST DAS endpoints; additive with the online-url-list option | None
`data-availability.rest-aggregator.wait-before-try-next` | duration                            time to wait until trying the next set of REST endpoints while waiting for a response; the next set of REST endpoints is determined by the strategy selected | `2s`
`data-availability.s3-storage.access-key` | string                                             S3 access key | None
`data-availability.s3-storage.bucket` | string                                                 S3 bucket | None
`data-availability.s3-storage.discard-after-timeout` | discard data after its expiry timeout | None
`data-availability.s3-storage.enable` | enable storage/retrieval of sequencer batch data from an AWS S3 bucket | None
`data-availability.s3-storage.object-prefix` | string                                          prefix to add to S3 objects | None
`data-availability.s3-storage.region` | string                                                 S3 region | None
`data-availability.s3-storage.secret-key` | string                                             S3 secret key | None
`data-availability.s3-storage.sync-from-storage-service` | enable s3 to be used as a source for regular sync storage | None
`data-availability.s3-storage.sync-to-storage-service` | enable s3 to be used as a sink for regular sync storage | None
`data-availability.sequencer-inbox-address` | string                                           parent chain address of SequencerInbox contract | None
`enable-rest` | enable the REST server listening on rest-addr and rest-port | None
`enable-rpc` | enable the HTTP-RPC server listening on rpc-addr and rpc-port | None
`log-level` | int                                                                              log level; 1: ERROR, 2: WARN, 3: INFO, 4: DEBUG, 5: TRACE | `3`
`log-type` | string                                                                            log type (plaintext or json) | `plaintext`
`metrics` | enable metrics | None
`metrics-server.addr` | string                                                                 metrics server address | `127.0.0.1`
`metrics-server.port` | int                                                                    metrics server port | `6070`
`metrics-server.update-interval` | duration                                                    metrics server update interval | `3s`
`pprof` | enable pprof | None
`pprof-cfg.addr` | string                                                                      pprof server address | `127.0.0.1`
`pprof-cfg.port` | int                                                                         pprof server port | `6071`
`rest-addr` | string                                                                           REST server listening interface | `localhost`
`rest-port` | uint                                                                             REST server listening port | `9877`
`rest-server-timeouts.idle-timeout` | duration                                                 the maximum amount of time to wait for the next request when keep-alives are enabled (http.Server.IdleTimeout) | `2m0s`
`rest-server-timeouts.read-header-timeout` | duration                                          the amount of time allowed to read the request headers (http.Server.ReadHeaderTimeout) | `30s`
`rest-server-timeouts.read-timeout` | duration                                                 the maximum duration for reading the entire request (http.Server.ReadTimeout) | `30s`
`rest-server-timeouts.write-timeout` | duration                                                the maximum duration before timing out writes of the response (http.Server.WriteTimeout) | `30s`
`rpc-addr` | string                                                                            HTTP-RPC server listening interface | `localhost`
`rpc-port` | uint                                                                              HTTP-RPC server listening port | `9876`
`rpc-server-timeouts.idle-timeout` | duration                                                  the maximum amount of time to wait for the next request when keep-alives are enabled (http.Server.IdleTimeout) | `2m0s`
`rpc-server-timeouts.read-header-timeout` | duration                                           the amount of time allowed to read the request headers (http.Server.ReadHeaderTimeout) | `30s`
`rpc-server-timeouts.read-timeout` | duration                                                  the maximum duration for reading the entire request (http.Server.ReadTimeout) | `30s`
`rpc-server-timeouts.write-timeout` | duration                                                 the maximum duration before timing out writes of the response (http.Server.WriteTimeout) | `30s`

## Notes
