#!/usr/bin/env bash
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runtime="${RUNTIME:-runc}"
config="${CONFIG:-$case_dir/buggy_config.json}"
rootfs_tar="${ROOTFS_TAR:-$case_dir/../../alpine-base.tar.gz}"
bundle="${BUNDLE:-$(mktemp -d)}"
container_id="${CONTAINER_ID:-runc-5493-$$}"
cleanup() {
  "$runtime" delete -f "$container_id" >/dev/null 2>&1 || true

  rm -rf "$bundle"
}
trap cleanup EXIT
mkdir -p "$bundle/rootfs"
tar -xzf "$rootfs_tar" -C "$bundle/rootfs"
variant="${VARIANT:-conflicting-values}"
python3 - "$config" "$bundle/config.json" "$variant" <<'PY'
import json,sys
src,dst,var=sys.argv[1:]
c=json.load(open(src))
c['process']['args']=['/bin/sh','-c','ulimit -n; exit 0']
c['process']['rlimits']=[{'type':'RLIMIT_NOFILE','hard':64,'soft':32}]
if var == 'conflicting-values': c['process']['rlimits'].append({'type':'RLIMIT_NOFILE','hard':128,'soft':64})
elif var == 'identical-values': c['process']['rlimits'].append({'type':'RLIMIT_NOFILE','hard':64,'soft':32})
json.dump(c,open(dst,'w'),indent=4)
PY
cd "$bundle"
set +e
"$runtime" run "$container_id" >"$bundle/result.txt" 2>&1
status=$?
set -e
printf 'status=%s\n' "$status"
cat "$bundle/result.txt"
