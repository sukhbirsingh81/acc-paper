# Recovered software and aircraft configuration

Recovery date: 21 September 2026. This record accompanies the existing paper results;
no experiment was rerun during recovery.

## What is preserved

`software_snapshot.json` records full commit/tree IDs, archive checksums, exclusions,
and the strength of the provenance evidence. Source archives are stored locally in
`.preserved/2026-09-21-software-snapshot/` (about 34 MB compressed). This internal
folder is excluded from Git and is not a public supplement. Copy it to the project's
approved durable storage before transferring or cleaning this workspace.

| Component | Preserved revision | Evidence |
|---|---|---|
| Planning Service | `92c10ab` | Identified as unmodified in the preserved August rerun notes. |
| Deconfliction Service | `2ee9143` | Committed counterpart of the closest-approach correction described in those notes. The original record named its parent plus an uncommitted fix. |
| CFMS/dronetools | `b6532f4` | Gitlink in the recorded planner revision. |
| Planner JSON dependency | `8c7a7d4` | Gitlink in the recorded planner revision. |
| Detector JSON dependency | `3946872` | Gitlink in the recovered detector revision. |
| Detector CLI dependency | `30d783e` | Gitlink in the recovered detector revision. |
| NDMap/usefulThings | `6fc3a9c` | Clean dependency currently linked into the paper worktree; its latest commit predates the rerun, but the execution-time revision was not recorded. |

Each archive contains tracked files from its named commit, not a copy of the current
development branch. Submodules are archived separately. Environment files,
certificate/key files, credential-bearing metadata and symlinks are excluded;
`omitted_paths` lists every exclusion. The original Git tree IDs identify the source
revisions, while SHA-256 identifies these deliberately filtered archives. This is
not a byte-for-byte archive of an original working directory.

The private folder also contains copies of the default aircraft file, build files
and Python lockfiles at those revisions, plus `AUGUST_RERUN_RECORD.md`. Build recipes
are the archived Makefiles (`make all` for both services). The planner requires its
CFMS source dependency and the pybind11 build group; the recorded `uv.lock` files
should be used with frozen dependency installation. These instructions were checked
against source; the reconstructed environment has not been rebuilt or benchmarked.

For reconstruction, extract the planner and detector archives into separate clean
directories. Extract CFMS and planner JSON under the planner's
`external/dronetools` and `external/nlohmann`; extract NDMap, detector JSON and CLI
under the detector's `external/usefulThings`, `external/nlohmann` and
`external/CLI11`. Recreate only the service settings documented in the August record.
Do not reuse a development `.env` file. The preserved benchmark scripts and original
manifest give the experiment commands. Experiment A's original OD draw was not
seed-reproducible: its recorded CSV pair list must be replayed to reproduce that
sample. A newly seeded draw is a different experiment.

## Aircraft settings: established versus inferred

The recorded benchmark request builder does not send `vehicleType`. The recorded
resolver chooses `CFMS_UAMcopter` with `data/uam_performance_params.txt` unless
`UAM_PERF_FILE` overrides the file. The original service environment and resolved
file hash were not captured. Therefore the preserved default is **a reconstructed
configuration, not a confirmed historical runtime selection**.

The default file's full checksum is recorded in `software_snapshot.json`. It is
preserved privately in `configuration/planner/data/uam_performance_params.txt`.
Its entries include empty mass 950 kg, zero battery/payload mass entries, 18 rotors,
2.25 m rotor diameter and a 27.778 m/s cruise-speed limit. Negative sentinel entries
in that file are not physical parameter values: for example the mass field uses
`-1` to request calculation from component entries. Electrical and battery entries
are explicitly marked uncalibrated in the source file. Do not describe this as a
validated manufacturer aircraft model or use it to support endurance/energy claims.

The phase speed targets are directly recoverable from `cpp/traj_engine.cpp` at the
recorded planner revision: 0 m/s horizontal take-off/landing, 5 m/s terminal funnel,
20 m/s transition/approach and 25 m/s cruise navigation. Near the destination, targets
are capped at 20 m/s within 700 m and 12 m/s within 300 m; lower targets remain lower.
They are requested waypoint speeds, not measured speeds or a uniform percentage
reduction from aircraft limits. The manuscript now states this distinction.

## What remains uncertain

- Which performance file was selected at execution time, including any environment override.
- Whether the CFMS submodule had unrecorded local changes at execution time.
- The NDMap dependency revision actually loaded into the historical detector build.
- Exact correspondence of that detector binary to the later committed correction.
- The installed runtime environment beyond the recorded machine information and source lockfiles.

The archive preserves available evidence and prevents further loss. It cannot
retroactively prove missing execution metadata. Additional contemporary logs could
resolve these gaps. Otherwise, a new run with explicit configuration and runtime
capture is required before claiming fully pinned experimental reproduction.

For such a run, record resolved performance-file bytes/hash, aircraft type,
actual backend used (CFMS versus fallback), every dependency revision and dirty
patch, executable/module hashes, compiler flags/versions, installed dependency
versions, sanitized effective service settings, input/request hashes and seeds.
Keep generated data separate from the published run until all tables and figures
have been regenerated and compared. A successful HTTP response alone does not
prove CFMS was used: the recorded service can fall back after some generator errors.

## Verification

Run from the papers repository:

```sh
python3 tools/verify_software_snapshot.py
```

This checks private archive hashes, safe archive paths and file counts, the
preserved default performance-file hash, and all paper result/figure hashes.
Passing confirms integrity of the recovered files; it does not resolve the
historical uncertainties above. On a clone without the private archives, the
verification deliberately reports them missing.
