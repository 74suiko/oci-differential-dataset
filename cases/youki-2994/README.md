# youki-2994

## Upstream Issue Summary
- Title: [Bug]: youki does not conform with OCI runtime spec
- URL: https://github.com/youki-dev/youki/issues/2994
- Category: Linux-specific Configuration
- Summary: This case reduces the upstream issue to a small OCI bundle that can be used for differential runtime testing.

## Runtime Version Assessment
Use the runtime version discussed in the upstream issue as the affected implementation and compare it with a fixed or reference runtime. Some cases require specific host support such as cgroup v1, cgroup v2, seccomp, eBPF device filtering, user namespaces, or hook execution support.

## Buggy Version Identification
The issue explicitly reports youki `Version 0.4.1` in its System and Setup Info, with `Commit VERGEN_IDEMPOTENT_OUTPUT`; the user reproduced it by installing youki from `main` with a dev profile on 2024-11-14. The issue page is closed and links PR #3181 for the lifecycle-state fix. Local git history maps PR #3181 to `38822f90da250e9e00ddb807e9fbdd78ba21156e` (`running create_runtime hook after container is set to created (#3181)`, 2025-06-07). Use its parent `c2ab4de08c033ba6dae867fb3cc5bd393572fb3d` as the pre-fix buggy baseline. `git describe` identifies the parent as `v0.5.3-67-gc2ab4de08c03` and the fix as contained before `v0.5.4` (`v0.5.4~16`).

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
1. Change into `cases/youki-2994`.
2. Run `bash repro.sh` with the default runtime.
3. Compare implementations by rerunning with explicit binaries, for example `RUNTIME=/path/to/reference-runtime bash repro.sh` and `RUNTIME=/path/to/buggy-runtime bash repro.sh`.
4. Check the clean baseline with `CONFIG=base_config.json bash repro.sh` when useful.
5. Compare exit code, stdout, stderr, and side effects against `expected_diff.txt`.

## Result Validation
Payload: process args: ["true"]; linux.resources.devices: [{"allow": false, "access": "rwm"}]; hooks: createRuntime

Oracle: Run the same buggy_config.json with a reference runtime and an affected runtime. A valid reproduction is a stable difference in exit status, stdout, stderr, runtime state, or documented side effects for the same OCI payload.
