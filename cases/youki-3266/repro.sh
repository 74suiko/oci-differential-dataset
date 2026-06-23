#!/usr/bin/env bash
set -euo pipefail

case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_file="${CONFIG:-$case_dir/buggy_config.json}"
runtime="${RUNTIME:-runc}"
rootfs_tar="${ROOTFS_TAR:-$case_dir/../../alpine-base.tar.gz}"
bundle="${BUNDLE:-$(mktemp -d)}"
container_id="${CONTAINER_ID:-youki-3266-$RANDOM}"

cleanup() {
  sudo -n "$runtime" delete -f "$container_id" >/dev/null 2>&1 || true
  sudo -n rm -rf "$bundle" >/dev/null 2>&1 || true
}
trap cleanup EXIT

mkdir -p "$bundle/rootfs"
if [[ ! -f "$rootfs_tar" ]]; then
  echo "missing rootfs tar: $rootfs_tar" >&2
  echo "set ROOTFS_TAR=/path/to/alpine-base.tar.gz or place alpine-base.tar.gz at the repository root" >&2
  exit 2
fi

sudo -n tar -xzf "$rootfs_tar" -C "$bundle/rootfs"
cp "$config_file" "$bundle/config.json"

sudo -n "$runtime" run -b "$bundle" "$container_id"
