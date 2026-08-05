# Detector temporal-semantics audit — reproduction record

Date: 2026-08-04

## What was preserved

- `binaries/detect_conflict.orig` — the `detect_conflict` binary as built for the
  originally published results (md5 `58568d273ffd418b6b29c0853e72ec03`). Kept on
  disk but excluded from git (3.1 MB build artifact); rebuild it with `make all`
  from acc-trajdeconf `89b155b` if it is ever needed again.
- `old_results/` — the published `plots/conflict_resolution/**` outputs and
  `results_manifest.json` as of papers commit `a5c3b38`.
- `old_results/figures/` — the three conflict-resolution figures as published.

Nothing was deleted or force-pushed; all preserved files are additional copies.

## Repository states used for the rerun

| Repository | Path | Commit |
|---|---|---|
| papers | `/home/sing_sk/ACC/papers` | `a5c3b38` (branch `chore/paper-review-fixes`) |
| acc-trajdeconf | `/home/sing_sk/ACC/acc-trajdeconf-paper` | `89b155b` (branch `chore/paper`) + the detector fix below |
| acc-trajcalc | `/home/sing_sk/ACC/acc-trajcalc-paper` | `92c10ab` (branch `chore/paper-2`), unmodified |

Note on the original manifest: `results_manifest.json` recorded acc-trajcalc
`da4a680`, but the published latency and case-table columns can only be produced
by `92c10ab` (`overhead = client − Σplan − Σdeconf`, and the case table's
end-to-end column taken from `client_elapsed_ms`). The published results
therefore came from `92c10ab`; the manifest entry was stale. The rerun uses
`92c10ab` so that the detector fix is the only difference.

## Code change under test

`acc-trajdeconf` only, in the detector:

- `cpp/detect_conflicts/main.cpp` — removed the global `g_ca` closest-approach
  map and its recording block from `checkConflict()`.
- `cpp/detect_conflicts/conflict_output.{h,cpp}` — closest approach is now
  computed from the reported conflict interval by scanning
  `[t_start, t_end]` at 0.1 s and taking the instant of minimum co-temporal
  horizontal distance.

Rebuilt with `make all` (g++ 13, `-std=c++17 -O2 -fopenmp`).

## Service configuration for the rerun

```
acc-trajdeconf: HOST=127.0.0.1 PORT=8006 RELOAD=false LOG_LEVEL=warning \
                TRAJCALC_BASE_URL=http://127.0.0.1:8001
acc-trajcalc:   HOST=127.0.0.1 PORT=8001 RELOAD=false LOG_LEVEL=warning \
                TRAJDECONF_BASE_URL=http://127.0.0.1:8006
                (PERSIST_ARTIFACTS defaults to true)
```

`plans/` was cleared before every run so no peer trajectory leaked between runs.

## Seeds and parameters (unchanged from the published runs)

- request-pair RNG seed: 0 (script default)
- schedule-time RNG seed: 10000 (script default)
- request count: 100
- schedule day: 2026-01-01, window start 00:00 UTC
- cruise altitude: 200 m MSL
- max planning attempts: 5
- excluded ICAOs: `EDDV,EDBC_MEINE,EDVE,EDBC_BS,EDBC`
- deterministic-case base epoch: 2026-01-02T09:00:00Z

## Commands executed

Detector build and tests (in `acc-trajdeconf-paper`):

```
make all
uv run --frozen pytest                     # 65 passed
```

Experiments (in `acc-trajcalc-paper`, via `scratchpad/run_all.sh`, `plans/`
cleared between runs):

```
uv run --frozen --group plot python devtools/paper_conflict_resolution_evaluation.py --plots
uv run --frozen --group plot python devtools/paper_conflict_resolution_evaluation.py \
    --window-minutes 60 --outdir plots/paper/conflict_resolution/window_60min --plots
uv run --frozen --group plot python devtools/paper_conflict_resolution_evaluation.py \
    --window-minutes 30 --outdir plots/paper/conflict_resolution/window_30min --plots
uv run --frozen --group plot python devtools/paper_conflict_resolution_evaluation.py \
    --window-minutes 15 --outdir plots/paper/conflict_resolution/window_15min --plots
uv run --frozen --group plot python devtools/paper_deterministic_conflicts.py
```

Table and macro generation (in `papers`):

```
python3 tools/make_conflict_tables.py --results plots/conflict_resolution
```

## Machine

Same host as the published runs (Intel Core i7-8650U, WSL2, no CPU-governor
pinning). Unrelated development services were resident during the rerun, so
absolute latency values are not directly comparable with the published run;
outcome counts, blocked edges, attempts and detours are.
