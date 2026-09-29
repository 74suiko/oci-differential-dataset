#!/usr/bin/env bash
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runtime="${RUNTIME:-youki}"
config="${CONFIG:-$case_dir/buggy_config.json}"
rootfs_tar="${ROOTFS_TAR:-$case_dir/../../alpine-base.tar.gz}"
bundle="${BUNDLE:-$(mktemp -d)}"
container_id="${CONTAINER_ID:-youki-3699-mount-runbindable-$$}"
cleanup() {
  "$runtime" delete -f "$container_id" >/dev/null 2>&1 || true
  rm -f /tmp/oci-diff-youki-3699-mount-runbindable-*; rm -rf /tmp/oci-diff-youki-3699-mount-runbindable-source "$bundle"
}
trap cleanup EXIT
mkdir -p "$bundle/rootfs"
tar -xzf "$rootfs_tar" -C "$bundle/rootfs"
cp "$config" "$bundle/config.json"
mkdir -p "/tmp/oci-diff-youki-3699-mount-runbindable-source/nested"
cd "$bundle"
set +e
"$runtime" run "$container_id" >"$bundle/result.txt" 2>&1
status=$?
set -e
printf 'status=%s\n' "$status"
cat "$bundle/result.txt"
