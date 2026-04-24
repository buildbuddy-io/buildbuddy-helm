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
| `image.repository`                            | Container image repository                                           | `buildbuddy.bbcr.io/public/buildbuddy-proxy-enterprise`    |
| `image.tag`                                   | Container image tag                                                  | `enterprise-v2.259.0`                                            |
| `replicas`                                    | Number of cache-proxy replicas                                       | `3`                                                              |
| `resources`                                   | Pod CPU/memory requests and limits                                   | `4 CPU / 16Gi`                                                   |
| `config`                                      | The `config.yaml` contents passed to the cache proxy                 | See [values.yaml](./values.yaml)                                 |
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
