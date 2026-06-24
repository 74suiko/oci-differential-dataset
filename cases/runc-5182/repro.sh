#!/usr/bin/env bash
set -euo pipefail

case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_file="${CONFIG:-$case_dir/buggy_config.json}"
runtime="${RUNTIME:-runc}"
rootfs_tar="${ROOTFS_TAR:-$case_dir/../../alpine-base.tar.gz}"
bundle="${BUNDLE:-$(mktemp -d)}"
container_id="${CONTAINER_ID:-runc-5182-$RANDOM}"

cleanup() {
  "$runtime" delete -f "$container_id" >/dev/null 2>&1 || true
  rm -rf "$bundle"
  rm -f /tmp/post-start /tmp/post-stop
}
trap cleanup EXIT

echo "Preparing OCI bundle for runc-5182"
rm -f /tmp/post-start /tmp/post-stop
mkdir -p "$bundle/rootfs"
tar -xzf "$rootfs_tar" -C "$bundle/rootfs"
cp "$config_file" "$bundle/config.json"

cd "$bundle"
echo "Creating container; the poststart hook is expected to fail"
set +e
"$runtime" create "$container_id"
create_status=$?
"$runtime" start "$container_id" >/dev/null 2>&1
start_status=$?
"$runtime" delete -f "$container_id" >/dev/null 2>&1
delete_status=$?
set -e

printf 'create_status=%s
start_status=%s
delete_status=%s
' "$create_status" "$start_status" "$delete_status"
if [ -f /tmp/post-stop ]; then
  echo "poststop-ran"
else
  echo "poststop-missing"
fi
