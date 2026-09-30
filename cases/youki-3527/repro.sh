#!/usr/bin/env bash
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runtime="${RUNTIME:-youki}"
config="${CONFIG:-$case_dir/buggy_config.json}"
rootfs_tar="${ROOTFS_TAR:-$case_dir/../../alpine-base.tar.gz}"
bundle="${BUNDLE:-$(mktemp -d)}"
container_id="${CONTAINER_ID:-youki-3527-$$}"
cleanup() {
  "$runtime" delete -f "$container_id" >/dev/null 2>&1 || true

  rm -rf "$bundle"
}
trap cleanup EXIT
mkdir -p "$bundle/rootfs"
tar -xzf "$rootfs_tar" -C "$bundle/rootfs"
variant="${VARIANT:-24x80}"
python3 - "$config" "$bundle/config.json" "$variant" <<'PY'
import json,sys
src,dst,var=sys.argv[1:]
c=json.load(open(src))
c['process']['terminal']=False
c['process'].pop('consoleSize',None)
if var != 'base':
    h,w=var.split('x',1)
    c['process']['terminal']=True
    c['process']['consoleSize']={'height':int(h),'width':int(w)}
    c['process']['args']=['/bin/sh','-c','stty size 2>/dev/null || true']
json.dump(c,open(dst,'w'),indent=4)
PY
cd "$bundle"
set +e
timeout "${TIMEOUT:-10}" "$runtime" run "$container_id" >"$bundle/result.txt" 2>&1
status=$?
set -e
printf 'status=%s\n' "$status"
cat "$bundle/result.txt"
