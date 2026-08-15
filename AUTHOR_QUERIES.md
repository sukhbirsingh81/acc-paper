# Author queries — items requiring author input (do not guess)

These items cannot be completed by the revision without author-provided
information.

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

7. **CFMS and NDMap version identifiers** — the manuscript states "CFMS
   project version 1.0" and that no standalone NDMap release is declared.
   Please confirm the exact CFMS release/commit and, if available, an NDMap
   version or internal commit reference for the reproducibility manifest.

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
