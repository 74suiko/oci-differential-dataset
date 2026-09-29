# runc-5182-poststart-sleep

## Upstream Issue Summary
- Root identifier: `R60-hook-failure/poststart-sleep`
- Runtime: `runc`
- Category: POSIX-platform Hooks
- Title: Poststart failure cleanup: poststart-sleep
- Evidence: https://github.com/opencontainers/runc/issues/5182
- Audit status: 已有 issue / 直接讨论

This directory imports one runtime-specific variant from the revision audit. It follows the repository's five-file case format. The imported audit record is evidence for case construction; it is not a claim that the cited fix has been rebuilt, merged, or verified on current runtime HEAD.

## Local Reproduction Files
- `base_config.json`: clean OCI configuration.
- `buggy_config.json`: configuration containing the issue-specific payload.
- `repro.sh`: configurable reproduction helper.
- `expected_diff.txt`: expected behavior and validation oracle.
- `README.md`: provenance and prerequisites.

## Prerequisites
- Linux host with the `runc` binary or `RUNTIME=/path/to/runtime`.
- Repository rootfs archive at `alpine-base.tar.gz`.
- Root or the host capabilities required by the case; mount, seccomp, hook, and terminal cases have additional requirements.
- The supplied audit did not run a fixed/new runtime for this import. Compare an affected version with a reference or fixed version before reporting a pass.

## Reproduction
```bash
cd cases/runc-5182-poststart-sleep
RUNTIME=/path/to/runc bash repro.sh
CONFIG=base_config.json RUNTIME=/path/to/runc bash repro.sh
```

For lifecycle cases, inspect the printed status and marker result. For terminal cases, run from a TTY. For mount and seccomp cases, treat missing kernel support or privileges as environment failures.

## Validation Note
The related PR changes poststart ordering but explicitly does not implement destruction after a poststart failure. This is a tracked known behavior, not a newly discovered or fully fixed case.
