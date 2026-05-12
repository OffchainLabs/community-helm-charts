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
Running a DAS as a part of a Data Availability Committee (DAC) requires a BLS key. The key can be provided as a secret or as a file. See the [Configuration Options](#configuration-options) section for more details.

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
--set configmap.data.data-availability.key.key-dir="/data/das-key" \
--set configmap.data.enable-rpc=true \
--set dasecretName=das-bls
```

### Examples

Examples are included below of values files that may be useful as a starting point for production use cases.

#### DAS (Mirror)

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

#### DAS (DAC Member)

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
      enable-rpc: true

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
| `lifecycle`                                     | Lifecycle hooks configuration                                               | `{}`                        |
| `extraEnv`                                      | Additional environment variables for the container                          | `{}`                        |
| `image.repository`                              | Docker image repository                                                     | `offchainlabs/nitro-node`   |
| `image.pullPolicy`                              | Docker image pull policy                                                    | `Always`                    |
| `image.tag`                                     | Docker image tag ovverrides the chart appVersion                            | `""`                        |
| `imagePullSecrets`                              | Docker registry pull secret                                                 | `[]`                        |
| `nameOverride`                                  | String to partially override das fullname                                   | `""`                        |
| `fullnameOverride`                              | String to fully override das fullname                                       | `""`                        |
| `diagnosticMode`                                | Enable diagnostics mode (sleep infinity)                                    | `false`                     |
| `commandOverride`                               | Command override for the das container                                      | `{}`                        |
| `customArgs`                                    | Extra args to pass to the das container command                             | `[]`                        |
| `livenessProbe`                                 | livenessProbe                                                               |                             |
| `livenessProbe.enabled`                         | Enable liveness probe                                                       | `true`                      |
| `livenessProbe.initialDelaySeconds`             | Initial delay for the liveness probe                                        | `60`                        |
| `livenessProbe.periodSeconds`                   | Period for the liveness probe                                               | `60`                        |
| `livenessProbe.timeoutSeconds`                  | Timeout for the liveness probe                                              | `5`                         |
| `livenessProbe.failureThreshold`                | Failure threshold for the liveness probe                                    | `3`                         |
| `livenessProbe.successThreshold`                | Success threshold for the liveness probe                                    | `1`                         |
| `readinessProbe`                                | readinessProbe                                                              |                             |
| `readinessProbe.enabled`                        | Enable readiness probe                                                      | `true`                      |
| `readinessProbe.initialDelaySeconds`            | Initial delay for the readiness probe                                       | `0`                         |
| `readinessProbe.periodSeconds`                  | Period for the readiness probe                                              | `5`                         |
| `readinessProbe.timeoutSeconds`                 | Timeout for the readiness probe                                             | `5`                         |
| `readinessProbe.failureThreshold`               | Failure threshold for the readiness probe                                   | `3`                         |
| `readinessProbe.successThreshold`               | Success threshold for the readiness probe                                   | `1`                         |
| `startupProbe`                                  | startupProbe                                                                |                             |
| `startupProbe.enabled`                          | Enable startup probe                                                        | `false`                     |
| `updateStrategy.type`                           | Update strategy type                                                        | `RollingUpdate`             |
| `persistence.localfilestorage`                  | This will only be created if local file storage is enabled in the configmap |                             |
| `persistence.localfilestorage.size`             | Size of the persistent volume claim                                         | `100Gi`                     |
| `persistence.localfilestorage.storageClassName` | Storage class of the persistent volume claim                                | `nil`                       |
| `persistence.localfilestorage.accessModes`      | Access modes of the persistent volume claim                                 | `["ReadWriteOnce"]`         |
| `serviceMonitor.enabled`                        | Enable service monitor CRD for prometheus operator                          | `false`                     |
| `serviceMonitor.portName`                       | Name of the port to monitor                                                 | `metrics`                   |
| `serviceMonitor.path`                           | Path to monitor                                                             | `/debug/metrics/prometheus` |
| `serviceMonitor.interval`                       | Interval to monitor                                                         | `5s`                        |
| `serviceMonitor.relabelings`                    | Add relabelings for the metrics being scraped                               | `[]`                        |
| `perReplicaService.enabled`                     | Enable per replica service                                                  | `false`                     |
| `headlessService.enabled`                       | Enable headless service                                                     | `false`                     |
| `headlessService.publishNotReadyAddresses`      | Publish not ready addresses                                                 | `true`                      |
| `pdb.enabled`                                   | Enable pod disruption budget                                                | `false`                     |
| `pdb.minAvailable`                              | Minimum number of available pods                                            | `""`                        |
| `pdb.maxUnavailable`                            | Maximum number of unavailable pods                                          | `1`                         |
| `serviceAccount.create`                         | Create a service account                                                    | `true`                      |
| `serviceAccount.annotations`                    | Annotations for the service account                                         | `{}`                        |
| `serviceAccount.name`                           | Name of the service account                                                 | `""`                        |
| `podAnnotations`                                | Annotations for the das pod                                                 | `{}`                        |
| `podSecurityContext.fsGroup`                    | Group id for the pod                                                        | `1000`                      |
| `podSecurityContext.runAsGroup`                 | Group id for the user                                                       | `1000`                      |
| `podSecurityContext.runAsNonRoot`               | Run as non root                                                             | `true`                      |
| `podSecurityContext.runAsUser`                  | User id for the user                                                        | `1000`                      |
| `podSecurityContext.fsGroupChangePolicy`        | Policy for the fs group                                                     | `OnRootMismatch`            |
| `securityContext`                               | Security context for the das container                                      | `{}`                        |
| `priorityClassName`                             | Priority class name for the das pod                                         | `""`                        |
| `service.type`                                  | Service type                                                                | `ClusterIP`                 |
| `service.publishNotReadyAddresses`              | Publish not ready addresses                                                 | `false`                     |
| `resources`                                     | Resource requests and limits for the das container                          | `{}`                        |
| `nodeSelector`                                  | Node selector for the das pod                                               | `{}`                        |
| `tolerations`                                   | Tolerations for the das pod                                                 | `[]`                        |
| `affinity`                                      | Affinity for the das pod                                                    | `{}`                        |
| `dasecretName`                                  | Name of the das bls secret that contains the bls key                        | `""`                        |
| `overrideKeydirMountPath`                       | Override the keydir mount path                                              | `""`                        |

### DAS Config options

| Name                                                                                       | Description                                                                              | Value     |
| ------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------- | --------- |
| `configmap.enabled`                                                                        | Enable configmap                                                                         | `true`    |
| `configmap.data`                                                                           | Data for the configmap. See Configuration Options for the full list of available options |           |
| `configmap.data.conf.env-prefix`                                                           | Environment variable prefix                                                              | `NITRO`   |
| `configmap.data.log-type`                                                                  | Log type                                                                                 | `json`    |
| `configmap.data.log-level`                                                                 | Log level                                                                                | `warn`    |
| `configmap.data.enable-rest`                                                               | Enable rest api                                                                          | `true`    |
| `configmap.data.rest-addr`                                                                 | Rest api address                                                                         | `0.0.0.0` |
| `configmap.data.rest-port`                                                                 | Rest api port                                                                            | `9877`    |
| `configmap.data.enable-rpc`                                                                | Enable rpc api                                                                           | `false`   |
| `configmap.data.rpc-addr`                                                                  | rpc api address                                                                          | `0.0.0.0` |
| `configmap.data.rpc-port`                                                                  | rpc api port                                                                             | `9876`    |
| `configmap.data.data-availability.parent-chain-node-url`                                   | Parent chain node url                                                                    | `""`      |
| `configmap.data.data-availability.sequencer-inbox-address`                                 | Sequencer inbox address                                                                  | `""`      |
| `configmap.data.data-availability.local-file-storage.enable`                               | Enable local file storage                                                                | `false`   |
| `configmap.data.data-availability.local-file-storage.data-dir`                             |                                                                                          | `""`      |
| `configmap.data.data-availability.s3-storage.enable`                                       | Enable s3 storage                                                                        | `false`   |
| `configmap.data.data-availability.s3-storage.access-key`                                   | s3 access key                                                                            | `""`      |
| `configmap.data.data-availability.s3-storage.bucket`                                       | s3 bucket                                                                                | `""`      |
| `configmap.data.data-availability.s3-storage.discard-after-timeout`                        | discard after timeout                                                                    | `""`      |
| `configmap.data.data-availability.s3-storage.object-prefix`                                | object prefix                                                                            | `""`      |
| `configmap.data.data-availability.s3-storage.region`                                       | region                                                                                   | `""`      |
| `configmap.data.data-availability.s3-storage.secret-key`                                   | s3 secret key                                                                            | `""`      |
| `configmap.data.data-availability.local-cache.enable`                                      | Enable local cache                                                                       | `false`   |
| `configmap.data.data-availability.local-cache.capacity`                                    | Maximum number of entries (up to 64KB each) to store in the cache.                       | `20000`   |
| `configmap.data.data-availability.rest-aggregator.enable`                                  | Enable rest aggregator                                                                   | `false`   |
| `configmap.data.data-availability.rest-aggregator.sync-to-storage.eager`                   | Enable eagerly syncing batch data to this DAS's storage                                  | `false`   |
| `configmap.data.data-availability.rest-aggregator.sync-to-storage.state-dir`               | Sync to storage directory                                                                | `""`      |
| `configmap.data.data-availability.rest-aggregator.sync-to-storage.eager-lower-bound-block` | Start indexing forward from this L1 block                                                | `""`      |
| `configmap.data.metrics`                                                                   | Enable metrics                                                                           | `false`   |
| `configmap.data.metrics-server.addr`                                                       | Metrics server address                                                                   | `0.0.0.0` |
| `configmap.data.metrics-server.port`                                                       | Metrics server port                                                                      | `6070`    |
| `configmap.data.metrics-server.update-interval`                                            | Metrics server update interval                                                           | `5s`      |

## Configuration Options
The following table lists the exhaustive configurable parameters that can be applied as part of the configmap (nested under `configmap.data`) or as standalone cli flags.

Option | Description | Default
--- | --- | ---

## Notes
