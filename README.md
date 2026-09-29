# OCI Differential Dataset

## Project Overview
This repository is a curated dataset of OCI runtime issue-reproduction cases. Each case captures a historical bug, compatibility difference, or specification edge case from runtimes such as runc, crun, and youki.

## Dataset Purpose
The dataset supports public research on OCI runtime testing. It is designed to make runtime behavior differences reproducible with small OCI configurations instead of large container images or full orchestrator stacks.

Typical uses include regression testing, differential testing across runtime implementations, specification conformance studies, and validation of edge cases in hooks, process execution, mounts, cgroups, devices, seccomp, and lifecycle state handling.

## Dataset Structure
The repository contains a root filesystem archive, metadata, issue-selection notes, and one directory per reproduction case.

Each case directory is named with the runtime and upstream issue number, for example `runc-4772`, `crun-1083`, or `youki-3266`.

## Directory Layout
```text
.
|-- README.md
|-- metadata.json
|-- alpine-base.tar.gz
`-- cases/
    |-- runc-4772/
    |   |-- base_config.json
    |   |-- buggy_config.json
    |   |-- repro.sh
    |   |-- expected_diff.txt
    |   `-- README.md
    |-- crun-1083/
    `-- youki-3266/
```

## Metadata Format
`metadata.json` is a JSON array. Each entry uses this schema:

```json
{
    "number": "runc-4772",
    "title": "Conversion of cgroup v1 CPU shares to v2 CPU weight causes workloads to have low CPU priority",
    "url": "https://github.com/opencontainers/runc/issues/4772",
    "analysis": {
        "category": "Linux-specific Configuration",
        "reason": "This case is included because it exercises OCI runtime behavior in Linux-specific Configuration."
    }
}
```

The `category` field uses one of the core OCI testing categories represented in this dataset:

- `Lifecycle & State`
- `POSIX-platform Hooks`
- `Process & Execution`
- `Filesystem & Mounts`
- `Linux-specific Configuration`
- `Annotations & Metadata`
- `Features & Versioning`
- `VM-specific Extensions`

## Case Format Description
Every case directory must contain exactly these files:

- `base_config.json`: a clean OCI configuration before the issue-specific payload is injected.
- `buggy_config.json`: the modified OCI configuration that triggers the historical issue or behavior difference.
- `repro.sh`: a reproduction helper that prepares a temporary OCI bundle, extracts `../../alpine-base.tar.gz`, copies the selected config to `config.json`, and invokes the runtime.
- `expected_diff.txt`: the expected behavioral difference and validation oracle.
- `README.md`: the case-level explanation, prerequisites, runtime version assessment, reproduction steps, and validation notes.

`buggy_config.json` is the standard filename for the modified configuration.

## Runtime Version Requirements
Most cases compare a historical buggy runtime with a fixed or reference runtime. The exact version requirements vary by case and are documented in each case README.

General guidance:

- runc cases often require a specific historical runc build, a fixed runc build, or a comparison against crun.
- crun cases often compare an older crun build with runc or a newer crun build.
- youki cases usually compare an affected youki build with runc or a fixed youki build.
- Linux-specific cases may require cgroup v1, cgroup v2, seccomp, eBPF device filtering, user namespaces, or particular kernel support.

## How to Reproduce an Issue
1. Install the runtime binaries you want to compare.
2. Keep `alpine-base.tar.gz` in the repository root.
3. Change into a case directory, for example `cd cases/runc-4772`.
4. Run the default reproduction: `bash repro.sh`.
5. Override the runtime if needed: `RUNTIME=/path/to/runtime bash repro.sh`.
6. Override the config if needed: `CONFIG=base_config.json bash repro.sh` or `CONFIG=buggy_config.json bash repro.sh`.
7. Compare the result with `expected_diff.txt`.

## How to Add New Cases
1. Create a directory under `cases/` named `<runtime>-<issue-number>`.
2. Add exactly the five required files: `base_config.json`, `buggy_config.json`, `repro.sh`, `expected_diff.txt`, and `README.md`.
3. Keep the clean baseline in `base_config.json` and put only the issue-specific payload in `buggy_config.json`.
4. Make `repro.sh` self-contained and configurable through `RUNTIME`, `CONFIG`, `ROOTFS_TAR`, `BUNDLE`, and `CONTAINER_ID` where practical.
5. Add a corresponding entry to `metadata.json` using the existing schema.
6. Document host requirements, affected versions, reproduction steps, and expected output.
7. Verify that the case does not depend on unrecoverable local paths or private artifacts.

## Expected Outputs and Validation
Validation is differential. A case is useful when the same OCI payload produces a meaningful difference between a reference runtime and an affected runtime.

Common validation signals include different exit codes, stdout or stderr markers, cgroup values, hook side effects, device-node metadata, mount visibility, process environment, capabilities, or exec behavior.

If a case fails because the host lacks a required kernel feature, cgroup controller, seccomp capability, runtime binary, or permission level, treat that as an environment failure rather than a successful reproduction.

## Limitations and Known Issues
- Some historical issues require very specific kernel, cgroup, LSM, or runtime versions.
- Some issue reports describe integration behavior from Docker, containerd, Podman, or CRIU and cannot always be reduced to a single static OCI config.
- Race-condition and lifecycle cases may require repeated runs or manual inspection.
- Several scripts require root privileges or passwordless sudo depending on the runtime and host configuration.
- The dataset uses a small Alpine root filesystem to keep cases compact; image-specific bugs may require additional fixtures.

## Revision Audit Extension (2026-09-29)

The repository now includes 26 runtime-specific extension cases imported from the revision audit. They are stored as separate variants when one upstream issue has multiple runtime or parameter combinations. The eight R97 feature trials are intentionally not imported as standalone cases because they are partial subitems of one aggregate case.

The imported cases preserve the audit status in each case README. “Existing fix code” and “existing fix PR” are provenance labels; they do not mean that the fixed revision was rebuilt or executed. The extension should therefore be reported with independent issue-family counts and runtime-variant counts separately.

The imported cases were constructed from the audit CSV and upstream references. Runtime execution, exhaustive duplicate search, and current-HEAD validation remain follow-up tasks.
