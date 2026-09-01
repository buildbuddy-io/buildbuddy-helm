# BuildBuddy Enterprise Cache Proxy

BuildBuddy Enterprise Cache Proxy is a caching layer that sits in front of your
[BuildBuddy](https://buildbuddy.io) remote cache, serving frequently-requested
blobs locally and reducing round-trips to the upstream cache.

## TL;DR

```bash
helm repo add buildbuddy https://helm.buildbuddy.io
helm install buildbuddy-cache-proxy buildbuddy/buildbuddy-enterprise-cache-proxy
```

## Introduction

This chart creates a [BuildBuddy Enterprise Cache Proxy](https://www.buildbuddy.io)
deployment on a [Kubernetes](https://kubernetes.io/) cluster using the
[Helm](https://helm.sh/) package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm v3+

## Defaults

This chart runs the Cache Proxy using BuildBuddy-recommended settings.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm install my-release buildbuddy/buildbuddy-enterprise-cache-proxy
```

See [Configuration](#configuration) below for values you may want to override.

## Uninstalling the Chart

```bash
helm delete my-release
```

## Configuration

See [values.yaml](./values.yaml) for the full list of configurable parameters.
Some common ones:

| Parameter                                     | Description                                                          | Default                                                          |
| --------------------------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `image.repository`                            | Container image repository                                           | `buildbuddy.bbcr.io/public/buildbuddy-proxy-enterprise`          |
| `image.tag`                                   | Container image tag                                                  | `enterprise-v2.300.0`                                            |
| `replicas`                                    | Number of cache-proxy replicas                                       | `3`                                                              |
| `cacheTarget`                                 | Upstream BuildBuddy cache the proxy sits in front of                 | `grpcs://remote.buildbuddy.io`                                   |
| `config.auth.reparse_jwts`                    | Disable process-local JWT reparsing for remote-authenticated proxies | `false`                                                          |
| `resources`                                   | Pod CPU/memory requests and limits                                   | `4 CPU / 16Gi`                                                   |
| `config`                                      | The `config.yaml` contents passed to the cache proxy                 | See [values.yaml](./values.yaml)                                 |
| `ingress.annotations`                         | Extra annotations merged into the cache-proxy gRPC Ingress           | `proxy-body-size: "0"`                                           |
| `rbac.create`                                 | Create the Role/RoleBinding used for Kubernetes peer discovery       | `true`                                                           |
| `serviceAccount.create`                       | Create the ServiceAccount used by cache-proxy pods                   | `true`                                                           |
| `podDisruptionBudget.enabled`                 | Enable a PodDisruptionBudget                                         | `true`                                                           |
| `persistence.enabled`                         | Back the cache-proxy data volume with a per-replica PVC              | `false`                                                          |
| `persistence.size`                            | Size of each cache-proxy PVC                                         | `100Gi`                                                          |
| `persistence.storageClass`                    | StorageClass for the cache-proxy PVCs (cluster default if unset)     | `nil`                                                            |

Individual values can be overridden at install time with `--set`:

```bash
helm install my-release buildbuddy/buildbuddy-enterprise-cache-proxy \
  --set replicas=3 \
  --set config.cache.max_size_bytes=250000000000
```

### Peer discovery

The Cache Proxy uses consistent hashing to shard replicas across pods. Peer
discovery is done via the Kubernetes API. The chart creates a `ServiceAccount`,
`Role`, and `RoleBinding` granting the minimum permissions needed
(`get/list/watch pods`, `get replicasets` in the release namespace).

If you prefer to manage RBAC yourself, set `rbac.create=false` and
`serviceAccount.create=false`, and reference your existing ServiceAccount with
`serviceAccount.name`.

### Persistent storage

By default the cache proxy writes its on-disk cache to an `emptyDir`, so the
cache is cold again every time a pod restarts. To keep the cache across
restarts and rescheduling, enable persistence:

```bash
helm install my-release buildbuddy/buildbuddy-enterprise-cache-proxy \
  --set persistence.enabled=true \
  --set persistence.size=250Gi \
  --set persistence.storageClass=ssd
```

This adds a `volumeClaimTemplate` to the StatefulSet, so each replica gets its
own PersistentVolumeClaim mounted at `/buildbuddy/` — the directory holding
`config.cache.pebble.root_directory`. Size the volume comfortably above
`config.cache.max_size_bytes`.

Kubernetes does not garbage-collect PVCs created from a `volumeClaimTemplate`:
they outlive `helm uninstall` and scale-downs, and are reattached if a replica
comes back. Delete them by hand when you no longer need the data.

As an alternative, `cacheProxyDataVolumeHostPath` mounts a path on the node
(useful for local SSDs). The two options are mutually exclusive.
