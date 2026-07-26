# youki-3320

## Upstream Issue Summary
- Title: rbind,ro mount is read-only but not recursively
- URL: https://github.com/youki-dev/youki/issues/3320
- Category: Filesystem & Mounts
- Summary: This case reduces the upstream issue to a small OCI bundle that can be used for differential runtime testing.

## Runtime Version Assessment
Use the runtime version discussed in the upstream issue as the affected implementation and compare it with a fixed or reference runtime. Some cases require specific host support such as cgroup v1, cgroup v2, seccomp, eBPF device filtering, user namespaces, or hook execution support.

## Buggy Version Identification
Git log matched `123b51a4ee05` (`rbind,ro mount is read-only but not recursively (#3345)`); use parent `98f42b58a658` as the pre-fix buggy baseline.

## Local Reproduction Files
- `base_config.json`: clean OCI configuration before injecting the issue-specific payload.
- `buggy_config.json`: modified OCI configuration containing the payload.
- `repro.sh`: helper script that prepares a temporary OCI bundle, extracts `../../alpine-base.tar.gz`, copies the selected config to `config.json`, and invokes the runtime.
- `expected_diff.txt`: expected behavioral difference and validation oracle.
- `README.md`: this case description.

## Reproduction Prerequisites
- Linux host with permission to run OCI runtimes.
- `alpine-base.tar.gz` present in the repository root.
- Runtime binary available on `PATH` or passed with `RUNTIME=/path/to/runtime`.
- Case-specific kernel or cgroup features available when required by `expected_diff.txt`.

## Reproduction Steps
1. Change into `cases/youki-3320`.
2. Run `bash repro.sh` with the default runtime.
3. Compare implementations by rerunning with explicit binaries, for example `RUNTIME=/path/to/reference-runtime bash repro.sh` and `RUNTIME=/path/to/buggy-runtime bash repro.sh`.
4. Check the clean baseline with `CONFIG=base_config.json bash repro.sh` when useful.
5. Compare exit code, stdout, stderr, and side effects against `expected_diff.txt`.

## Result Validation
Payload: process args: ["sh", "-c", "echo -n 'Top(/mnt/foo): '; touch /mnt/foo 2>/dev/null && echo RW || echo RO; echo -n 'Sub(/mnt/subvol/bar): '; touch /mnt/subvol/bar 2>/dev/null && echo RW || echo RO"]; linux.resources.devices: [{"allow": false, "access": "rwm"}]; additional mounts: [{"destination": "/mnt", "type": "bind", "source": "/tmp/mounts_recursive", "options": ["rbind", "ro"]}]

Oracle: Both the top-level bind mount and recursive submount should be read-only. A buggy runtime allows writes through a recursive submount.

## Additional Validation Note (2026-07-19)
Using only `buggy_config.json` with the provided `alpine-base.tar.gz` rootfs, the case did not run to the original oracle because the configured bind source `/tmp/mounts_recursive` is not provided by the case. After creating that source and a submount in the temporary validation environment, runc 1.1.14, youki 0.6.0, and crun 1.17 all reported the top-level mount as read-only and the recursive submount as writable. This did not provide a reference runtime showing recursive read-only behavior, so reproducing the original differential issue appears to require additional host mount setup and a runtime/kernel combination that supports or enforces recursive read-only bind mounts.
