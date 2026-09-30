# runtime-spec-1309

## Upstream issue
- Title: Spec poststop hook behaviour is different from the popular implementations
- Source: https://github.com/opencontainers/runtime-spec/issues/1309
- Category: POSIX-platform Hooks
- Case source: This is one cross-runtime specification case. runc issue #1765 and youki PR #3407 are implementation evidence for the same spec issue; rerun the directory with `RUNTIME=runc` and `RUNTIME=youki`.

This directory is the canonical issue-level case. Parameter and runtime observations that came from the same upstream issue are represented as variants in the reproduction helper instead of separate directories.

- Source creation date: 2026-02-17 (Issue)

## Variants
- `fail`
- `sleep`

## Files
- `base_config.json`: clean OCI configuration.
- `buggy_config.json`: representative primary variant.
- `repro.sh`: selects a variant with `VARIANT=...`; set `RUNTIME=/path/to/runtime` as needed.
- `expected_diff.txt`: validation oracle.

## Prerequisites
Linux, the required OCI runtime, Python 3, `alpine-base.tar.gz` at the repository root, and the privileges/kernel features required by the selected variant. Mount, seccomp, hook, and terminal variants are not validated on this Windows workspace.

## Reproduction
```bash
cd cases/runtime-spec-1309
RUNTIME=/path/to/runtime VARIANT=fail bash repro.sh
```

This replaces separate runc-1765 and youki-3407 directories to avoid counting one spec discrepancy twice.

## Verification status
The upstream evidence identifies the issue or fix source. Current-version runtime execution and exhaustive duplicate checking remain follow-up work; a source-side fix is not treated as a verified pass.
