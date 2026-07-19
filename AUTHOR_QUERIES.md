# Author queries — items requiring author input (do not guess)

These items cannot be completed by the revision without author-provided
information. The manuscript currently carries neutral placeholders where the
MDPI template requires content.

1. **Corresponding-author email** — `\corres{}` in `mdpi/drones_manuscript.tex`
   still contains the template placeholder. Please provide the address to use
   (institutional address preferred by MDPI).

2. **Complete affiliation/postal addresses** — the `\address{}` block lists
   only "Technical University of Munich (TUM), Germany" and "DLR Institute of
   Flight Guidance, Germany". MDPI requires full postal addresses (street,
   postal code, city). Please provide both.

3. **Funding statement** — `\funding{}` is unresolved. Confirm either the
   grant/project acknowledgement text (e.g., HorizonUAM / IAM-CC project
   funding, grant numbers) or that the research received no external funding.

4. **Acknowledgments** — `\acknowledgments{}` is unresolved. Confirm whether
   to acknowledge colleagues (e.g., reviewers of the draft) or remove.

5. **Reference 22 (Nagel et al., fleet-control architecture)** — cited as an
   unpublished manuscript ("submitted"). Please confirm its current
   publication status, venue, and DOI, or whether it should be cited as a
   preprint with an access link. The revised manuscript no longer relies on it
   for essential architecture details, but reviewers may ask for an accessible
   version.

6. **Code/data availability** — the Data Availability Statement currently says
   "available from the corresponding author upon reasonable request" and the
   experimental-setup section states the graph data "can be provided as
   supplementary material". Please decide:
   - whether the benchmark CSV/JSON result files and the graph node/edge lists
     will be attached as supplementary material;
   - whether any service code can be released publicly (per the companion
     paper, the code currently lives in DLR-internal repositories).

7. **CFMS and NDMap version identifiers** — the manuscript states "CFMS
   project version 1.0" and that no standalone NDMap release is declared.
   Please confirm the exact CFMS release/commit and, if available, an NDMap
   version or internal commit reference for the reproducibility manifest.
