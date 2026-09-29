# youki-3758-createContainer-sleep

## Upstream Issue Summary
- Root identifier: `R60-hook-failure/createcontainer-sleep`
- Runtime: `youki`
- Category: POSIX-platform Hooks
- Title: createContainer-sleep failure cleanup behavior
- Evidence: https://github.com/youki-dev/youki/issues/3758
- Audit status: 已有 issue / 直接讨论

This directory imports one runtime-specific variant from the revision audit. It follows the repository's five-file case format. The imported audit record is evidence for case construction; it is not a claim that the cited fix has been rebuilt, merged, or verified on current runtime HEAD.

## Local Reproduction Files
- `base_config.json`: clean OCI configuration.
- `buggy_config.json`: configuration containing the issue-specific payload.
- `repro.sh`: configurable reproduction helper.
- `expected_diff.txt`: expected behavior and validation oracle.
- `README.md`: provenance and prerequisites.

## Prerequisites
- Linux host with the `youki` binary or `RUNTIME=/path/to/runtime`.
- Repository rootfs archive at `alpine-base.tar.gz`.
- Root or the host capabilities required by the case; mount, seccomp, hook, and terminal cases have additional requirements.
- The supplied audit did not run a fixed/new runtime for this import. Compare an affected version with a reference or fixed version before reporting a pass.

## Reproduction
```bash
cd cases/youki-3758-createContainer-sleep
RUNTIME=/path/to/youki bash repro.sh
CONFIG=base_config.json RUNTIME=/path/to/youki bash repro.sh
```

For lifecycle cases, inspect the printed status and marker result. For terminal cases, run from a TTY. For mount and seccomp cases, treat missing kernel support or privileges as environment failures.

## Validation Note
This is an extension variant of issue #3758. The supplied evidence does not show that every variant is covered or fixed upstream.
