# crun-2220

## Upstream issue
- Title: Seccomp filter cache key omits errno-related fields
- Source: https://github.com/containers/crun/pull/2220
- Category: Linux-specific Configuration
- Case source: The two audit rows R76 and R79 are covered by the same crun pull request; no separate issue was found.

This directory is the canonical issue-level case. Parameter and runtime observations that came from the same upstream issue are represented as variants in the reproduction helper instead of separate directories.

- Source creation date: 2026-09-01 (Pull request)

## Variants
- `errno-default`
- `allow-with-errno`

## Files
- `base_config.json`: clean OCI configuration.
- `buggy_config.json`: representative primary variant.
- `repro.sh`: selects a variant with `VARIANT=...`; set `RUNTIME=/path/to/runtime` as needed.
- `expected_diff.txt`: validation oracle.

## Prerequisites
Linux, the required OCI runtime, Python 3, `alpine-base.tar.gz` at the repository root, and the privileges/kernel features required by the selected variant. Mount, seccomp, hook, and terminal variants are not validated on this Windows workspace.

## Reproduction
```bash
cd cases/crun-2220
RUNTIME=/path/to/runtime VARIANT=errno-default bash repro.sh
```

This is a PR-sourced case because the audit did not identify a separate issue number.

## Verification status
The upstream evidence identifies the issue or fix source. Current-version runtime execution and exhaustive duplicate checking remain follow-up work; a source-side fix is not treated as a verified pass.
