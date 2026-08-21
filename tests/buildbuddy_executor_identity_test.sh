#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
chart="$repo_root/charts/buildbuddy-executor"
values_file="$(mktemp)"
trap 'rm -f "$values_file"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local description="$3"
  [[ "$haystack" == *"$needle"* ]] || fail "$description"
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local description="$3"
  [[ "$haystack" != *"$needle"* ]] || fail "$description"
}

render_deployment() {
  helm template test "$chart" --show-only templates/deployment.yaml "$@"
}

render_config() {
  helm template test "$chart" --show-only templates/config.yaml "$@" \
    | awk '/^  config.yaml: / {print $2}' \
    | base64 --decode
}

default_deployment="$(render_deployment)"
assert_contains "$default_deployment" $'- name: MY_POD_NAME\n              valueFrom:\n                fieldRef:\n                  fieldPath: metadata.name' \
  "default deployment should expose the pod name"
assert_contains "$default_deployment" $'- name: MY_HOSTNAME\n              valueFrom:\n                fieldRef:\n                  fieldPath: spec.nodeName' \
  "default registration hostname should use the node name"
assert_contains "$default_deployment" $'- name: MY_NODE_NAME\n              valueFrom:\n                fieldRef:\n                  fieldPath: spec.nodeName' \
  "default deployment should expose the node name"
assert_contains "$default_deployment" $'- mountPath: /buildbuddy/metadata/\n              name: executor-metadata' \
  "default deployment should mount executor metadata separately"
assert_contains "$default_deployment" 'path: "/var/lib/buildbuddy/executor-metadata/default/test-buildbuddy-executor"' \
  "default metadata should use a release-specific node hostPath"
assert_contains "$default_deployment" 'topologyKey: kubernetes.io/hostname' \
  "hostPath metadata should require one executor per node"
assert_contains "$default_deployment" $'rollingUpdate:\n      maxSurge: 0\n      maxUnavailable: 1' \
  "hostPath metadata should use a non-surging rolling update"

default_config="$(render_config)"
assert_contains "$default_config" 'metadata_directory: /buildbuddy/metadata/' \
  "default config should store generated host IDs in the metadata volume"
assert_not_contains "$default_config" 'host_id:' \
  "default config should keep the executor-generated host ID"

printf '%s\n' 'executorMetadataVolume:' '  emptyDir: {}' >"$values_file"
ephemeral_deployment="$(render_deployment --values "$values_file")"
assert_contains "$ephemeral_deployment" $'- name: executor-metadata\n          emptyDir: {}' \
  "custom metadata VolumeSource should render unchanged"
assert_not_contains "$ephemeral_deployment" 'topologyKey: kubernetes.io/hostname' \
  "non-hostPath metadata should not force node anti-affinity"
assert_not_contains "$ephemeral_deployment" 'maxSurge: 0' \
  "non-hostPath metadata should keep the configured deployment strategy"

printf '%s\n' 'executorMetadataVolume:' '  csi:' \
  '    driver: metadata.csi.example' '    fsType: ext4' \
  '    volumeAttributes:' '      purpose: executor-identity' >"$values_file"
csi_deployment="$(render_deployment --values "$values_file")"
assert_contains "$csi_deployment" $'csi:\n            driver: metadata.csi.example\n            fsType: ext4\n            volumeAttributes:\n              purpose: executor-identity' \
  "nested custom metadata VolumeSource should render unchanged"
assert_not_contains "$csi_deployment" 'topologyKey: kubernetes.io/hostname' \
  "custom CSI metadata should not force node anti-affinity"

printf '%s\n' 'executorMetadataVolume:' '  hostPath:' \
  '    path: /mnt/executor-metadata' '    type: DirectoryOrCreate' \
  'strategy:' '  type: RollingUpdate' '  rollingUpdate:' \
  '    maxSurge: 2' '    maxUnavailable: 40%' \
  'affinity:' '  nodeAffinity:' \
  '    preferredDuringSchedulingIgnoredDuringExecution:' \
  '      - weight: 1' '        preference:' '          matchExpressions:' \
  '            - key: storage' '              operator: Exists' \
  '  podAntiAffinity:' '    requiredDuringSchedulingIgnoredDuringExecution:' \
  '      - labelSelector:' '          matchLabels:' \
  '            workload: other' '        topologyKey: topology.kubernetes.io/zone' \
  '    preferredDuringSchedulingIgnoredDuringExecution:' \
  '      - weight: 10' '        podAffinityTerm:' '          labelSelector:' \
  '            matchLabels:' '              workload: preferred' \
  '          topologyKey: kubernetes.io/hostname' >"$values_file"
merged_deployment="$(render_deployment --values "$values_file")"
assert_contains "$merged_deployment" 'path: /mnt/executor-metadata' \
  "custom hostPath metadata should render unchanged"
assert_contains "$merged_deployment" 'nodeAffinity:' \
  "generated anti-affinity should preserve node affinity"
assert_contains "$merged_deployment" 'topologyKey: topology.kubernetes.io/zone' \
  "generated anti-affinity should preserve required pod anti-affinity"
assert_contains "$merged_deployment" 'workload: preferred' \
  "generated anti-affinity should preserve preferred pod anti-affinity"
assert_contains "$merged_deployment" 'app.kubernetes.io/instance: test' \
  "hostPath metadata should append release anti-affinity"
assert_contains "$merged_deployment" $'maxSurge: 0\n      maxUnavailable: 40%' \
  "hostPath rollout should preserve explicit maxUnavailable"

printf '%s\n' 'strategy:' '  type: Recreate' >"$values_file"
recreate_deployment="$(render_deployment --values "$values_file")"
assert_contains "$recreate_deployment" $'strategy:\n    type: Recreate' \
  "hostPath metadata should preserve Recreate strategy"
assert_not_contains "$recreate_deployment" 'rollingUpdate:' \
  "Recreate strategy should not render rolling update options"

printf '%s\n' 'executorMetadataVolume:' '  emptyDir: {}' >"$values_file"
ephemeral_legacy_deployment="$(render_deployment --values "$values_file" \
  --set executorDataVolumeHostPath=/var/lib/buildbuddy-executor)"
assert_contains "$ephemeral_legacy_deployment" 'topologyKey: kubernetes.io/hostname' \
  "executor-data hostPath should require one executor per node"

legacy_deployment="$(render_deployment \
  --set executorDataVolumeHostPath=/var/lib/buildbuddy-executor)"
assert_contains "$legacy_deployment" 'path: /var/lib/buildbuddy-executor' \
  "executorDataVolumeHostPath should keep rendering the executor-data hostPath"
assert_contains "$legacy_deployment" 'path: "/var/lib/buildbuddy-executor/metadata"' \
  "legacy hostPath should preserve its existing metadata directory"
assert_contains "$legacy_deployment" 'topologyKey: kubernetes.io/hostname' \
  "legacy node metadata should require one executor per node"

echo "PASS: buildbuddy executor identity rendering"
