#!/usr/bin/env bash
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runtime="${RUNTIME:-crun}"
config="${CONFIG:-$case_dir/buggy_config.json}"
rootfs_tar="${ROOTFS_TAR:-$case_dir/../../alpine-base.tar.gz}"
bundle="${BUNDLE:-$(mktemp -d)}"
container_id="${CONTAINER_ID:-crun-2220-$$}"
cleanup() {
  "$runtime" delete -f "$container_id" >/dev/null 2>&1 || true

  rm -rf "$bundle"
}
trap cleanup EXIT
mkdir -p "$bundle/rootfs"
tar -xzf "$rootfs_tar" -C "$bundle/rootfs"
variant="${VARIANT:-errno-default}"
python3 - "$config" "$bundle/config.json" "$variant" <<'PY'
import json,sys
src,dst,var=sys.argv[1:]
c=json.load(open(src))
c.pop('seccomp',None)
if var != 'base':
    rule={'names':['getpid'],'action':'SCMP_ACT_ERRNO'}
    if var == 'allow-with-errno': rule['errnoRet']=13
    c.setdefault('linux',{})['seccomp']={'defaultAction':'SCMP_ACT_ALLOW','syscalls':[rule]}
c['process']['args']=['/bin/sh','-c','getpid >/dev/null 2>&1; echo seccomp_status:$?']
json.dump(c,open(dst,'w'),indent=4)
PY
cd "$bundle"
set +e
"$runtime" run "$container_id" >"$bundle/result.txt" 2>&1
status=$?
set -e
printf 'status=%s\n' "$status"
cat "$bundle/result.txt"
