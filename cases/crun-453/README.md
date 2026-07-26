# crun-453

## Upstream Issue Summary
- Title: invalid seccomp action `SCMP_ACT_LOG`
- URL: https://github.com/containers/crun/issues/453
- Category: Linux-specific Configuration
- Summary: This case reduces the upstream issue to a small OCI bundle that can be used for differential runtime testing.

## Runtime Version Assessment
Use the runtime version discussed in the upstream issue as the affected implementation and compare it with a fixed or reference runtime. Some cases require specific host support such as cgroup v1, cgroup v2, seccomp, eBPF device filtering, user namespaces, or hook execution support.

## Buggy Version Identification
Issue text does not name a release. Git log matched `47dd153de924` (`seccomp: support SCMP_ACT_LOG`); use parent `8aa48d5db588` as the pre-fix buggy baseline.

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
1. Change into `cases/crun-453`.
2. Run `bash repro.sh` with the default runtime.
3. Compare implementations by rerunning with explicit binaries, for example `RUNTIME=/path/to/reference-runtime bash repro.sh` and `RUNTIME=/path/to/buggy-runtime bash repro.sh`.
4. Check the clean baseline with `CONFIG=base_config.json bash repro.sh` when useful.
5. Compare exit code, stdout, stderr, and side effects against `expected_diff.txt`.

## Result Validation
Payload: process args: ["/bin/sh", "-c", "echo seccomp-log-action-453; true"]; linux.resources.devices: [{"allow": false, "access": "rwm"}]; linux.seccomp: {"defaultAction": "SCMP_ACT_LOG", "architectures": ["SCMP_ARCH_X86_64"], "syscalls": [{"names": ["read", "write", "exit", "exit_group"], "action": "SCMP_ACT_ALLOW"}]}

Oracle: A supporting runtime accepts SCMP_ACT_LOG and starts. An unsupported runtime fails during seccomp setup.

## Additional Validation Note (2026-07-19)
Using only `buggy_config.json` with the provided `alpine-base.tar.gz` rootfs, the original unsupported-`SCMP_ACT_LOG` behavior was not reproduced with runc 1.1.14, youki 0.6.0, or crun 1.17. All three runtimes accepted the seccomp action and printed `seccomp-log-action-453`. Reproduction appears to require a runtime or libseccomp environment that lacks `SCMP_ACT_LOG` support.
