# crun-2197

## Upstream issue
- Title: Starting a rootful distrobox via podman completely breaks the system
- Source: https://github.com/containers/crun/issues/2197
- Category: Filesystem & Mounts
- Case source: crun commit ea4672d closes issue #2197; the per-mount propagation options are required by the OCI runtime-spec mount-options table.

This directory is the canonical issue-level case. Parameter and runtime observations that came from the same upstream issue are represented as variants in the reproduction helper instead of separate directories.

- Source creation date: 2026-08-19 (Issue)

## Variants
- `rslave`
- `runbindable`

## Files
- `base_config.json`: clean OCI configuration.
- `buggy_config.json`: representative primary variant.
- `repro.sh`: selects a variant with `VARIANT=...`; set `RUNTIME=/path/to/runtime` as needed.
- `expected_diff.txt`: validation oracle.

## Prerequisites
Linux, the required OCI runtime, Python 3, `alpine-base.tar.gz` at the repository root, and the privileges/kernel features required by the selected variant. Mount, seccomp, hook, and terminal variants are not validated on this Windows workspace.

## Reproduction
```bash
cd cases/crun-2197
RUNTIME=/path/to/runtime VARIANT=rslave bash repro.sh
```

The original audit had two rows for this issue. They are now one issue-level case with a variant matrix.

## Verification status
The upstream evidence identifies the issue or fix source. Current-version runtime execution and exhaustive duplicate checking remain follow-up work; a source-side fix is not treated as a verified pass.
