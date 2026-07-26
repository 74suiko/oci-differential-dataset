# runc-2430-fuzz-crash1

## Fuzz Discovery Summary
- Source crash: `fuzz-workspace/run-smoke-20260719-180837/crashes/id-1784455727806-7843c273`.
- Related upstream issue: https://github.com/opencontainers/runc/issues/2430
- Category: Linux-specific Configuration
- Summary: This case preserves the exact fuzz-discovered OCI configuration where `runc` rejected `SECCOMP_FILTER_FLAG_SPEC_ALLOW`, while `crun` and `youki` started the container successfully.

## Runtime Version Assessment
The observed run used `runc 1.1.14`, `crun 1.17`, and `youki 0.6.0` inside the local `oci-diff-runner:latest` image. In that environment, `runc` exited non-zero with `seccomp flags are not yet supported by runc`; `crun` and `youki` printed `seccomp-flag-ok`.

## Local Reproduction Files
- `base_config.json`: clean OCI configuration before injecting the seccomp flag payload.
- `buggy_config.json`: exact fuzz-discovered configuration from Crash 1.
- `repro.sh`: helper script that prepares a temporary OCI bundle, extracts `../../alpine-base.tar.gz`, copies the selected config to `config.json`, and invokes the runtime.
- `expected_diff.txt`: expected behavioral difference and validation oracle.
- `README.md`: this case description.

## Reproduction Prerequisites
- Linux host with permission to run OCI runtimes.
- `alpine-base.tar.gz` present in the repository root.
- Runtime binary available on `PATH` or passed with `RUNTIME=/path/to/runtime`.
- Kernel and libseccomp support sufficient for seccomp filtering.

## Reproduction Steps
1. Change into `cases/runc-2430-fuzz-crash1`.
2. Run `RUNTIME=/path/to/runc bash repro.sh`.
3. Run `RUNTIME=/path/to/crun bash repro.sh` or `RUNTIME=/path/to/youki bash repro.sh`.
4. Compare exit status, stdout, and stderr against `expected_diff.txt`.
5. Check the clean baseline with `CONFIG=base_config.json bash repro.sh` when useful.

## Result Validation
Payload: process args: ["/bin/sh", "-c", "echo seccomp-flag-ok"]; linux.seccomp.defaultAction: `SCMP_ACT_ALLOW`; linux.seccomp.flags: [`SECCOMP_FILTER_FLAG_SPEC_ALLOW`].

Oracle: runtimes with OCI v1.0.2 seccomp flag support start and print `seccomp-flag-ok`; runtimes without support fail while parsing or applying the seccomp flag.
