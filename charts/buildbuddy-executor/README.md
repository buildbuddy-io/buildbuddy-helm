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
| `image.repository`            | Container image repository                                                                                                                                                                                                                                                                                                                        | `gcr.io/flame-public/buildbuddy-executor-enterprise`                                                                               |
| `image.tag`                   | Container image tag                                                                                                                                                                                                                                                                                                                               | `enterprise-v2.175.0`                                                                                                                |
| `image.imagePullPolicy`       | Container image pull policy                                                                                                                                                                                                                                                                                                                       | `IfNotPresent`                                                                                                                     |
| `disk.data.enabled`           | Whether to enable a persistent volume disk mounted at /data                                                                                                                                                                                                                                                                                       | `true`                                                                                                                             |
| `disk.data.size`              | The size of the persistent volume disk                                                                                                                                                                                                                                                                                                            | `10Gi`                                                                                                                             |
| `service.internalHTTPPort`    | The port on our docker image that serves http traffic                                                                                                                                                                                                                                                                                             | `8080`                                                                                                                             |
| `service.internalGRPCPort`    | The port on our docker image that serves grpc traffic                                                                                                                                                                                                                                                                                             | `1985`                                                                                                                             |
| `service.internalMetricsPort` | The port on our docker image that serves prometheus traffic                                                                                                                                                                                                                                                                                       | `9090`                                                                                                                             |
| `extraPodAnnotations`         | Extra pod annotations to be used in the deployments                                                                                                                                                                                                                                                                                               | `[]`                                                                                                                               |
| `extraPodLabels`              | Extra pod labels to be used in the deployments                                                                                                                                                                                                                                                                                                    | `[]`                                                                                                                               |
| `extraEnvVars`                | Extra environments variables to be used in the deployments                                                                                                                                                                                                                                                                                        | `[]`                                                                                                                               |
| `extraInitContainers`         | Additional init containers                                                                                                                                                                                                                                                                                                                        | `[]`                                                                                                                               |
| `extraContainers`             | Additional containers                                                                                                                                                                                                                                                                                                                             | `[]`                                                                                                                               |
| `customExecutorCommand`       | Custom command for running the executor                                                                                                                                                                                                                                                                                                           | `null`                                                                                                                             |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install my-release \
  --set image.tag=enterprise-v2.175.0 \
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
