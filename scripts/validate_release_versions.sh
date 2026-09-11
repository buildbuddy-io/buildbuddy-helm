#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "validate_release_versions: $*" >&2
  exit 1
}

yq_bin=${YQ:-}
if [[ -z $yq_bin ]]; then
  yq_bin=$(command -v yq || true)
fi
[[ -n $yq_bin ]] || fail "mikefarah/yq v4 is required"
yq_version=$("$yq_bin" --version 2>&1 || true)
case "$yq_version" in
  *mikefarah/yq*version\ v4.*) ;;
  *) fail "mikefarah/yq v4 is required (found: ${yq_version:-unknown yq})" ;;
esac

if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [repository-root]" >&2
  exit 2
fi
repo=${1:-${BUILD_WORKSPACE_DIRECTORY:-}}
[[ -n "$repo" ]] || fail "repository root is required"
charts="$repo/charts"

read_yaml() {
  local file=$1 expression=$2 value
  value=$("$yq_bin" eval --exit-status --unwrapScalar "$expression" "$file") ||
    fail "$file: could not read $expression"
  [[ $value != *$'\n'* ]] || fail "$file: $expression returned multiple values"
  printf '%s\n' "$value"
}

read_dependency_version() {
  local file=$1 dependency=$2 value
  value=$(DEPENDENCY="$dependency" "$yq_bin" eval --exit-status --unwrapScalar '
    [.dependencies[] | select(.name == strenv(DEPENDENCY)) | .version]
    | select(length == 1)
    | .[0]
  ' "$file") || fail "$file: expected one dependency named $dependency"
  printf '%s\n' "$value"
}

expect_equal() {
  local actual=$1 expected=$2 description=$3
  [[ $actual == "$expected" ]] ||
    fail "$description: got '$actual', want '$expected'"
}

image_prefix() {
  case "$1" in
    buildbuddy) echo v ;;
    buildbuddy-executor|buildbuddy-enterprise|buildbuddy-enterprise-cache-proxy) echo enterprise-v ;;
    buildbuddy-redis) echo -n ;;
    *) fail "unknown chart '$1'" ;;
  esac
}

check_chart() {
  local root=$1 expected_name=$2 expected_version=${3:-}
  local actual_name chart_version app_version image_tag
  actual_name=$(read_yaml "$root/Chart.yaml" '.name')
  chart_version=$(read_yaml "$root/Chart.yaml" '.version')
  app_version=$(read_yaml "$root/Chart.yaml" '.appVersion')
  image_tag=$(read_yaml "$root/values.yaml" '.image.tag')

  expect_equal "$actual_name" "$expected_name" "$root: chart name"
  expect_equal "$image_tag" "$(image_prefix "$expected_name")$app_version" \
    "$root: image.tag"
  if [[ -n $expected_version ]]; then
    expect_equal "$chart_version" "$expected_version" "$root: chart version"
  fi
}

temporary_directory=$(mktemp -d)
trap 'rm -rf "$temporary_directory"' EXIT

bundled_chart_root() {
  local parent=$1 child=$2 required=$3 directory archive extracted
  directory="$parent/charts/$child"
  if [[ -d $directory ]]; then
    printf '%s\n' "$directory"
    return
  fi

  archive="$parent/charts/$child-$required.tgz"
  [[ -f $archive ]] || fail "$parent: missing $archive"
  extracted=$(mktemp -d "$temporary_directory/bundle.XXXXXX")
  tar -xzf "$archive" -C "$extracted" || fail "$archive: cannot extract"
  [[ -d $extracted/$child ]] || fail "$archive: missing $child directory"
  printf '%s\n' "$extracted/$child"
}

check_dependency() {
  local parent=$1 child=$2 required locked bundled
  required=$(read_dependency_version "$parent/requirements.yaml" "$child")
  locked=$(read_dependency_version "$parent/requirements.lock" "$child")
  expect_equal "$locked" "$required" "$parent: $child lock"

  bundled=$(bundled_chart_root "$parent" "$child" "$required")
  check_chart "$bundled" "$child" "$required"

  if [[ $child == buildbuddy-executor ]]; then
    check_dependency "$bundled" buildbuddy-enterprise-cache-proxy
  fi
}

for chart in buildbuddy buildbuddy-executor buildbuddy-enterprise \
  buildbuddy-enterprise-cache-proxy buildbuddy-redis; do
  check_chart "$charts/$chart" "$chart"
done
check_dependency "$charts/buildbuddy-executor" buildbuddy-enterprise-cache-proxy
check_dependency "$charts/buildbuddy-enterprise" buildbuddy-executor
check_dependency "$charts/buildbuddy-enterprise" buildbuddy-redis
