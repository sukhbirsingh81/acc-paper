# Pre-submission review — Singh & Nagel, MDPI *Drones* manuscript

Same checklist Bianca applied to Enno's frontiers digital-twins paper, run against
`mdpi/drones_manuscript.tex` at `e042a71`, plus further comments.

Section numbers below are the ones **as reviewed** (before the fixes). The section
promotion in §1.3 renumbered everything from Related Work onwards; the current
numbering is Introduction 1, Related Work 2, Materials and Methods 3, Experimental
Setup 4, Results 5, Discussion 6, Conclusions 7.

## Status

Applied in `chore/paper-review-fixes` (commits `1b18af2`..`6b4840a`):
§1.1 scope wording, §1.2 initial-implementation statements, §1.3 section promotion,
§1.4 all abbreviation items, and comments 1, 7, 8, 9, 10, 13, 14, 15.

Still open, needing author input: comments 4, 5, 6 and the IAM-CC expansion — all
tracked in `AUTHOR_QUERIES.md`.

Deliberately not applied (editorial judgment, your call): comments 2, 3, 11, 12.

---

## 1. Mandatory items before publication

### 1.1 Remove company names / wrong-scope attributions

No Frequentis/Skyzr equivalent in this paper. The third-party names that are present
are all legitimate and should **stay**:

| Name | Where | Verdict |
|---|---|---|
| Intel Core i7-8650U, Ubuntu 24.04 LTS | 2.6.2 (`experimental_setup.tex:49,52`) | Keep — reproducibility info, no scope claim |
| OpenStreetMap contributors, CARTO | Fig. 5 caption (`experimental_setup.tex:18`) | Keep — required by the map-data licence |
| CFMS, NDMap | throughout | Keep — correctly attributed to DLR |

**The equivalent problem here is role scope, not company names.** Two places assert
a role for our services inside a regulated process that is not established:

1. `methodology.tex:18` — "In the **deployed** workflow, the fleet webserver submits
   a versioned operation plan (U-plan) to the USSP, and the USSP applies its
   authorization workflow, **consulting the Deconfliction Service where applicable**".
   Nothing is deployed, and a USSP consulting an operator-side deconfliction service
   is a concept assumption, not current practice.
2. Fig. 1 (`methodology.tex:63-65`) draws a solid request arrow `USSP → Deconfliction
   Service` labelled "deconfliction check at authorization", which reads as an
   existing interface.

**Fix:** "In the target workflow …", "the USSP **may** consult …", and add "(assumed
in the target concept)" to that arrow's caption text. This is the same class of
misleading-scope issue Bianca objected to, so it will get looked at.

### 1.2 State clearly that this is an initial implementation

Currently weak. "prototype" appears **4 times in the whole manuscript** — abstract,
two highlights bullets, 1.1 and 5. Sections 1, 2, 3 and 4 describe the system in the
present tense as an existing system.

Worse, **`IAM-CC` is named exactly once, unexpanded, with no caveat**
(`related_work.tex:51`): "The services evaluated here are embedded in the IAM-CC
fleet-control architecture described by Nagel et al." Given that Bianca's explicit
requirement on Enno's paper was to state that it describes an *initial* IAM-CC
implementation which will be developed further and may differ, our sentence has to
carry the same caveat — otherwise the two papers contradict each other on her own
programme.

**Fix — two sentences:**

- End of Section 1 (`introduction.tex`, after the contributions list): state that the
  paper describes an initial implementation, that it is evaluated as a research
  prototype, and that the operational system will be developed further and may differ.
- `related_work.tex:51`: expand IAM-CC on first use and add the same caveat, e.g.
  "… are an initial implementation of planning and deconfliction providers for the
  IAM-CC (Innovative Air Mobility Control Center) fleet-control architecture …
  the final IAM-CC will be developed further and may differ from the setup evaluated
  here." **Confirm the correct expansion with Enno before using it.**

### 1.3 Section numbering — sub-sections with only one entry

Confirmed hit, same defect as Enno's paper:

- **Section 1 (Introduction) contains exactly one subsection, 1.1 Related Work.**
  That is the single-entry case. It also pushes related work to *three* levels
  (1.1.1–1.1.3), which is unusual for a related-work section.
  **Fix:** promote Related Work to its own Section 2; 1.1.1–1.1.3 then become 2.1–2.3
  and everything downstream shifts by one.
- **2.6 Experimental Setup** is a subsection of Materials and Methods that runs to
  **2.6.5**, so "Limitations" sits at the third level inside the setup description.
  **Fix:** promote Experimental Setup to its own section; at minimum lift 2.6.5
  Limitations out (see also comment 14 on duplication).
- Cross-references call subsections "Section": `introduction.tex:29` refers to
  "Section~\ref{sec:related}" (= 1.1) and "Section~\ref{sec:experimental_setup}"
  (= 2.6). Both resolve themselves if the two promotions above are made.
- Sections 4 and 5 have no subsections — fine. 3.1–3.3 — fine.

### 1.4 Abbreviations — expand on first use

**Used before they are defined**

| Abbr. | First use | Defined at |
|---|---|---|
| `USSP` | `introduction.tex:8` ("submit to a USSP for authorization") | `introduction.tex:10` — swap the two |
| `REST`, `WSS` | inside Fig. 1 (`methodology.tex:49`) | body text *after* the figure (`methodology.tex:89`) — define in the caption or before the figure |

**Never expanded anywhere in the text**

| Abbr. | Where | In the abbreviations table? |
|---|---|---|
| `SESAR` | `introduction.tex:4`, 1.1.1 | No |
| `IAM-CC` | `related_work.tex:51` | No |
| `IQR` | Fig. 8 caption (`results.tex:90`) | No |
| `UI` | `methodology.tex:8` ("operator UI") | No |
| `LTS` | `experimental_setup.tex:52` | Yes, but never expanded in text |
| `CI` | `results.tex:72` | No — "confidence interval" is spelled out earlier in the same paragraph, so the usage is fine; just add the row |
| `BLAN`, `WOHL`, `VOLK`, `SCHN`, `FUHB` | Section 3.1 | n/a — say once that these are four-letter identifiers of the Hamburg vertiports |

**Abbreviation collision**

`OLS` is defined as "Outer limitation surface" in the table, but Section 3.2 and
Fig. 7's caption use "ordinary-least-squares fit" — the standard statistics meaning.
The text spells that one out everywhere, so it is not wrong, but the paper does both
vertiport geometry and regression, so it is worth a note or a rename.

**Table hygiene**

- `TUM` is in the table but never used in the body (affiliation only).
- `A*` is listed as an abbreviation; it is an algorithm name.
- Wording mismatches with the text: "application-programming-interface (API)" vs.
  "Application programming interface"; "comma-separated-values (CSV)" vs.
  "Comma-separated values". Harmonize.
- `MSL` is defined twice — `methodology.tex:120` and again `experimental_setup.tex:7`.
- **`mdpi/content/abbreviations.tex` is dead code.** It is not `\input` anywhere; the
  live table is inline at `drones_manuscript.tex:112-141`. Delete it before the two
  copies drift apart.

---

## 2. Further suggestions and comments

**Submission mechanics**

1. **Abstract is 293 words. MDPI's limit is 200.** It currently carries the full
   result set (96/1/3, 118 of 4950, 59 of 99, four window lengths). Keep the
   RQ-level findings; drop the pair-level counts, which are in Section 3.3 anyway.
2. **Title is 17 words** with a colon and two sub-clauses, and uses "4D" while the
   abstract says "four-dimensional". Shorten it and pick one form.
3. **36 pages, of which Materials and Methods is pages 6–21** — Methods is longer than
   Results. Expect an editor comment. Tables 3 and 4 (waypoint and deconfliction
   parameters) are the obvious candidates for supplementary material.
4. **Funding statement says "no external funding"** while the scenario comes from
   HorizonUAM and the services sit in IAM-CC. If either is a funded project this is
   wrong, and funders do check it. (Already `AUTHOR_QUERIES.md` #2 — repeating it
   because Bianca will look at it.)
5. **Corresponding author is a gmail address** on a TUM/DLR paper, and the affiliations
   have no postal addresses. (`AUTHOR_QUERIES.md` #1, #3.)
6. **Reference [22] (Nagel et al.) is `@unpublished`** and the paper leans on it in
   1.1, three times in 2.1, and in the Fig. 1 and Fig. 3 captions. Get a preprint DOI
   or make the text fully self-contained. Also: whatever Bianca makes Enno change
   there — company names, IAM-CC initial-implementation wording — has to match what
   we write about IAM-CC.
7. **Three uncited bib entries**: `cesiumjs_software`, `cesiumjs_docs`,
   `uav_dynamic_path_planning_q_apf`. Cite or remove.
8. **Data availability is inconsistent** with 2.6.1, which offers the graph node and
   edge lists "as supplementary material" while the statement says data is available
   on request only. The 29-node graph is tiny — attach it and the benchmark becomes
   reproducible at no cost.

**Technical / content**

9. **The separation minima are unjustified.** 0.3 NM and 100 ft (2.4, Table 4) are
   stated as given. These are ATM-derived values; for eVTOL in a 200 m corridor a
   reviewer will ask where they come from. One sentence with a reference, or an
   explicit "benchmark choice, not a proposed UAM standard".
10. **The 200 m MSL cruise layer sits above the 120 m AGL VLL ceiling** normally
    assumed for U-space operations. The paper says several times that it is a
    benchmark abstraction, but never why 200 m. One sentence (corridor concept above
    VLL / HorizonUAM scenario) stops it reading as an oversight.
11. **The full-day baseline produces only 3 conflicts out of 100 requests**, yet
    Section 3.3 spends most of its length on it. Table 5 (density scenarios) and the
    deterministic suite carry the actual evidence about the resolution loop. Consider
    leading with the density table and keeping the full day as the sparse reference
    case.
12. **Section 3.1 is a single-case walkthrough over pages 22–24 with five figures**,
    in a Results section whose quantitative content is 3.2 and 3.3. Tightening it, or
    moving the phase-panel figures (7, 8, 9) to an appendix, would improve the balance
    flagged in comment 3.
13. **Fig. 9**: waypoints 2 and 10 are not visible, although the text says 11 CFMS
    waypoints. Either label them or note in the caption that co-located waypoints
    overlap. (The axis labels are correct — "Horizontal speed"; only the *filename*
    still says `tas`, which is harmless but confusing in the repo.)
14. **Limitations are stated three times** — 2.6.5, the last two paragraphs of
    Section 4, and paragraph 3 of Section 5. Keep one full statement and cross-refer.
15. **"verticone" is introduced twice** with different framing and different quoting
    (2.3 `methodology.tex:328`, 2.6.3 `experimental_setup.tex:75`). Introduce once.

---

## 3. Already tracked

`AUTHOR_QUERIES.md` items 1, 2, 3, 7, 8, 9 overlap with comments 4–8 above and are
not new findings. Items 4, 5, 6 (NDMap/CFMS publication clearance and version
identifiers) are unaffected by this review and still need Enno's sign-off.
