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

## Deployment guidance

Cache Proxy pods form a distributed cache. Consistent hashing assigns cached
artifacts to the running pods, and reads and writes are routed to the pod that
owns each artifact. Prefer fewer, larger proxy pods to reduce overhead, while
keeping enough replicas and failure-domain spread for high availability.

As a starting point, provision these totals across all proxy pods:

- 1 proxy CPU for every 20-30 executor CPUs.
- 1 GB of proxy memory for every 4-5 GB of executor memory.

For example, a deployment with 1,000 executor CPUs and 2 TB of executor memory
should start with about 33-50 total proxy CPUs and 400-500 GB of total proxy
memory. Divide those totals across the proxy replicas. Monitor resource
utilization and tune these values for your cache traffic and enabled features.

Store proxy data on local SSD-backed storage. The chart's default `emptyDir`
volume and the optional `cacheProxyDataVolumeHostPath` only select how storage
is mounted; neither guarantees that the underlying node storage is an SSD.
Schedule proxies onto appropriately configured nodes and spread replicas across
failure domains.

Deploying proxies and executors in the same cluster lets the executor pool
autoscale while keeping cache traffic within the cluster. See the
[Cache Proxy documentation](https://www.buildbuddy.io/docs/enterprise-proxy)
for complete deployment and configuration guidance.

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
| `image.tag`                                   | Container image tag                                                  | `enterprise-v2.287.0`                                            |
| `replicas`                                    | Number of cache-proxy replicas                                       | `3`                                                              |
| `cacheTarget`                                 | Upstream BuildBuddy cache the proxy sits in front of                 | `grpcs://remote.buildbuddy.io`                                   |
| `config.auth.reparse_jwts`                    | Disable process-local JWT reparsing for remote-authenticated proxies | `false`                                                          |
| `resources`                                   | Pod CPU/memory requests and limits                                   | `4 CPU / 16Gi`                                                   |
| `config`                                      | The `config.yaml` contents passed to the cache proxy                 | See [values.yaml](./values.yaml)                                 |
| `ingress.annotations`                         | Extra annotations merged into the cache-proxy gRPC Ingress           | `proxy-body-size: "0"`                                           |
| `rbac.create`                                 | Create the Role/RoleBinding used for Kubernetes peer discovery       | `true`                                                           |
| `serviceAccount.create`                       | Create the ServiceAccount used by cache-proxy pods                   | `true`                                                           |
| `podDisruptionBudget.enabled`                 | Enable a PodDisruptionBudget                                         | `true`                                                           |

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
