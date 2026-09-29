# crun-r44-mount-runbindable

## Upstream Issue Summary
- Root identifier: `R44-mount-propagation/runbindable`
- Runtime: `crun`
- Category: Filesystem & Mounts
- Title: Recursive unbindable mount propagation
- Evidence: https://github.com/containers/crun/commit/ea4672d34ca7057ea46d537f0183bddfef250e9c
- Audit status: 已有修复代码

This directory imports one runtime-specific variant from the revision audit. It follows the repository's five-file case format. The imported audit record is evidence for case construction; it is not a claim that the cited fix has been rebuilt, merged, or verified on current runtime HEAD.

## Local Reproduction Files
- `base_config.json`: clean OCI configuration.
- `buggy_config.json`: configuration containing the issue-specific payload.
- `repro.sh`: configurable reproduction helper.
- `expected_diff.txt`: expected behavior and validation oracle.
- `README.md`: provenance and prerequisites.

## Prerequisites
- Linux host with the `crun` binary or `RUNTIME=/path/to/runtime`.
- Repository rootfs archive at `alpine-base.tar.gz`.
- Root or the host capabilities required by the case; mount, seccomp, hook, and terminal cases have additional requirements.
- The supplied audit did not run a fixed/new runtime for this import. Compare an affected version with a reference or fixed version before reporting a pass.

## Reproduction
```bash
cd cases/crun-r44-mount-runbindable
RUNTIME=/path/to/crun bash repro.sh
CONFIG=base_config.json RUNTIME=/path/to/crun bash repro.sh
```

For lifecycle cases, inspect the printed status and marker result. For terminal cases, run from a TTY. For mount and seccomp cases, treat missing kernel support or privileges as environment failures.

## Validation Note
The audit identifies a missing MS_REC component for recursive propagation. The cited source fix was not rebuilt or executed during this import.
