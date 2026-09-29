#!/usr/bin/env bash
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runtime="${RUNTIME:-youki}"
config="${CONFIG:-$case_dir/buggy_config.json}"
rootfs_tar="${ROOTFS_TAR:-$case_dir/../../alpine-base.tar.gz}"
bundle="${BUNDLE:-$(mktemp -d)}"
container_id="${CONTAINER_ID:-youki-3758-prestart-sleep-$$}"
cleanup() {
  "$runtime" delete -f "$container_id" >/dev/null 2>&1 || true
  rm -f /tmp/oci-diff-youki-3758-prestart-sleep-*; rm -rf /tmp/oci-diff-youki-3758-prestart-sleep-source "$bundle"
}
trap cleanup EXIT
mkdir -p "$bundle/rootfs"
tar -xzf "$rootfs_tar" -C "$bundle/rootfs"
cp "$config" "$bundle/config.json"
rm -f "/tmp/oci-diff-youki-3758-prestart-sleep-poststop"
cd "$bundle"
set +e
"$runtime" create "$container_id"; "$runtime" start "$container_id" >"$bundle/result.txt" 2>&1
status=$?
"$runtime" delete -f "$container_id" >>"$bundle/result.txt" 2>&1 || true
set -e
printf 'status=%s\n' "$status"
cat "$bundle/result.txt"
if [ -f "/tmp/oci-diff-youki-3758-prestart-sleep-poststop" ]; then echo "marker-present"; else echo "marker-missing"; fi
