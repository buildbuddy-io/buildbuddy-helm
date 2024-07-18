# BuildBuddy Open Source

[BuildBuddy](https://buildbuddy.io) is an open source Bazel build event viewer, result store, and remote cache.

## TL;DR

```
helm repo add buildbuddy https://helm.buildbuddy.io
helm install buildbuddy buildbuddy/buildbuddy \
  --set mysql.mysqlUser=sampleUser \
  --set mysql.mysqlPassword=samplePassword
```

## Introduction

This chart creates a [BuildBuddy Open Source](https://github.com/buildbuddy-io/buildbuddy/) deployment on a [Kubernetes](https://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

## Prerequisites

- Kubernetes 1.19+ with Beta APIs enabled
- Helm v2/v3
- Tiller (the Helm v2 server-side component) installed on the cluster

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install my-release buildbuddy/buildbuddy
```

**Helm v2 command**

```bash
$ helm install --name my-release buildbuddy/buildbuddy
```

The command deploys BuildBuddy on the Kubernetes cluster in the default configuration. The [configuration](#configuration)
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
$ helm upgrade my-release -f my-values.yaml buildbuddy/buildbuddy-enterprise
```

## Writing deployment to a file

You can write your Kubernetes deployment configuration to a file with release name `my-release`:

```bash
$ helm template my-release buildbuddy/buildbuddy > buildbuddy-deploy.yaml
```

You can then check this configuration in to your source repository, or manually apply it to your cluster with:

```bash
$ kubectl apply -f buildbuddy-deploy.yaml
```

## Configuration

The following table lists the configurable parameters of the BuildBuddy Open Source chart and their default values.

| Parameter                            | Description                                                                                                                                                                                                                                                                                                                 | Default                                                                                                                   |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `config`                             | The `config.yaml` configuration to be used by the BuildBuddy server. The values you provide will by using Helm's merging behavior override individual default values only. See the [example configurations](#example-configurations) and the [BuildBuddy documentation](https://www.buildbuddy.io/docs/config) for details. | See `config` in [values.yaml](https://github.com/buildbuddy-io/buildbuddy-helm/blob/master/charts/buildbuddy/values.yaml) |
| `image.repository`                   | Container image repository                                                                                                                                                                                                                                                                                                  | `gcr.io/flame-public/buildbuddy-app-onprem`                                                                               |
| `image.tag`                          | Container image tag                                                                                                                                                                                                                                                                                                         | `v2.74.0`                                                                                                                  |
| `image.imagePullPolicy`              | Container image pull policy                                                                                                                                                                                                                                                                                                 | `IfNotPresent`                                                                                                            |
| `disk.data.enabled`                  | Whether to enable a persistent volume disk mounted at /data                                                                                                                                                                                                                                                                 | `true`                                                                                                                    |
| `disk.data.size`                     | The size of the persistent volume disk                                                                                                                                                                                                                                                                                      | `10Gi`                                                                                                                    |
| `service.type`                       | The type of service we're exposing                                                                                                                                                                                                                                                                                          | `LoadBalancer`                                                                                                            |
| `service.externalHTTPPort`           | The port on which to expose our http load balancer                                                                                                                                                                                                                                                                          | `80`                                                                                                                      |
| `service.externalGRPCPort`           | The port on which to expose our grpc load balancer                                                                                                                                                                                                                                                                          | `1985`                                                                                                                    |
| `service.externalHTTPSPort`          | The port on which to expose our https load balancer                                                                                                                                                                                                                                                                         | `443`                                                                                                                     |
| `service.externalGRPCSPort`          | The port on which to expose our grpcs load balancer                                                                                                                                                                                                                                                                         | `1986`                                                                                                                    |
| `service.internalHTTPPort`           | The port on our docker image that serves http traffic                                                                                                                                                                                                                                                                       | `8080`                                                                                                                    |
| `service.internalGRPCPort`           | The port on our docker image that serves grpc traffic                                                                                                                                                                                                                                                                       | `1985`                                                                                                                    |
| `service.internalHTTPSPort`          | The port on our docker image that serves https traffic                                                                                                                                                                                                                                                                      | `8081`                                                                                                                    |
| `service.internalGRPCSPort`          | The port on our docker image that serves grpcs traffic                                                                                                                                                                                                                                                                      | `1986`                                                                                                                    |
| `service.internalMetricsPort`        | The port on our docker image that serves prometheus metrics traffic                                                                                                                                                                                                                                                         | `9090`                                                                                                                    |
| `service.annotations`                | Service annotations                                                                                                                                                                                                                                                                                                         | `{}`                                                                                                                      |
| `service.loadBalancerIP`             | A user-specified IP address for service type LoadBalancer to use as External IP (if supported)                                                                                                                                                                                                                              | `nil`                                                                                                                     |
| `service.loadBalancerSourceRanges`   | list of IP CIDRs allowed access to load balancer (if supported)                                                                                                                                                                                                                                                             | `[]`                                                                                                                      |
| `ingress.enabled`                    | If `true`, an ingress is created                                                                                                                                                                                                                                                                                            | `false`                                                                                                                   |
| `ingress.sslEnabled`                 | If `true`, ssl is enabled for the ingress (certmanager should also be enabled for automatic cert configuration)                                                                                                                                                                                                             | `false`                                                                                                                   |
| `ingress.httpHost`                   | The hostname that will handle http traffic                                                                                                                                                                                                                                                                                  | `[buildbuddy.example.com]`                                                                                                |
| `ingress.grpcHost`                   | The hostname that will handle grpc traffic                                                                                                                                                                                                                                                                                  | `[buildbuddy-grpc.example.com]`                                                                                           |
| `ingress.controller.enabled`         | If `true`, an ingress controller is created. If undefined (default), `ingress.enabled` is used instead to decide this.                                                                                                                                                                                                      | undefined (defaults to `ingress.enabled`)                                                                                 |
| `certmanager.enabled`                | If `true`, an cert-manager will be installed (kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager.crds.yaml) must be run before deploying to create necessary CRDs                                                                                            | `false`                                                                                                                   |
| `certmanager.emailAddress`           | The email address to use for letsencrypt cert registration                                                                                                                                                                                                                                                                  | `your-email@gmail.com`                                                                                                    |
| `mysql.enabled`                      | Enables deployment of a mysql server                                                                                                                                                                                                                                                                                        | `false`                                                                                                                   |
| `mysql.mysqlRootPassword`            | Root Password for Mysql (Optional)                                                                                                                                                                                                                                                                                          | ""                                                                                                                        |
| `mysql.mysqlUser`                    | Username for Mysql (Required)                                                                                                                                                                                                                                                                                               | ""                                                                                                                        |
| `mysql.mysqlPassword`                | User Password for Mysql (Required)                                                                                                                                                                                                                                                                                          | ""                                                                                                                        |
| `mysql.mysqlDatabase`                | Database name (Required)                                                                                                                                                                                                                                                                                                    | "buildbuddy"                                                                                                              |
| `extraPodAnnotations`                | Extra pod annotations to be used in the deployments                                                                                                                                                                                                                                                                         | `{}`                                                                                                                      |
| `extraPodLabels`                     | Extra pod labels to be used in the deployments                                                                                                                                                                                                                                                                              | `{}`                                                                                                                      |
| `extraLabels`                        | Extra labels to be used in all resources                                                                                                                                                                                                                                                                              | `{}`                                                                                                                      |
| `extraEnvVars`                       | Extra environments variables to be used in the deployments                                                                                                                                                                                                                                                                  | `[]`                                                                                                                      |
| `extraInitContainers`                | Additional init containers                                                                                                                                                                                                                                                                                                  | `[]`                                                                                                                      |
| `initContainerImage.repository`      | Init container image repository                                                                                                                                                                                                                                                                                             | `appropriate/curl`                                                                                                        |
| `initContainerImage.tag`             | Init container image tag                                                                                                                                                                                                                                                                                                    | `latest`                                                                                                                  |
| `initContainerImage.imagePullPolicy` | Container image pull policy                                                                                                                                                                                                                                                                                                 | `IfNotPresent`                                                                                                            |
| `sidecar.name`                       | Sidecar Container name                                                                                                                                                                                                                                                                                                 | `nil`                                                                                                            |
| `sidecar.repository`                 | Sidecar Container image repository                                                                                                                                                                                                                                                                                                  | `nil`                                                                                                            |
| `sidecar.tag`                        | Sidecar Container image tag                                                                                                                                                                                                                                                                                                 | `nil`                                                                                                            |
| `sidecar.pullPolicy`                 | Sidecar Container image pull policy                                                                                                                                                                                                                                                                                                 | `nil`                                                                                                            |
| `sidecar.envVars`                    | Environment Variables to be used in the Sidecar Container                                                                                                                                                                                                                                                                                                 | `nil`                                                                                                            |
| `sidecar.ports`                      | Sidecar Container ports                                                                                                                                                                                                                                                                                                 | `nil`                                                                                                            |
| `sidecar.command`                    | Sidecar Container Commands                                                                                                                                                                                                                                                                                                 | `nil`                                                                                                            |
| `sidecar.args`                      | Sidecar Container Command Arguments                                                                                                                                                                                                                                                                                                 | `nil`                                                                                                            |
| `sidecar.livenessProbe`              | Sidecar Container Liveness Probe                                                                                                                                                                                                                                                                                                 | `nil`                                                                                                            |
| `sidecar.readinessProbe`             | Sidecar Container Readiness Probe                                                                                                                                                                                                                                                                                                 | `nil`                                                                                                            |
| `sidecar.resources`                  | Sidecar Container resources                                                                                                                                                                                                                                                                                                 | `nil`                                                                                                            |
| `sidecar.volumeMounts`               | Sidecar Container Volume Mounts                                                                                                                                                                                                                                                                                                 | `nil`                                                                                                            |
| `deploymentType`                     | Strategy used to replace pods in Deployment                                                                                                                                                                                                                                                                                                 | `RollingUpdate`                                                                                                            |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install my-release \
  --set image.tag=v2.74.0\
  --set mysql.mysqlUser=sampleUser \
  --set mysql.mysqlPassword=samplePassword \
  buildbuddy/buildbuddy
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install my-release -f values.yaml buildbuddy/buildbuddy
```

### Example configurations

Below are some examples of `.yaml` files with values that could be passed to the `helm`
command with the `-f` or `--values` flag to get started.

### Example MySQL configuration

```yaml
mysql:
  enabled: true
  mysqlUser: "sampleUser"
  mysqlPassword: "samplePassword"
```

### Example external database configuration

```yaml
mysql:
  enabled: false

config:
  database:
    ## mysql:     "mysql://<USERNAME>:<PASSWORD>@tcp(<HOST>:3306)/<DATABASE_NAME>"
    ## sqlite:    "sqlite3:///tmp/buildbuddy-enterprise.db"
    data_source: "" # Either set this or mysql.enabled, not both!
```

### Example ingress and certs configuration

Note: make sure to run `kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager.crds.yaml` to install CRDs before deploying this configuration.

```yaml
ingress:
  enabled: true
  sslEnabled: true
  httpHost: buildbuddy.example.com
  grpcHost: buildbuddy-grpc.example.com

mysql:
  enabled: true
  mysqlUser: "sampleUser"
  mysqlPassword: "samplePassword"

certmanager:
  enabled: true
  emailAddress: your-email@gmail.com

config:
  app:
    build_buddy_url: "https://buildbuddy.example.com"
    events_api_url: "grpcs://buildbuddy-grpc.example.com"
    cache_api_url: "grpcs://buildbuddy-grpc.example.com"
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
