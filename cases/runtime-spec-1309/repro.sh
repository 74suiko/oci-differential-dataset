#!/usr/bin/env bash
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runtime="${RUNTIME:-runc}"
config="${CONFIG:-$case_dir/buggy_config.json}"
rootfs_tar="${ROOTFS_TAR:-$case_dir/../../alpine-base.tar.gz}"
bundle="${BUNDLE:-$(mktemp -d)}"
container_id="${CONTAINER_ID:-runtime-spec-1309-$$}"
cleanup() {
  "$runtime" delete -f "$container_id" >/dev/null 2>&1 || true
  rm -f /tmp/oci-diff-runtime-spec-1309-second
  rm -rf "$bundle"
}
trap cleanup EXIT
mkdir -p "$bundle/rootfs"
tar -xzf "$rootfs_tar" -C "$bundle/rootfs"
variant="${VARIANT:-fail}"
rm -f /tmp/oci-diff-runtime-spec-1309-second
python3 - "$case_dir/base_config.json" "$bundle/config.json" "$variant" <<'PY'
import json,sys
src,dst,var=sys.argv[1:]
c=json.load(open(src))
first='sleep 4; exit 1' if var=='sleep' else 'exit 1'
c['process']['args']=['/bin/true']
c['hooks']={'poststop':[{'path':'/bin/sh','args':['sh','-c',first]}, {'path':'/bin/sh','args':['sh','-c','touch /tmp/oci-diff-runtime-spec-1309-second']}] }
json.dump(c,open(dst,'w'),indent=4)
PY
cd "$bundle"
set +e
"$runtime" create "$container_id" >"$bundle/result.txt" 2>&1
create_status=$?
"$runtime" start "$container_id" >>"$bundle/result.txt" 2>&1 || true
"$runtime" delete -f "$container_id" >>"$bundle/result.txt" 2>&1
delete_status=$?
set -e
printf 'create_status=%s\ndelete_status=%s\n' "$create_status" "$delete_status"
cat "$bundle/result.txt"
if [ -f /tmp/oci-diff-runtime-spec-1309-second ]; then echo marker-present; else echo marker-missing; fi
