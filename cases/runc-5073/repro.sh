#!/usr/bin/env bash
set -euo pipefail

case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_file="${CONFIG:-$case_dir/buggy_config.json}"
runtime="${RUNTIME:-runc}"
rootfs_tar="${ROOTFS_TAR:-$case_dir/../../alpine-base.tar.gz}"
bundle="${BUNDLE:-$(mktemp -d)}"
container_id="${CONTAINER_ID:-runc-5073-$RANDOM}"

cleanup() {
  "$runtime" delete -f "$container_id" >/dev/null 2>&1 || true
  rm -rf "$bundle"
}
trap cleanup EXIT

echo "Preparing OCI bundle for runc-5073"
mkdir -p "$bundle/rootfs"
tar -xzf "$rootfs_tar" -C "$bundle/rootfs"
cp "$config_file" "$bundle/config.json"

cd "$bundle"
echo "Running runc-5073 with $runtime"
"$runtime" run "$container_id"
