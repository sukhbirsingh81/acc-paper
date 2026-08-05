# Revision report — submission draft revision (2026-07-18/19)

Scope: manuscript `mdpi/drones_manuscript.tex` + benchmark/evaluation/service
code in `acc-trajcalc` (branch `chore/paper-2`) and `acc-trajdeconf` (branch
`chore/paper`, worktree `acc-trajdeconf-paper`). The older root draft
(`main.tex`) is intentionally frozen at the pre-revision state; the MDPI
manuscript is the submission draft.

> Note (2026-08-05): the root draft (`main.tex`, `content/`, `references.bib`
> and its built PDFs) has since been deleted. It was two detector corrections
> behind and only reachable through git history from here on. The MDPI
> manuscript is the sole remaining draft.

## 1. Scientific blockers fixed

### A. Vertical-separation unit error (fixed, experiment rerun)
- Root cause: `cpp/detect_conflicts/detect_conflicts.h` defined
  `VERTICAL_SEPARATION 100. // feet` and both the conflict rule
  (`main.cpp`) and the NDMap broad-phase minima (`map_setup.cpp`) compared it
  directly against altitudes in metres — an effective 100 m threshold instead
  of the intended 100 ft.
- Fix: threshold now declared as `VERTICAL_SEPARATION_FT 100.` and converted
  once at the configuration boundary (`FT_TO_M 0.3048`,
  `VERTICAL_SEPARATION_M`); only the metre constant exists for detector code,
  so a mixed-unit comparison cannot silently reappear (the old macro name is
  gone; reuse fails to compile). Binary rebuilt from source.
- Unit audit: horizontal threshold 0.3 NM converted via `NM_TO_M` (geodesic
  metres) — correct; coordinates deg→rad at the parser — correct; time in
  epoch seconds end to end — correct; service passes altitudes through
  unchanged (test added).
- Tests added (`acc-trajdeconf tests/test_detector_separation_units.py`, 9
  tests): 100 ft → 30.48 m conversion; vertical 30 m in / 31 m out; explicit
  regression case (60 m must NOT conflict — it did under the bug); horizontal
  500 m in / 610 m out; temporal semantics (overlap required, disjoint
  intervals never conflict); altitude unit passthrough. Plus
  `acc-trajcalc tests/test_trajectory_altitude_units.py` (waypoint and
  generated/persisted altitudes are metres).
- Experiment B fully rerun with the corrected binary (same seeds 0/10000).

### B. Conflict predicate defined precisely (manuscript)
- New "Conflict predicate" paragraph with Equation (1): geodesic horizontal
  distance < 0.3 NM (555.6 m) AND |Δalt| ≤ 30.48 m, on discrete ~1 s samples,
  WGS-84 deg→rad conversion documented, no interpolation, co-temporal overlap
  required, 80 s = broad-phase pairing box (not a separation buffer), 2 s =
  conflict-interval merge threshold. Between-sample displacement bound
  (~25 m at cruise) related to the 555.6 m threshold.
- Empirically verified semantics: NDMap reports conflicts only for
  temporally overlapping trajectories; a 5 s gap between passes through the
  same point is NOT reported. Documented as such in manuscript and tests.

### C. Experiment B strengthened
- Reproducible baseline: seeds recorded (request-pair 0, schedule 10000),
  full-day window, 100 requests.
- Deterministic cases (`devtools/paper_deterministic_conflicts.py`), all 5
  pass with expected outcomes:
  head-on → resolved (1 initial conflict); following 15 s in-trail →
  no_path (graph exhausted; 3 initial conflicts); crossing at node HCTY →
  resolved, conflict confirmed within 556 m of the node; merge at shared
  destination/landing time → retry limit; unsolvable shared-pad case →
  retry limit.
- Density scenarios: 15/30/60-minute scheduling windows (same OD sequence
  and seeds), run in addition to the full-day baseline.
- New per-request metrics: peer-set size, temporally overlapping peers,
  initial/final route + distances + detour ratio, encounter-type
  classification (head-on / same-direction / node-crossing), per-attempt
  planner and detection latency, client end-to-end latency, HTTP overhead.
- Summary now reports candidate-peer comparisons, overlapping pairs,
  conflicts conditional on overlap, and outcomes split into resolved /
  retry-limit / no-route / mapping-stall.

### D. Experiment B latency decomposed
- Instrumented per attempt in `network_routes.py` (plan_ms, deconf_ms,
  peer_count in each `conflictResolution.attempts[]` entry).
- Finding (baseline run): clear first-pass requests average ≈78 ms planning
  (incl. artifact persistence), ≈1885 ms conflict detection, ≈19 ms HTTP;
  resolved requests ≈234 ms planning, ≈3670 ms detection, ≈33 ms HTTP.
  The earlier "unexplained" gap between planner subtotal and end-to-end time
  is per-check conflict detection: every check re-fetches all peer
  trajectories and rebuilds NDMap in a fresh detector process, and the
  server-side `total_ms` was stamped before the final detection call.
  New figure `conflict_resolution_latency_decomposition.png` + manuscript
  discussion.
- CFMS process startup is not separable: the engine is an in-process
  pybind11 module; manuscript now uses the exact phrase "CFMS invocation and
  dense trajectory generation" and states no engine-internal claim is made.

### E. Trajectory/NDMap lifecycle documented
- Code comments (`_calculate_network_route_impl` docstring) + manuscript
  "Detector state lifecycle" paragraph: stateless per-request detector, peers
  re-fetched per check, candidate id stable across attempts with overwrite
  semantics, duplicate insertion/self-conflict prevention, single-host
  trajectory store limitation.

### New bug found and fixed during revision
- Re-planning could exhaust every outgoing edge of the origin node; A*'s
  ValueError then escaped as raw HTTP 400 ("Start vertiport has no outgoing
  edges") — the old draft's unexplained "routing errors". The loop now
  reports this as a structured `no_path` outcome with the accumulated attempt
  record (commit "fix: report exhausted re-planning graph as no_path
  outcome"). Deterministically reproduced by the in-trail scenario.

## 2. Experimental claims corrected
- "Planner-stage scaling" renamed to "planner-stage latency decomposition
  and route-length dependence" in the title, abstract, highlights,
  contributions, section titles, captions, discussion, conclusions.
- Experiment A rerun with 5 warmup requests and 3 repetitions per OD pair
  (300 samples), monotonic clocks documented, CPU governor noted, nearest-rank
  quantile method documented, table reports Max instead of p99, per-bucket n
  annotated (87/147/54/12).
- Regression reporting: planner ms vs distance slope 2.14 ms/km
  (95% CI [2.01, 2.26], R² 0.80); samples vs distance 47.4 /km (R² 0.96);
  CFMS ms vs samples 0.045 ms/sample (R² 0.84).
- Pearson r text/figure consistency: text now quotes the same values as the
  regenerated figure (0.89/0.89/0.20/0.31).
- Unsupported "wider spread for longer paths" claim removed (per-bucket std
  8.4/11.3/12.3/7.3 ms is not monotone).

## 3. Method/architecture confusion fixed
- h1/hover/LDP reconciled with the implementation: h1 = max(15 m, LDP) =
  15 m; over-pad waypoint = h1; the 30 m hover-gate parameter exists but is
  unused by the nominal sequence — now stated explicitly; "over-pad hover
  waypoint" renamed.
- Phase naming: figure panels and prose renamed to "departure and outbound
  climb" / "inbound descent and arrival"; phase boundaries (first/last
  corridor node) stated; mean-TAS (17.15 m/s sample mean) vs distance/duration
  (17.53 m/s) discrepancy explained.
- Graph semantics: Table 1 recomputed from the actual data over all 812
  ordered OD pairs and corrected (60 undirected / 120 directed edges, mean
  degree 4.14, mean 3.14 hops, median 12.88 km — previous values 61/122/
  4.21/3.09/12.83 did not match the data); all nodes are vertiports;
  overflight of intermediate vertiports stated; 61 dataset entries → 29
  evaluated nodes explained.
- Conflict-to-edge mapping formalized (tie-breaking, duplicates, directed
  single-direction removal, unbounded mapping distance limitation,
  mapping-stall as separate outcome) + unit tests.
- Regulatory vs software roles: "U-space does not prescribe or mandate a
  corridor topology"; "inspired by"/"consistent with" EASA instead of
  "follows"; Table 2 recaptioned as benchmark parameterisation; "verticone"
  flagged as manuscript terminology; candidate-intent/U-plan defined without
  relying on the unpublished companion paper.

## 4. Paper strengthened
- Research questions RQ1–RQ3 added and answered in the conclusions.
- Related-work comparison table added; explicit relation to the companion
  fleet-control paper (ref 22) added; waypoint synthesis repositioned as an
  implementation contribution.
- Per-case conflict table generated from results
  (`conflict_resolution_cases_rows.tex`).
- Figures: fonts/labels enlarged for the conflict figures, "not_checked"
  label replaced by "Empty peer set", attempt ticks restricted to 1–5,
  n per bucket annotated, new latency-decomposition figure. Figures remain
  300–400 dpi PNG (vector PDF conversion not done; noted as remaining item).

## 5. Editorial
- "Drones" removed from keywords; placeholder DOI blanked for the submission
  build; CesiumJS sentence removed (frontend not evaluated); BFF/WSS added to
  abbreviations; double "Proceedings of the Proceedings of" fixed in both
  bib files (ICAS and ATM seminar entries); repetition of the "not an
  operational capacity assessment" disclaimer reduced.
- AUTHOR_QUERIES.md lists all items requiring author input (email, postal
  addresses, funding, acknowledgments, ref-22 status, data availability,
  exact CFMS/NDMap version identifiers).

## 6. Old vs new numerical results

Experiment A (old: 100 samples, no warmup; new: 300 samples, warmup 5,
repeat 3, same OD seed):

| Metric (mean ms) | Old | New |
|---|---|---|
| Planner-stage subtotal | 43.72 | 47.25 |
| CFMS invocation + generation | 43.38 | 46.88 |
| Waypoint synthesis | 0.12 | 0.13 |
| A* path search | 0.22 | 0.24 |
| Pearson r (planner vs distance) | 0.97 (n=100) | 0.89 (n=300) |

Experiment B baseline (old: buggy 100 m vertical threshold; new: corrected
30.48 m, loop fix, same seeds):

| Quantity | Old | New |
|---|---|---|
| Conflict-free first check | 93 | 96 |
| Resolved by re-routing | 6 | 3 |
| Empty peer set | 1 | 1 |
| Requests with initial conflict | 6 | 3 |
| Blocked directed edges | 13 | 5 |
| Attempts (resolved) | 2–4 | 2–3 |

Window scenarios and deterministic cases are new (no old values). See
`results_manifest.json` for artifact hashes and exact commands/seeds.

## 7. Unresolved items / blockers
- Author-input items in AUTHOR_QUERIES.md (front matter, funding, data
  availability decisions, ref-22 status).
- True scaling experiments (network size, concurrency) were NOT added; all
  "scaling" claims were removed/renamed instead.
- Vector-PDF figures: figures are high-resolution PNG; converting the
  matplotlib pipeline to PDF output remains optional polish.
- CFMS engine-internal timing cannot be decomposed further without modifying
  the pybind11 module; the manuscript uses the combined-stage phrase
  exclusively.
- The root draft `main.tex` still reflects the pre-revision state by design.
