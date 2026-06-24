#!/bin/bash
set -euo pipefail

case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
issue_id="runc-2928"
runtime="${RUNTIME:-runc}"
config="${CONFIG:-$case_dir/buggy_config.json}"
rootfs_tar="${ROOTFS_TAR:-$case_dir/../../alpine-base.tar.gz}"
bundle="$(mktemp -d "${TMPDIR:-/tmp}/${issue_id}.XXXXXX")"
container_id="${CONTAINER_ID:-${issue_id}-$$}"

cleanup() {
    "$runtime" delete -f "$container_id" >/dev/null 2>&1 || true
    rm -rf "$bundle"
    rm -rf /tmp/runc-2928-relative-mount-source
}
trap cleanup EXIT

mkdir -p "$bundle/rootfs"
tar -xzf "$rootfs_tar" -C "$bundle/rootfs"
cp "$config" "$bundle/config.json"
mkdir -p /tmp/runc-2928-relative-mount-source
printf 'runc-2928-marker\n' > /tmp/runc-2928-relative-mount-source/marker
mkdir -p "$bundle/rootfs/templated_config"

cd "$bundle"
"$runtime" run "$container_id"
