# runc-2928

## Upstream Issue Summary
- Title: runc@master failing with Moby CI: mount destination templated_config not absolute
- URL: https://github.com/opencontainers/runc/issues/2928
- Category: Filesystem & Mounts
- Summary: This case reduces the upstream issue to a small OCI bundle that can be used for differential runtime testing.

## Runtime Version Assessment
Use the runtime version discussed in the upstream issue as the affected implementation and compare it with a fixed or reference runtime. Some cases require specific host support such as cgroup v1, cgroup v2, seccomp, eBPF device filtering, user namespaces, or hook execution support.

## Buggy Version Identification
Issue text explicitly reports the failing runc revision `d279ebd97d8832020e2c6f50cc3a11d0499a4690`. It also identifies the regression as PR #2917, including `2192670a2430` (`libct/configs/validate: validate mounts`) whose parent is `1f1e91b1a09b`.

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
1. Change into `cases/runc-2928`.
2. Run `bash repro.sh` with the default runtime.
3. Compare implementations by rerunning with explicit binaries, for example `RUNTIME=/path/to/reference-runtime bash repro.sh` and `RUNTIME=/path/to/buggy-runtime bash repro.sh`.
4. Check the clean baseline with `CONFIG=base_config.json bash repro.sh` when useful.
5. Compare exit code, stdout, stderr, and side effects against `expected_diff.txt`.

## Result Validation
Payload: process args: ["/bin/sh", "-c", "cat /templated_config/marker 2>/dev/null || echo mount-not-visible"]; linux.resources.devices: [{"allow": false, "access": "rwm"}]; relative mount destinations: [{"destination": "templated_config", "type": "bind", "source": "/tmp/runc-2928-relative-mount-source", "options": ["rbind", "ro"]}]

Oracle: Strict builds report that templated_config is not an absolute mount destination. Compatibility builds warn or start and may expose the marker file.
