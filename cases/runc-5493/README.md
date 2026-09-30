# runc-5493

## Upstream issue
- Title: runc accepts duplicate RLIMIT_NOFILE entries and starts the container
- Source: https://github.com/opencontainers/runc/issues/5493
- Category: Process & Execution
- Case source: PR #5494 proposes the fix for issue #5493; identical and conflicting values are variants of the same duplicate-type rule.

This directory is the canonical issue-level case. Parameter and runtime observations that came from the same upstream issue are represented as variants in the reproduction helper instead of separate directories.

- Source creation date: 2026-09-26 (Issue)

## Variants
- `conflicting-values`
- `identical-values`

## Files
- `base_config.json`: clean OCI configuration.
- `buggy_config.json`: representative primary variant.
- `repro.sh`: selects a variant with `VARIANT=...`; set `RUNTIME=/path/to/runtime` as needed.
- `expected_diff.txt`: validation oracle.

## Prerequisites
Linux, the required OCI runtime, Python 3, `alpine-base.tar.gz` at the repository root, and the privileges/kernel features required by the selected variant. Mount, seccomp, hook, and terminal variants are not validated on this Windows workspace.

## Reproduction
```bash
cd cases/runc-5493
RUNTIME=/path/to/runtime VARIANT=conflicting-values bash repro.sh
```



## Verification status
The upstream evidence identifies the issue or fix source. Current-version runtime execution and exhaustive duplicate checking remain follow-up work; a source-side fix is not treated as a verified pass.
