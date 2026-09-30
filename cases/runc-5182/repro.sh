#!/usr/bin/env bash
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runtime="${RUNTIME:-runc}"
config="${CONFIG:-$case_dir/buggy_config.json}"
rootfs_tar="${ROOTFS_TAR:-$case_dir/../../alpine-base.tar.gz}"
bundle="${BUNDLE:-$(mktemp -d)}"
container_id="${CONTAINER_ID:-runc-5182-$$}"
cleanup() {
  "$runtime" delete -f "$container_id" >/dev/null 2>&1 || true
  rm -f /tmp/oci-diff-runc-5182-*
  rm -rf "$bundle"
}
trap cleanup EXIT
mkdir -p "$bundle/rootfs"
tar -xzf "$rootfs_tar" -C "$bundle/rootfs"
variant="${VARIANT:-poststart-fail}"
rm -f /tmp/oci-diff-runc-5182-*
python3 - "$case_dir/base_config.json" "$bundle/config.json" "$variant" <<'PY'
import json,sys
src,dst,var=sys.argv[1:]
c=json.load(open(src))
marker='/tmp/oci-diff-runc-5182-poststop'
cmd='sleep 1; touch /tmp/oci-diff-runc-5182-poststart; exit 1' if var=='poststart-sleep' else 'touch /tmp/oci-diff-runc-5182-poststart; exit 1'
c['process']['args']=['/bin/true']
c['hooks']={'poststart':[{'path':'/bin/sh','args':['sh','-c',cmd]}], 'poststop':[{'path':'/bin/sh','args':['sh','-c','touch '+marker]}]}
json.dump(c,open(dst,'w'),indent=4)
PY
cd "$bundle"
set +e
"$runtime" create "$container_id" >"$bundle/result.txt" 2>&1
create_status=$?
"$runtime" start "$container_id" >>"$bundle/result.txt" 2>&1
start_status=$?
"$runtime" delete -f "$container_id" >>"$bundle/result.txt" 2>&1 || true
set -e
printf 'create_status=%s\nstart_status=%s\n' "$create_status" "$start_status"
cat "$bundle/result.txt"
if [ -f /tmp/oci-diff-runc-5182-poststop ]; then echo marker-present; else echo marker-missing; fi
