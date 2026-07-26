# runc-4014

## Upstream Issue Summary
- Title: Undefined (and potentially incorrect) behavior when pids limit is set to 0
- URL: https://github.com/opencontainers/runc/issues/4014
- Category: Linux-specific Configuration
- Summary: This case reduces the upstream issue to a small OCI bundle that can be used for differential runtime testing.

## Runtime Version Assessment
Use the runtime version discussed in the upstream issue as the affected implementation and compare it with a fixed or reference runtime. Some cases require specific host support such as cgroup v1, cgroup v2, seccomp, eBPF device filtering, user namespaces, or hook execution support.

## Buggy Version Identification
Issue text does not name a release. Git log matched the pids.limit fix series, including `3b75374cc797` (`runtime-spec: update pids.limit handling to match new guidance`); use parent `eec1f7e34b33` as the pre-fix baseline.

## Local Reproduction Files
- `base_config.json`: clean OCI configuration before injecting the issue-specific payload.
- `buggy_config.json`: modified OCI configuration containing the payload.
- `repro.sh`: helper script that prepares a temporary OCI bundle, extracts `../../alpine-base.tar.gz`, copies the selected config to `config.json`, and invokes the runtime.
- `expected_diff.txt`: expected behavioral difference and validation oracle.
- `README.md`: this case description.

## Reproduction Prerequisites
- Linux host with permission to run OCI runtimes.
- `alpine-base.tar.gz` present in the repository root.
- Runtime binary available on `PATH` or passed with `RUNTIME=/path/to/runtime`.
- Case-specific kernel or cgroup features available when required by `expected_diff.txt`.

## Reproduction Steps
1. Change into `cases/runc-4014`.
2. Run `bash repro.sh` with the default runtime.
3. Compare implementations by rerunning with explicit binaries, for example `RUNTIME=/path/to/reference-runtime bash repro.sh` and `RUNTIME=/path/to/buggy-runtime bash repro.sh`.
4. Check the clean baseline with `CONFIG=base_config.json bash repro.sh` when useful.
5. Compare exit code, stdout, stderr, and side effects against `expected_diff.txt`.

## Result Validation
Payload: process args: ["/bin/sh", "-c", "cat /sys/fs/cgroup/pids/pids.max 2>/dev/null || cat /sys/fs/cgroup/pids.max 2>/dev/null"]; linux.resources.pids: {"limit": 0}; linux.resources.devices: [{"allow": false, "access": "rwm"}]

Oracle: Compare the effective pids.max value. The case exposes whether pids.limit=0 is interpreted as unlimited, inherited, or otherwise undefined.

## Additional Validation Note (2026-07-19)
Using only `buggy_config.json` with the provided `alpine-base.tar.gz` rootfs, no divergent or obviously incorrect `pids.limit=0` behavior was reproduced with runc 1.1.14, youki 0.6.0, or crun 1.17. All three runtimes printed `max` for `pids.max`. Reproducing the historical ambiguity appears to require an affected runtime revision or a host cgroup configuration where `pids.limit=0` is interpreted differently.
