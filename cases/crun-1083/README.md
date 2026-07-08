# crun-1083

## Upstream Issue Summary
- Title: runc incompatibility wrt. cgroup memory limits
- URL: https://github.com/containers/crun/issues/1083
- Category: Linux-specific Configuration
- Summary: This case reduces the upstream issue to a small OCI bundle that can be used for differential runtime testing.

## Runtime Version Assessment
Use the runtime version discussed in the upstream issue as the affected implementation and compare it with a fixed or reference runtime. Some cases require specific host support such as cgroup v1, cgroup v2, seccomp, eBPF device filtering, user namespaces, or hook execution support.

## Buggy Version Identification
Local dataset notes identify `crun version 1.7.1.0.0.0.6-258c` as the buggy build and `crun version 1.27.1.0.0.0.29-856f4` as fixed. Git log also matched `3880f04675f5` (`cgroup: always enable controller`); parent `258c237f5947` is the pre-fix baseline.

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
1. Change into `cases/crun-1083`.
2. Run `bash repro.sh` with the default runtime.
3. Compare implementations by rerunning with explicit binaries, for example `RUNTIME=/path/to/reference-runtime bash repro.sh` and `RUNTIME=/path/to/buggy-runtime bash repro.sh`.
4. Check the clean baseline with `CONFIG=base_config.json bash repro.sh` when useful.
5. Compare exit code, stdout, stderr, and side effects against `expected_diff.txt`.

## Result Validation
Payload: process args: ["/bin/sh", "-c", "echo memory-limit-1083; cat /sys/fs/cgroup/memory/memory.limit_in_bytes 2>/dev/null || cat /sys/fs/cgroup/memory.max 2>/dev/null || true"]; linux.resources.memory: {"limit": 67108864, "swap": 134217728}; linux.resources.devices: [{"allow": false, "access": "rwm"}]

Oracle: The buggy crun build prints max for the memory limit, while runc and fixed crun print 67108864 for the configured 64 MiB limit.
