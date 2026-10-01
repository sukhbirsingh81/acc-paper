# Author queries — items requiring author input (do not guess)

These items cannot be completed by the revision without author-provided
information.

## Current review — 21 September 2026

See `REVIEW_2026-09-21.md` and the subsequent recovery in
`reproducibility/README.md`. Source snapshots, dependency revisions, lockfiles and
the default aircraft parameter file are now preserved with checksums. The detector
fix has a committed counterpart, `2ee9143`; the earlier “uncommitted fix” entry is
retained as historical evidence in the manifest. The manuscript now documents
phase-speed settings and reconstructed default model parameters.

What still cannot be confirmed from the saved run record: the runtime performance
file override, exact NDMap revision at execution time, and the link between the
executed detector binary and recovered source. These are explicit provenance
limitations, not missing files we can fill by guessing. A new, fully instrumented
run would be needed to eliminate those historical uncertainties if no further
run records exist.

## Submission blockers — decide before uploading

1. **Author emails** — resolved. `\corres{}` now reads
   `sukhbir.singh@dlr.de`. MDPI puts only the corresponding author's address in
   the manuscript, so Enno's is not in the TeX; his DLR address is
   `enno.nagel@dlr.de` (taken from his DLR-authored commits in the ACC repos)
   for the submission form.

2. **Funding statement** — still open. `\funding{}` reads "This research
   received no external funding." MDPI requires the field to be present, so it
   cannot simply be dropped, and this wording is the standard way of saying that
   no external grant applies — it names no project or funder. Left as is.
   **Still worth one check with Enno before upload**, because if the work does
   sit under a funded project, the funder has to be acknowledged and getting
   this wrong can affect future funding. A `% AUTHOR ACTION` comment marks the
   line.

3. **Complete affiliation/postal addresses** — still open, and now the only
   remaining blocker. The `\address{}` block lists only "Technical University of
   Munich (TUM), Germany" and "DLR Institute of Flight Guidance, Germany". MDPI
   requires full postal addresses (street, postal code, city). Please provide
   both.

4. **IAM-CC** — resolved by removal. The name is no longer used anywhere in
   the manuscript. Section 2 now describes the evaluated services as an initial
   implementation of the planning and deconfliction providers of "the
   fleet-control architecture described by Nagel et al.", and closes with the
   note that that architecture will be developed further and may differ from
   what is evaluated here. No expansion is needed since the abbreviation is
   gone.

## DLR publication-approval review

5. **NDMap statements retained in the manuscript.** The following are kept
   because Equation~(2) and the reported results cannot be interpreted without
   them. All of them describe externally observable detector behavior, not
   internal algorithms; confirm they are cleared for publication:
   - both trajectories are evaluated at one common instant, with linear
     interpolation between samples (Section 3.4, Equations (1)--(2));
   - the horizontal and vertical thresholds and the strict/non-strict
     inequality sides (Section 3.4, Table 4);
   - interval overlap as a precondition for examining a pair;
   - the 2 s merge gap and the 1 s minimum reported violation duration, both
     needed to state the completeness limitation honestly;
   - that separation minima plus "an implementation-specific time-partition
     parameter" are supplied for broad-phase pruning. The numeric value of that
     parameter has been removed from the manuscript, the tables and the
     reproducibility manifest.

   Removed in this revision: the internal tree/leaf-cell structure, arc-radian
   units, the witness probe grid, the bisection refinement schedule, the
   reported-interval rounding, the named library duration constant, the sample
   thinning rule, and the numeric time-partition value.

6. **CFMS statements retained in the manuscript.** CFMS is treated as a
   black-box trajectory generator. Retained: that it consumes a phase-structured
   waypoint sequence with altitude, speed and phase labels and emits a dense
   time-parameterized 4D trajectory at ~1 s spacing; the published reference;
   the stated version. Removed: the unused hover-gate parameter and its default,
   and the unevaluated balked-landing / holding / energy-constrained-divert
   procedure variants. Confirm nothing further needs generalizing.

7. **CFMS and NDMap source recovery — partially resolved (21 September).**
   Full revisions and local source archives are now recorded in
   `reproducibility/software_snapshot.json`. CFMS is pinned by the recorded
   planner revision; the linked NDMap source has been preserved, but its use in
   the historical run is not independently established. See the current-review
   note above for the exact remaining uncertainties.

## Remaining editorial items

8. **Reference 22 (Nagel et al., fleet-control architecture)** — cited as an
   unpublished manuscript ("submitted"). Please confirm its current
   publication status, venue, and DOI, or whether it should be cited as a
   preprint with an access link. The revised manuscript no longer relies on it
   for essential architecture details, but reviewers may ask for an accessible
   version. Since this manuscript no longer names IAM-CC, the two papers are now
   only loosely coupled, but the initial-implementation framing in Section 2
   should still not contradict whatever Bianca requires in that paper.

9. **Code/data availability** — the Data Availability Statement now reads:
   "The evaluation data and non-proprietary analysis and plotting scripts,
   including the vertiport node list and corridor edge list of the evaluated
   network, are available from the corresponding author upon reasonable request.
   Proprietary software components and restricted integration source code are
   not included and remain subject to the applicable intellectual-property and
   licensing conditions." No public repository or archive is claimed. Confirm
   this is the intended level of disclosure, and whether the graph node/edge
   lists should instead be attached as supplementary material.

10. **Acknowledgments** — currently thanks Bianca Isabella Schuchardt for the
    draft review. Confirm this is wanted and complete.

11. **Separation minima** — Section 3.4 now states explicitly that 0.3 NM and
    100 ft are a benchmark configuration choice following conventional
    air-traffic practice, and not a proposed UAM separation standard. If a
    citable source for these values in a UAM/U-space context exists, adding it
    would be stronger than the current hedge.

## Code fix deferred to the authors

10. **`benchmark_trajs.py` seeding — fixed in code, rerun still open.** In
    `acc-trajcalc` branch `chore/paper-2`, `devtools/benchmark_trajs.py` line
    ~1073 does `random.seed(args.seed or None)`. The default seed is 0, which is
    falsy, so it becomes `random.seed(None)` and the OD draw is seeded from
    system entropy. Experiment A is therefore not reproducible from its seed.
    (`paper_conflict_resolution_evaluation.py` uses `random.Random(seed)` and is
    fine, which is why Experiment B is reproducible.)

    Fixed in `acc-trajcalc` `chore/paper-2` commit `8fd2a78`: the draw now uses a
    local `random.Random(args.seed)`, so `--seed` behaves as documented. The
    module-level `rand_id()` still uses the global RNG, which only produces
    request identifiers and deliberately stays non-deterministic.

    **What this does not do:** the reported Experiment A numbers were produced by
    the old, entropy-seeded code, so rerunning with the fix draws a *different*
    100-pair sample and every planner number would change. The results were not
    rerun. The manuscript therefore defines the reported sample by its recorded
    pair list in `plots/trajcalc_scalability/planner_scalability.csv`, not by a
    seed. If you do want a seed-reproducible Experiment A in the submitted
    version, the rerun has to happen with the services up and the planner tables
    and macros regenerated afterwards — say the word and I will prepare it.
