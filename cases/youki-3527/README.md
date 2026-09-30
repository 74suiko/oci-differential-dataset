# youki-3527

## Upstream issue
- Title: Difference between the Terminals and Standard IO in runc and youki
- Source: https://github.com/youki-dev/youki/issues/3527
- Category: Process & Execution
- Case source: PR #3639 is part of issue #3527; console sizes are input variants.

This directory is the canonical issue-level case. Parameter and runtime observations that came from the same upstream issue are represented as variants in the reproduction helper instead of separate directories.

- Source creation date: 2026-05-04 (Issue)

## Variants
- `24x80`
- `40x132`

## Files
- `base_config.json`: clean OCI configuration.
- `buggy_config.json`: representative primary variant.
- `repro.sh`: selects a variant with `VARIANT=...`; set `RUNTIME=/path/to/runtime` as needed.
- `expected_diff.txt`: validation oracle.

## Prerequisites
Linux, the required OCI runtime, Python 3, `alpine-base.tar.gz` at the repository root, and the privileges/kernel features required by the selected variant. Mount, seccomp, hook, and terminal variants are not validated on this Windows workspace.

## Reproduction
```bash
cd cases/youki-3527
RUNTIME=/path/to/runtime VARIANT=24x80 bash repro.sh
```



## Verification status
The upstream evidence identifies the issue or fix source. Current-version runtime execution and exhaustive duplicate checking remain follow-up work; a source-side fix is not treated as a verified pass.
