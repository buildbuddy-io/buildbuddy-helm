# BuildBuddy Redis

BuildBuddy Redis handles caching for [BuildBuddy](https://buildbuddy.io).

## TL;DR

```
helm repo add buildbuddy https://helm.buildbuddy.io
helm install buildbuddy buildbuddy/buildbuddy-redis
```

## Introduction

This chart creates a [BuildBuddy Redis]( deployment on a [Kubernetes](https://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

## Prerequisites

- Kubernetes 1.15+ with Beta APIs enabled
- Helm v2/v3
- Tiller (the Helm v2 server-side component) installed on the cluster

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install my-release buildbuddy/buildbuddy-redis
```

**Helm v2 command**

```bash
$ helm install --name my-release buildbuddy/buildbuddy-redis
```

The command deploys BuildBuddy Redis on the Kubernetes cluster in the default configuration. The [configuration](#configuration)
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
$ helm upgrade my-release -f my-values.yaml buildbuddy/buildbuddy-redis
```

## Writing deployment to a file

You can write your Kubernetes deployment configuration to a file release name `my-release`:

```bash
$ helm template my-release buildbuddy/buildbuddy-redis > buildbuddy-deploy.yaml
```

You can then check this configuration in to your source repository, or manually apply it to your cluster with:

```bash
$ kubectl apply -f buildbuddy-deploy.yaml
```

## Configuration

The following table lists the configurable parameters of the BuildBuddy Open Source chart and their default values.

| Parameter                  | Description                                                                                                                                                                                                                                                                                                                  | Default                                                                                                                            |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `image.repository`         | Container image repository                                                                                                                                                                                                                                                                                                   | `redis`                                                                               |
| `image.tag`                | Container image tag                                                                                                                                                                                                                                                                                                          | `5.0.4`                                                                                                   |
| `image.imagePullPolicy`    | Container image pull policy                                                                                                                                                                                                                                                                                                  | `IfNotPresent`                                                                                                                     |
| `service.internalRedisPort` | The port on which redis will listen for traffic                                                                                                                                                                                                                                                                        | `6379`                                                                                                                             |
| `service.annotations`      | Service annotations                                                                                                                                                                                                                                                                                                          | `[]`                                                                                                                               |
| `extraPodAnnotations`      | Extra pod annotations to be used in the deployments                                                                                                                                                                                                                                                                          | `[]`                                                                                                                               |
| `extraPodLabels`           | Extra pod labels to be used in the deployments                                                                                                                                                                                                                                                                               | `[]`                                                                                                                               |
| `extraEnvVars`             | Extra environments variables to be used in the deployments                                                                                                                                                                                                                                                                   | `[]`                                                                                                                               |
| `extraInitContainers`      | Additional init containers                                                                                                                                                                                                                                                                                                   | `[]`                                                                                                                               |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install my-release \
  --set image.tag=5.0.3 \
  buildbuddy/buildbuddy-redis
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install my-release -f values.yaml buildbuddy/buildbuddy-redis
```

