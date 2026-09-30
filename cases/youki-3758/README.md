# youki-3758

## Upstream issue
- Title: youki does not invoke poststop after a createRuntime hook fails or times out
- Source: https://github.com/youki-dev/youki/issues/3758
- Category: POSIX-platform Hooks
- Case source: The issue directly covers createRuntime failure/timeout; prestart and createContainer rows are retained as explicitly labeled extension variants.

This directory is the canonical issue-level case. Parameter and runtime observations that came from the same upstream issue are represented as variants in the reproduction helper instead of separate directories.

- Source creation date: 2026-09-27 (Issue)

## Variants
- `createRuntime-nonzero`
- `createRuntime-timeout`
- `prestart-fail`
- `prestart-sleep`
- `createContainer-fail`
- `createContainer-sleep`

## Files
- `base_config.json`: clean OCI configuration.
- `buggy_config.json`: representative primary variant.
- `repro.sh`: selects a variant with `VARIANT=...`; set `RUNTIME=/path/to/runtime` as needed.
- `expected_diff.txt`: validation oracle.

## Prerequisites
Linux, the required OCI runtime, Python 3, `alpine-base.tar.gz` at the repository root, and the privileges/kernel features required by the selected variant. Mount, seccomp, hook, and terminal variants are not validated on this Windows workspace.

## Reproduction
```bash
cd cases/youki-3758
RUNTIME=/path/to/runtime VARIANT=createRuntime-nonzero bash repro.sh
```



## Verification status
The upstream evidence identifies the issue or fix source. Current-version runtime execution and exhaustive duplicate checking remain follow-up work; a source-side fix is not treated as a verified pass.
