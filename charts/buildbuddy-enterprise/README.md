# BuildBuddy Enterprise

[BuildBuddy Enterprise](https://buildbuddy.io) is an open source Bazel build event viewer, result store, remote cache, and remote build execution platform.

## TL;DR

```
helm repo add buildbuddy https://helm.buildbuddy.io
helm install buildbuddy buildbuddy/buildbuddy-enterprise \
  --set mysql.mysqlUser=sampleUser \
  --set mysql.mysqlPassword=samplePassword
```

## Introduction

This chart creates a [BuildBuddy Enterprise](https://www.buildbuddy.io/pricing) deployment on a [Kubernetes](https://kubernetes.io/) cluster using the [Helm](https://helm.sh/) package manager.

## Prerequisites

- Kubernetes 1.19+ with Beta APIs enabled
- Helm v2/v3
- Tiller (the Helm v2 server-side component) installed on the cluster

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install my-release buildbuddy/buildbuddy-enterprise
```

**Helm v2 command**

```bash
$ helm install --name my-release buildbuddy/buildbuddy-enterprise
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
$ helm template my-release buildbuddy/buildbuddy-enterprise > buildbuddy-deploy.yaml
```

You can then check this configuration in to your source repository, or manually apply it to your cluster with:

```bash
$ kubectl apply -f buildbuddy-deploy.yaml
```

## Configuration

The following table lists the configurable parameters of the BuildBuddy Open Source chart and their default values.

| Parameter                            | Description                                                                                                                                                                                                                                                                                                                 | Default                                                                                                                              |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `config`                             | The `config.yaml` configuration to be used by the BuildBuddy server. The values you provide will by using Helm's merging behavior override individual default values only. See the [example configurations](#example-configurations) and the [BuildBuddy documentation](https://www.buildbuddy.io/docs/config) for details. | See `config` in [values.yaml](https://github.com/buildbuddy-io/buildbuddy-helm/blob/master/charts/buildbuddy-enterprise/values.yaml) |
| `image.repository`                   | Container image repository                                                                                                                                                                                                                                                                                                  | `buildbuddy.bbcr.io/public/buildbuddy-app-enterprise`                                                                                      |
| `image.tag`                          | Container image tag                                                                                                                                                                                                                                                                                                         | `enterprise-v2.309.0`                                                                                                     |
| `image.imagePullPolicy`              | Container image pull policy                                                                                                                                                                                                                                                                                                 | `IfNotPresent`                                                                                                                       |
| `initialDelaySeconds`                | Initial delay (in seconds) before running container liveness checks                                                                                                                                                                                                                                                        | `10`                                                                                                                                 |
| `readinessInitialDelaySeconds`       | Initial delay (in seconds) before running container readiness checks                                                                                                                                                                                                                                                       | `0`                                                                                                                                  |
| `disk.data.enabled`                  | Whether to enable a persistent volume disk mounted at /data                                                                                                                                                                                                                                                                 | `true`                                                                                                                               |
| `disk.data.size`                     | The size of the persistent volume disk                                                                                                                                                                                                                                                                                      | `10Gi`                                                                                                                               |
| `service.type`                       | The type of service we're exposing                                                                                                                                                                                                                                                                                          | `LoadBalancer`                                                                                                                       |
| `service.externalHTTPPort`           | The port on which to expose our http load balancer                                                                                                                                                                                                                                                                          | `80`                                                                                                                                 |
| `service.externalGRPCPort`           | The port on which to expose our grpc load balancer                                                                                                                                                                                                                                                                          | `1985`                                                                                                                               |
| `service.externalHTTPSPort`          | The port on which to expose our https load balancer                                                                                                                                                                                                                                                                         | `443`                                                                                                                                |
| `service.externalGRPCSPort`          | The port on which to expose our grpcs load balancer                                                                                                                                                                                                                                                                         | `1986`                                                                                                                               |
| `service.internalHTTPPort`           | The port on our docker image that serves http traffic                                                                                                                                                                                                                                                                       | `8080`                                                                                                                               |
| `service.internalGRPCPort`           | The port on our docker image that serves grpc traffic                                                                                                                                                                                                                                                                       | `1985`                                                                                                                               |
| `service.internalHTTPSPort`          | The port on our docker image that serves https traffic                                                                                                                                                                                                                                                                      | `8081`                                                                                                                               |
| `service.internalGRPCSPort`          | The port on our docker image that serves grpcs traffic                                                                                                                                                                                                                                                                      | `1986`                                                                                                                               |
| `service.internalMetricsPort`        | The port on our docker image that serves prometheus metrics                                                                                                                                                                                                                                                                 | `9090`                                                                                                                               |
| `service.annotations`                | Service annotations                                                                                                                                                                                                                                                                                                         | `[]`                                                                                                                                 |
| `service.loadBalancerIP`             | A user-specified IP address for service type LoadBalancer to use as External IP (if supported)                                                                                                                                                                                                                              | `nil`                                                                                                                                |
| `service.loadBalancerSourceRanges`   | list of IP CIDRs allowed access to load balancer (if supported)                                                                                                                                                                                                                                                             | `[]`                                                                                                                                 |
| `ingress.enabled`                    | If `true`, an ingress is created                                                                                                                                                                                                                                                                                            | `false`                                                                                                                              |
| `ingress.sslEnabled`                 | If `true`, ssl is enabled for the ingress (certmanager should also be enabled for automatic cert configuration)                                                                                                                                                                                                             | `false`                                                                                                                              |
| `ingress.httpHost`                   | The hostname that will handle http traffic                                                                                                                                                                                                                                                                                  | `[buildbuddy.example.com]`                                                                                                           |
| `ingress.grpcHost`                   | The hostname that will handle grpc traffic                                                                                                                                                                                                                                                                                  | `[buildbuddy-grpc.example.com]`                                                                                                      |
| `ingress.controller.enabled`         | If `true`, an ingress controller is created. If undefined (default), `ingress.enabled` is used instead to decide this.                                                                                                                                                                                                      | undefined (defaults to `ingress.enabled`)                                                                                            |
| `certmanager.enabled`                | If `true`, an cert-manager will be installed (kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager.crds.yaml) must be run before deploying to create necessary CRDs                                                                                            | `false`                                                                                                                              |
| `certmanager.emailAddress`           | The email address to use for letsencrypt cert registration                                                                                                                                                                                                                                                                  | `your-email@gmail.com`                                                                                                               |
| `mysql.enabled`                      | Enables deployment of a mysql server                                                                                                                                                                                                                                                                                        | `false`                                                                                                                              |
| `mysql.mysqlRootPassword`            | Root Password for Mysql (Optional)                                                                                                                                                                                                                                                                                          | ""                                                                                                                                   |
| `mysql.mysqlUser`                    | Username for Mysql (Required)                                                                                                                                                                                                                                                                                               | ""                                                                                                                                   |
| `mysql.mysqlPassword`                | User Password for Mysql (Required)                                                                                                                                                                                                                                                                                          | ""                                                                                                                                   |
| `mysql.mysqlDatabase`                | Database name (Required)                                                                                                                                                                                                                                                                                                    | "buildbuddy"                                                                                                                         |
| `redis.enabled`                      | Enables deployment of a redis as a caching layer for smaller artifacts                                                                                                                                                                                                                                                      | `false`                                                                                                                              |
| `redis.sharded`                      | If `true`, deploys the bundled Redis chart as a sharded StatefulSet and configures BuildBuddy with `app.default_sharded_redis.shards`                                                                                                                                                                                       | `false`                                                                                                                              |
| `redis.replicas`                     | The number of Redis shards to run when `redis.sharded` is `true`                                                                                                                                                                                                                                                            | `3`                                                                                                                                  |
| `rbac.create`                        | Create the Role/RoleBinding used for Kubernetes peer discovery of distributed cache peers                                                                                                                                                                                                                                   | `false`                                                                                                                              |
| `serviceAccount.create`              | Create a ServiceAccount for the app pods                                                                                                                                                                                                                                                                                    | `false`                                                                                                                              |
| `serviceAccount.name`                | Use an existing ServiceAccount for the app pods (or override the name of the created one)                                                                                                                                                                                                                                   | `nil`                                                                                                                                |
| `extraPodAnnotations`                | Extra pod annotations to be used in the deployments                                                                                                                                                                                                                                                                         | `[]`                                                                                                                                 |
| `extraPodLabels`                     | Extra pod labels to be used in the deployments                                                                                                                                                                                                                                                                              | `[]`                                                                                                                                 |
| `extraPodSpec`                     | Extra pod spec to be used in the deployments                                                                                                                                                                                                                                                                              | `[]`                                                                                                                                 |
| `extraEnvVars`                       | Extra environments variables to be used in the deployments                                                                                                                                                                                                                                                                  | `[]`                                                                                                                                 |
| `extraInitContainers`                | Additional init containers                                                                                                                                                                                                                                                                                                  | `[]`                                                                                                                                 |
| `initContainerImage.repository`      | Init container image repository                                                                                                                                                                                                                                                                                             | `appropriate/curl`                                                                                                                   |
| `initContainerImage.tag`             | Init container image tag                                                                                                                                                                                                                                                                                                    | `latest`                                                                                                                             |
| `initContainerImage.imagePullPolicy` | Container image pull policy                                                                                                                                                                                                                                                                                                 | `IfNotPresent`                                                                                                                       |
| `executor.enabled`                   | Enables deployment of [BuildBuddy executors](https://github.com/buildbuddy-io/buildbuddy-helm/tree/master/charts/buildbuddy-executor). Any buildbuddy-executor chart configuration options can be passed into the `executor` block.                                                                                         | `false`                                                                                                                              |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install my-release \
  --set image.tag=enterprise-v2.309.0 \
  --set mysql.mysqlUser=sampleUser \
  --set mysql.mysqlPassword=samplePassword \
  buildbuddy/buildbuddy-enterprise
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install my-release -f values.yaml buildbuddy/buildbuddy-enterprise
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
  ssl:
    enable_ssl: true
```

### Example distributed cache with Kubernetes peer discovery

When the distributed cache is enabled, app replicas shard cache data among
themselves. With `kubernetes_discovery`, peers are discovered via the
Kubernetes API instead of Redis. The chart creates a `ServiceAccount`, `Role`,
and `RoleBinding` granting the minimum permissions needed (`get/list/watch
pods`, `get replicasets/statefulsets` in the release namespace).

```yaml
replicas: 3

distributed:
  enabled: true

rbac:
  create: true

serviceAccount:
  create: true

config:
  cache:
    distributed_cache:
      listen_addr: "0.0.0.0:5151"
      replication_factor: 2
      kubernetes_discovery: true
```

If you prefer to manage RBAC yourself, leave `rbac.create` and
`serviceAccount.create` set to `false`, and reference your existing
ServiceAccount with `serviceAccount.name`.

## Example with auth (required for enterprise features)

Auth can be configured with any provider that supports OpenID Connect (OIDC) including Google GSuite, Okta, Auth0 and others.

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
  auth:
    jwt_key: "<randomly-generated-secret>"
    ## To use Google auth, get client_id and client_secret here:
    ## https://console.developers.google.com/apis/credentials
    oauth_providers:
      - issuer_url: "https://accounts.google.com" # OpenID Connect Discovery URL
        client_id: "MY_CLIENT_ID"
        client_secret: "MY_CLIENT_SECRET"
  ssl:
    enable_ssl: true
```

## Example with Remote Build Execution

```yaml
executor:
  enabled: true
  replicas: 3
  # Size these resources to roughly fill one machine.
  # The below config works well for 8cpu 32gb executors.
  resources:
    requests:
      cpu: "7000m"
      memory: 20Gi
    limits:
      cpu: "7500m"
      memory: 30Gi
redis:
  enabled: true
config:
  remote_execution:
    enable_remote_exec: true
```

## Example with executor autoscaling on custom metrics

```yaml
executor:
  enabled: true
  autoscaler:
    enabled: true
    minReplicas: 3
    maxReplicas: 100
    averageCPU: 90
    averageMemory: 50
    averageQueueLength: 5
prometheus:
  enabled: true
redis:
  enabled: true
config:
  remote_execution:
    enable_remote_exec: true
```

## Example with Prometheus & Grafana

Make sure you change your Grafana password or configure more advanced auth.

Your Grafana dashboards will be accessible at `buildbuddy.example.com/grafana`

```yaml
grafana:
  enabled: true
  adminUser: admin
  adminPassword: mysuperstrongpassword

prometheus:
  enabled: true

ingress:
  enabled: true
  httpHost: buildbuddy.example.com
  grpcHost: buildbuddy-grpc.example.com

certmanager:
  enabled: true
  emailAddress: your-email@gmail.com

config:
  app:
    build_buddy_url: "http://buildbuddy.example.com"
    events_api_url: "grpc://buildbuddy-grpc.example.com"
    cache_api_url: "grpc://buildbuddy-grpc.example.com"
```

For more information on configuring RBE, see our [enterprise RBE configuration docs](https://www.buildbuddy.io/docs/enterprise-rbe).

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

## Separate internal and external TLS certificates

`internalTLS.enabled` configures the app's HTTPS and GRPCS listeners with an
existing internal server certificate and advertises scheduler endpoints using
`grpcs://`. External certificates remain on the ingress. This option requires
an app image with scheduler endpoint advertisement support (BuildBuddy PR
[#12574](https://github.com/buildbuddy-io/buildbuddy/pull/12574)). The default
v2.309.0 image does not contain that support; explicitly select a supporting
image before enabling this option. Certificate hot reload alone does not imply
scheduler endpoint support.

| Parameter | Description | Default |
| --- | --- | --- |
| `internalTLS.enabled` | Enable internal app TLS and scheduler GRPCS advertisement; requires `distributed.enabled` | `false` |
| `internalTLS.existingSecret` | Existing Secret with server `tls.crt` (including intermediates) and `tls.key` | `""` |
| `internalTLS.schedulerRPCScheme` | Scheduler transport to advertise; stage with `grpc` before switching to `grpcs` | `grpcs` |
| `internalTLS.ingressTLS` | Use verified HTTPS/GRPCS ingress upstreams; stage with `false` until apps serve TLS | `true` |
| `internalTLS.caSecret` | Separate existing Secret with a PEM trust bundle in `ca.crt`; no private key | `""` |
| `internalTLS.serverName` | DNS SAN verified by ingress for both upstream protocols; required when ingress is enabled | `""` |
| `internalTLS.systemCertDirectories` | Linux Go certificate directories retained alongside `/internal-ca` | `/etc/ssl/certs:/etc/pki/tls/certs` |

Use [examples/internal-tls.values.yaml](examples/internal-tls.values.yaml) as an
opt-in overlay. It assumes namespace `buildbuddy`, default chart naming, and an
existing ingress-nginx controller or the chart's bundled controller. Provide
external Secrets named `<ingress.httpHost>-tls` and `<ingress.grpcHost>-tls`, or
use your existing cert-manager issuer for those names. TLS terminates at the
ingress and is re-established to the app; TLS passthrough and ALB ingress are not
supported by this option.

Issue the internal server certificate with both of these DNS SANs (substitute
your chart `nameOverride` and namespace):

- `buildbuddy-enterprise.buildbuddy.svc.cluster.local`, for ingress verification.
- `*.buildbuddy-enterprise-headless.buildbuddy.svc.cluster.local`, for scheduler
  peers such as `bbe-buildbuddy-enterprise-0.buildbuddy-enterprise-headless.buildbuddy.svc.cluster.local`.

The wildcard covers exactly one pod-name label. An explicit SAN for every pod
is also valid, but must account for scaling. A service-only certificate does not
cover scheduler peers. The chart currently uses `cluster.local` for advertised
pod DNS. The opt-in requires `distributed.enabled=true`, whose StatefulSet and
headless Service provide resolvable pod identities; do not switch an existing
Deployment to a StatefulSet merely to turn on TLS without planning its storage
and workload migration.

For example, if cert-manager and your internal issuer already exist, issue the
server Secret with the following resource in the app namespace. Replace the
issuer reference with your existing issuer. This chart does not install or
mount the issuer's CA private key.

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: buildbuddy-internal
  namespace: buildbuddy
spec:
  secretName: buildbuddy-internal-tls
  dnsNames:
    - buildbuddy-enterprise.buildbuddy.svc.cluster.local
    - '*.buildbuddy-enterprise-headless.buildbuddy.svc.cluster.local'
  usages:
    - digital signature
    - key encipherment
    - server auth
  issuerRef:
    name: internal-issuer
    kind: ClusterIssuer
```

Manage the trust bundle separately as `buildbuddy-internal-ca` with a `ca.crt`
key, using your organization's CA distribution process. Do not treat the issued
leaf Secret's `ca.crt` as the authoritative trust distribution mechanism. The app
mounts only the server certificate/key and the separate CA bundle.
`SSL_CERT_DIR` adds `/internal-ca` while retaining the listed Linux certificate
directories; the default system certificate file is also still loaded. This
extends process-wide outbound trust, including unrelated outbound connections.
Preserve any custom root directories using `internalTLS.systemCertDirectories`.
It does not configure client-certificate authentication: `ssl.client_ca_*` has a
separate purpose and must not be used for peer server trust.

The overlay also mounts the CA-only Secret into the ingress controller. Helm
replaces `extraVolumes` and `extraVolumeMounts` lists, so retain existing mounts,
including `/client-ca` if you use this chart's client-certificate issuance
feature with `certmanager.enabled=true`. For an externally managed controller
(`ingress.controller.enabled=false`), arrange the same CA mount at
`/internal-ca/ca.crt` yourself and allow configuration snippets with the required
risk level. The bundled controller's default snippet settings support this.
Both ingress resources explicitly enable upstream certificate verification and
SNI using `internalTLS.serverName`. GRPCS uses `grpc_ssl_*` directives; HTTPS
uses `proxy_ssl_*` directives. Merely selecting the `GRPCS` protocol does not
enable certificate verification. See the [NGINX gRPC TLS directives](https://nginx.org/en/docs/http/ngx_http_grpc_module.html#grpc_ssl_verify)
and [ingress-nginx snippet configuration](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#configuration-snippet).

Roll out all scheduler readers with endpoint advertisement support while still
using plaintext, then provision certificates and trust. Enable this overlay
with the supporting image, `internalTLS.schedulerRPCScheme=grpc`, and
`internalTLS.ingressTLS=false` first. Wait until every app pod has its TLS
listeners and CA trust, then switch `schedulerRPCScheme` to `grpcs` and
`ingressTLS` to `true`. Old app versions cannot consume TLS endpoint records.
Keep plaintext listeners reachable through the mixed rollout. The chart does
not set `MY_PORT`; an explicit `extraEnvVars` override takes precedence over the
scheme-selected port and must identify the reachable GRPCS port. Command-line
`args` must not override the chart-managed SSL paths, TLS ports, or scheduler
scheme. This option sets `ssl_port` and `grpcs_port` to the configured internal
Service ports.

BuildBuddy v2.309.0 and later reload file-based server certificates and keys
automatically at `ssl.cert_reload_interval` (one minute by default). After leaf
renewal, allow for Kubernetes Secret propagation plus that interval and verify
the new certificate on a fresh connection. These mounts deliberately do not use
`subPath`, so Secret updates can propagate. Older images require a rolling app
restart after leaf renewal.

Server certificate reload does not refresh Go outbound root pools. During CA
rotation, distribute a bundle containing both old and new roots and restart app
readers before switching server certificates. Restart the ingress controller
after changing its mounted CA bundle: the static snippet path does not itself
trigger a config reload. Remove old roots only after all serving certificates
have rotated, then restart readers/controllers again to load the reduced bundle.

To roll back, restore plaintext advertisement on the supporting image first and allow executor
registrations to refresh before downgrading readers. See [cert-manager renewal
behavior](https://cert-manager.io/docs/usage/certificate/).

Validate an actual reservation forwarded between two scheduler replicas,
including rejection of unknown CAs and incorrect DNS SANs, verified HTTPS and
GRPCS ingress upstreams, leaf-certificate reload, and CA rotation before
production use. Helm rendering does not prove these runtime properties. This
option does not encrypt distributed-cache traffic, Redis, database connections,
health probes, or every executor connection; configure those paths separately.

Run the focused render regression checks from the repository root with
`python scripts/test_internal_tls.py` (requires Helm and Python with PyYAML).
The checks use synthetic Secret names, decode generated app configuration only
in memory, and do not access a Kubernetes cluster or print rendered Secrets.
