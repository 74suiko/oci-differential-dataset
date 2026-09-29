# crun-r79-seccomp-allow-with-errno

## Upstream Issue Summary
- Root identifier: `R79-seccomp-rule-errno/allow-with-errno`
- Runtime: `crun`
- Category: Linux-specific Configuration
- Title: Seccomp allow rule with errno-specific filter state
- Evidence: https://github.com/containers/crun/commit/10b754c749d1c42bff3e8190db20b34a05317485
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
cd cases/crun-r79-seccomp-allow-with-errno
RUNTIME=/path/to/crun bash repro.sh
CONFIG=base_config.json RUNTIME=/path/to/crun bash repro.sh
```

For lifecycle cases, inspect the printed status and marker result. For terminal cases, run from a TTY. For mount and seccomp cases, treat missing kernel support or privileges as environment failures.

## Validation Note
The cited crun change separates cached filters by errno-related rule data. Version 1.30.1 was inspected, but no rebuilt or runtime validation was performed.
