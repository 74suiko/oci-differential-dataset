# crun-1783

## Upstream Issue Summary
- Title: cannot resolve `null` under rootfs
- URL: https://github.com/containers/crun/issues/1783
- Category: Filesystem & Mounts
- Summary: This case reduces the upstream issue to a small OCI bundle that can be used for differential runtime testing.

## Runtime Version Assessment
Use the runtime version discussed in the upstream issue as the affected implementation and compare it with a fixed or reference runtime. Some cases require specific host support such as cgroup v1, cgroup v2, seccomp, eBPF device filtering, user namespaces, or hook execution support.

## Buggy Version Identification
Issue text does not name a release. Git log matched `7407bbc9a5bc` (`Revert "chroot_realpath: do not return non-existing paths"`); use parent `073b9b862268` as the pre-fix buggy baseline.

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
1. Change into `cases/crun-1783`.
2. Run `bash repro.sh` with the default runtime.
3. Compare implementations by rerunning with explicit binaries, for example `RUNTIME=/path/to/reference-runtime bash repro.sh` and `RUNTIME=/path/to/buggy-runtime bash repro.sh`.
4. Check the clean baseline with `CONFIG=base_config.json bash repro.sh` when useful.
5. Compare exit code, stdout, stderr, and side effects against `expected_diff.txt`.

## Result Validation
Payload: process args: ["sh"]; linux.resources.devices: [{"allow": false, "access": "rwm"}]

Oracle: Run the same buggy_config.json with a reference runtime and an affected runtime. A valid reproduction is a stable difference in exit status, stdout, stderr, runtime state, or documented side effects for the same OCI payload.

## Additional Validation Note (2026-07-19)
Using only `buggy_config.json` with the provided `alpine-base.tar.gz` rootfs, the original `null` resolution issue was not reproduced with runc 1.1.14, youki 0.6.0, or crun 1.17. In a non-TTY run, the terminal-enabled config failed or timed out because no usable console was attached; with a pseudo-TTY, the runtimes entered the shell and timed out without showing the reported path-resolution failure. Reproduction appears to require the original terminal/console conditions and affected crun behavior.
