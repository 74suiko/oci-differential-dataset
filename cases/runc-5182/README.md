# runc-5182

## Upstream issue
- Title: poststop hook is not run if poststart hook fails
- Source: https://github.com/opencontainers/runc/issues/5182
- Category: POSIX-platform Hooks
- Related fix: https://github.com/opencontainers/runc/pull/5186
- Issue created: 2026-03-17

This existing repository case now absorbs the two audit variants instead of creating duplicate directories.

- Source creation date: 2026-03-17 (Issue)

## Variants
- `poststart-fail`
- `poststart-sleep`

Use `VARIANT=poststart-fail` or `VARIANT=poststart-sleep` with `repro.sh`. The related PR changes hook ordering but explicitly does not implement all cleanup semantics after a poststart failure.

## Verification status
The issue source and historical reproduction are documented. The helper uses Python 3 to materialize variants. Current-version execution remains a follow-up task.
