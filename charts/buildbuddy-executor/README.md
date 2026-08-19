# BuildBuddy Executor

BuildBuddy Executor handles execution for [BuildBuddy](https://buildbuddy.io)'s Remote Build Execution platform.

## TL;DR

```
helm repo add buildbuddy https://helm.buildbuddy.io
helm install buildbuddy buildbuddy/buildbuddy-executor
```

## Introduction

This chart creates a [BuildBuddy Executor](https://www.buildbuddy.io/pricing) deployment on a [Kubernetes](https://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

## Prerequisites

- Kubernetes 1.15+ with Beta APIs enabled
- Helm v2/v3
- Tiller (the Helm v2 server-side component) installed on the cluster

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install my-release buildbuddy/buildbuddy-executor
```

**Helm v2 command**

```bash
$ helm install --name my-release buildbuddy/buildbuddy-executor
```

The command deploys BuildBuddy Executor on the Kubernetes cluster in the default configuration. The [configuration](#configuration)
section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Updating your release

If you change configuration, you can update your deployment:

```bash
$ helm upgrade my-release -f my-values.yaml buildbuddy/buildbuddy-executor
```

## Writing deployment to a file

You can write your Kubernetes deployment configuration to a file release name `my-release`:

```bash
$ helm template my-release buildbuddy/buildbuddy-executor > buildbuddy-deploy.yaml
```

You can then check this configuration in to your source repository, or manually apply it to your cluster with:

```bash
$ kubectl apply -f buildbuddy-deploy.yaml
```

## Configuration

The following table lists the configurable parameters of the BuildBuddy Open Source chart and their default values.

| Parameter                     | Description                                                                                                                                                                                                                                                                                                                                       | Default                                                                                                                            |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `config`                      | The `config.yaml` configuration to be used by the BuildBuddy Executor. The values you provide will by using Helm's merging behavior override individual default values only. See the [example configurations](#example-configurations) and the [BuildBuddy documentation](https://www.buildbuddy.io/docs/config-rbe#executor-config) for details. | See `config` in [values.yaml](https://github.com/buildbuddy-io/buildbuddy-helm/blob/master/charts/buildbuddy-executor/values.yaml) |
| `image.repository`            | Container image repository                                                                                                                                                                                                                                                                                                                        | `buildbuddy.bbcr.io/public/buildbuddy-executor-enterprise`                                                                               |
| `image.tag`                   | Container image tag                                                                                                                                                                                                                                                                                                                               | `enterprise-v2.295.0`                                                                                                                |
| `image.imagePullPolicy`       | Container image pull policy                                                                                                                                                                                                                                                                                                                       | `IfNotPresent`                                                                                                                     |
| `imagePullSecrets`            | Image pull secrets for private container registries                                                                                                                                                                                                                                                                                               | `[]`                                                                                                                               |
| `disk.data.enabled`           | Whether to enable a persistent volume disk mounted at /data                                                                                                                                                                                                                                                                                       | `true`                                                                                                                             |
| `disk.data.size`              | The size of the persistent volume disk                                                                                                                                                                                                                                                                                                            | `10Gi`                                                                                                                             |
| `service.internalHTTPPort`    | The port on our docker image that serves http traffic                                                                                                                                                                                                                                                                                             | `8080`                                                                                                                             |
| `service.internalGRPCPort`    | The port on our docker image that serves grpc traffic                                                                                                                                                                                                                                                                                             | `1985`                                                                                                                             |
| `service.internalMetricsPort` | The port on our docker image that serves prometheus traffic                                                                                                                                                                                                                                                                                       | `9090`                                                                                                                             |
| `proxy.enabled`               | Deploy a [BuildBuddy Enterprise Cache Proxy](../buildbuddy-enterprise-cache-proxy) and default `config.executor.cache_target` to its in-cluster gRPC Service. Any cache-proxy chart value can be passed under `proxy`.                                                                                               | `false`                                                                                                                            |
| `extraPodAnnotations`         | Extra pod annotations to be used in the deployments                                                                                                                                                                                                                                                                                               | `[]`                                                                                                                               |
| `extraPodLabels`              | Extra pod labels to be used in the deployments                                                                                                                                                                                                                                                                                                    | `[]`                                                                                                                               |
| `extraEnvVars`                | Extra environments variables to be used in the deployments                                                                                                                                                                                                                                                                                        | `[]`                                                                                                                               |
| `extraInitContainers`         | Additional init containers                                                                                                                                                                                                                                                                                                                        | `[]`                                                                                                                               |
| `extraContainers`             | Additional containers                                                                                                                                                                                                                                                                                                                             | `[]`                                                                                                                               |
| `customExecutorCommand`       | Custom command for running the executor                                                                                                                                                                                                                                                                                                           | `null`                                                                                                                             |
| `executorDataVolumeHostPath`  | Optional node hostPath for the executor cache and build-data volume mounted at `/buildbuddy`. Enabling it adds required one-executor-per-node anti-affinity.                                                                                                                                                                                       | `null` (`emptyDir`)                                                                                                                 |
| `executorMetadataVolume`      | Kubernetes VolumeSource for generated executor host-ID metadata. The default is a release-specific node hostPath and adds required one-executor-per-node anti-affinity.                                                                                                                                                                            | `null` (managed node `hostPath`)                                                                                                    |
| `priorityClassName`           | Optional Kubernetes priority class name assigned to executor pods                                                                                                                                                                                                                                                                                 | `null`                                                                                                                             |
| `dnsConfig`                   | Pod DNS configuration (e.g. `options.ndots`, `searches`, `nameservers`)                                                                                                                                                                                                                                                                             | `null`                                                                                                                             |
| `dnsPolicy`                   | Pod DNS policy (`ClusterFirst`, `Default`, `None`, etc.)                                                                                                                                                                                                                                                                                          | `null`                                                                                                                             |
| `terminationGracePeriodSeconds` | Seconds Kubernetes waits for executor pods to terminate gracefully before forcefully killing them. When set, also configure `config.max_shutdown_duration` to a few seconds less so the executor can drain in-flight work before Kubernetes sends SIGKILL. See [example](#example-termination-grace-period-configuration). | `null` (Kubernetes default: 30)                                                                                                    |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install my-release \
  --set image.tag=enterprise-v2.295.0 \
  --set mysql.mysqlUser=sampleUser \
  --set mysql.mysqlPassword=samplePassword \
  buildbuddy/buildbuddy-executor
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install my-release -f values.yaml buildbuddy/buildbuddy-executor
```

### Example configurations

Below are some examples of `.yaml` files with values that could be passed to the `helm`
command with the `-f` or `--values` flag to get started.

### Example bring your own executor configuration

```yaml
config:
  executor:
    app_target: "grpcs://remote.buildbuddy.io:443"
    local_cache_size_bytes: 50000000000 # 50GB
    api_key: "YOUR_EXECUTOR_ENABLED_API_KEY"
```

### Executor identity and metadata persistence

Executor registrations have distinct host, pod, and process identities:

- The executor generates a random host ID and stores it in
  `/buildbuddy/metadata/host_id`. BuildBuddy uses this ID for cache affinity.
- `MY_HOSTNAME` and `MY_NODE_NAME` contain the Kubernetes node name. The
  scheduler registration log correlates this hostname with the host ID and
  executor ID.
- `MY_POD_NAME` contains the Kubernetes pod name for monitoring and log
  correlation.
- The executor ID remains a random UUID generated on every process start, so a
  container restart in the same pod creates a distinct executor registration.

By default, `executorMetadataVolume` mounts a release-specific node `hostPath`
at `/buildbuddy/metadata`. A replacement pod on the same node reuses that
node's generated host ID. A pod scheduled on another node uses the ID already
stored on that node, or generates a new one. Replacing or deleting the node
also removes this identity unless the host path is retained outside the node.

The metadata volume is separate from `executor-data`, which remains an
`emptyDir` by default. This avoids making the executor cache and build data
node-persistent merely to preserve the host ID. If the legacy
`executorDataVolumeHostPath` is configured, the metadata volume defaults to
its existing `metadata` subdirectory so upgrades keep the stored host ID.

Multiple executor processes must not use the same metadata directory or host
ID. Whenever the effective metadata volume or `executor-data` is a node
`hostPath`, the chart adds required pod anti-affinity on
`kubernetes.io/hostname`, allowing at most one executor pod from the release
on each node. Rolling updates use zero surge and replace one executor at a time
by default so the new pod can schedule after the old pod leaves its node. An
explicit nonzero `strategy.rollingUpdate.maxUnavailable` is preserved. The
default three replicas therefore require three eligible Kubernetes nodes;
otherwise some executor pods remain pending.

Set `executorMetadataVolume` to any Kubernetes VolumeSource to customize the
storage. A custom source must be writable and exclusive to one replica; a
shared PVC is not safe for multiple executor processes. For ephemeral per-pod
identity and no automatic one-per-node constraint, use:

```yaml
executorMetadataVolume:
  emptyDir: {}
```

### Example deploy a cache proxy with the executors

Enable the bundled cache-proxy chart to automatically point the executors at
its in-cluster gRPC Service. An explicit `config.executor.cache_target` takes
precedence over the generated target. The cache proxy must use its own Cache
proxy key rather than the executor-enabled API key.

```yaml
config:
  executor:
    app_target: "grpcs://remote.buildbuddy.io:443"
    api_key: "YOUR_EXECUTOR_ENABLED_API_KEY"

proxy:
  enabled: true
  service:
    type: ClusterIP
  config:
    cache_proxy:
      api_key: "YOUR_CACHE_PROXY_API_KEY"
```

### Example DNS configuration

```yaml
dnsConfig:
  options:
    - name: ndots
      value: "3"
```

### Example termination grace period configuration

When increasing the pod termination grace period, also set `config.max_shutdown_duration`
(a top-level BuildBuddy config option) to a few seconds less. This gives the executor
process time to drain in-flight remote execution work before Kubernetes forcefully
terminates the pod.

```yaml
terminationGracePeriodSeconds: 60
config:
  max_shutdown_duration: 55s
```

### Example autoscaling configuration

```yaml
autoscaler:
  enabled: true
  minReplicas: 3
  maxReplicas: 100
  averageCPU: 90
  averageMemory: 50
  averageQueueLength: 5
```

## More examples

For more example `config:` blocks, see our [configuration docs](https://www.buildbuddy.io/docs/config#configuration-options).

### Local development

For local testing use [minikube](https://github.com/kubernetes/minikube)

Create local cluster using with specified Kubernetes version (e.g. `1.15.6`)

```bash
$ minikube start --kubernetes-version v1.15.6
```

Initialize helm

```bash
$ helm init
```

Above command is not required for Helm v3

Get dependencies

```bash
$ helm dependency update
```

Perform local installation

```bash
$ helm install . \
    --set image.tag=5.12.4 \
    --set mysql.mysqlUser=sampleUser \
    --set mysql.mysqlPassword=samplePassword
```

**Helm v3 command**

```bash
$ helm install . \
    --generate-name \
    --set image.tag=5.12.4 \
    --set mysql.mysqlUser=sampleUser \
    --set mysql.mysqlPassword=samplePassword
```
