#!/usr/bin/env bash
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
runtime="${RUNTIME:-youki}"
config="${CONFIG:-$case_dir/buggy_config.json}"
rootfs_tar="${ROOTFS_TAR:-$case_dir/../../alpine-base.tar.gz}"
bundle="${BUNDLE:-$(mktemp -d)}"
container_id="${CONTAINER_ID:-youki-3758-$$}"
cleanup() {
  "$runtime" delete -f "$container_id" >/dev/null 2>&1 || true
  rm -f /tmp/oci-diff-youki-3758-poststop
  rm -rf "$bundle"
}
trap cleanup EXIT
mkdir -p "$bundle/rootfs"
tar -xzf "$rootfs_tar" -C "$bundle/rootfs"
variant="${VARIANT:-createRuntime-nonzero}"
rm -f /tmp/oci-diff-youki-3758-poststop
python3 - "$case_dir/base_config.json" "$bundle/config.json" "$variant" <<'PY'
import json,sys
src,dst,var=sys.argv[1:]
c=json.load(open(src))
c['process']['args']=['/bin/true']
c.pop('hooks',None)
marker='/tmp/oci-diff-youki-3758-poststop'
if var != 'base':
    if var.startswith('createRuntime-'): stage='createRuntime'
    elif var.startswith('prestart-'): stage='prestart'
    else: stage='createContainer'
    fail='sleep 4; exit 1' if var.endswith('sleep') else 'exit 7'
    c['hooks']={stage:[{'path':'/bin/sh','args':['sh','-c',fail]}], 'poststop':[{'path':'/bin/sh','args':['sh','-c','touch '+marker]}]}
    if var == 'createRuntime-timeout': c['hooks'][stage][0]['timeout']=1
json.dump(c,open(dst,'w'),indent=4)
PY
cd "$bundle"
set +e
"$runtime" create "$container_id" >"$bundle/result.txt" 2>&1
create_status=$?
"$runtime" start "$container_id" >>"$bundle/result.txt" 2>&1 || true
"$runtime" delete -f "$container_id" >>"$bundle/result.txt" 2>&1 || true
set -e
printf 'create_status=%s\n' "$create_status"
cat "$bundle/result.txt"
if [ -f /tmp/oci-diff-youki-3758-poststop ]; then echo marker-present; else echo marker-missing; fi
