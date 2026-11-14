# 10 — Screening

## Context

Screening is a **labeled simulation** for the D0 demo, not a real clinical
instrument. `ScreeningStep1Screen` (S09) collects age/weight/height,
`ScreeningDemoDialog` (E05) is the transparency gate, and
`ScreeningResultScreen` (S10) shows a permanent "SIMULASI" badge and a 50% donut
example. Inputs never produce a real medical percentage (FR-05 GATED).
`ProfileProvider.updateLatestScreening` (`profile_provider.dart:141-155`) stores
the latest simulated category/score onto the active child (drives home risk
meter + meal-plan risk).

## Findings / Integration Issues

### P2 — Screening updates child risk without distinguishing simulation
`updateLatestScreening` (`profile_provider.dart:141-155`) writes
`latestRiskCategory`/`latestRiskScore` onto the active child. These values flow
into the home risk meter and meal-plan risk query. If the simulation value is
presented anywhere without the "SIMULASI" badge, it could be misread as a real
risk. Verify every consumer of `latestRiskCategory` keeps the disclaimer.

### P3 — Hardcoded 50% simulation is not parameterized
The S10 donut/text is fixed at 50% per the PDF. If product later wants the
simulation to reflect the entered age/weight/height, the plumbing (step-1 inputs
→ result) is not wired; inputs are validated then discarded.

## Requirement

- FR-05: initial data collection + result with explanation; score/classification
  GATED.
- AC-03: S10 permanent "SIMULASI" badge; default home risk "Skrining belum
  tersedia".
- FR-17: follow-up guidance is general; no automatic clinical decision.

## QA Checklist (manual)

| ID | Scenario | Steps | Expected |
| --- | --- | --- | --- |
| SCR-01 | Step 1 render | Home → Skrining | "Skrining Risiko Diabetes", "Langkah 1 dari 3", age/BB/TB fields |
| SCR-02 | Validation | Enter out-of-range values → next | Inline validation blocks; no crash |
| SCR-03 | Transparency gate | Valid values → next | E05 dialog: "instrumen belum tersedia", two actions (Kembali / Lihat Contoh Hasil) |
| SCR-04 | Simulation result | Lihat Contoh Hasil | S10: 50% donut + permanent "SIMULASI" badge + 3 recommendations + "Selanjutnya" |
| SCR-05 | No false medical claim | Complete flow | No screen implies the % is the child's real risk |
| SCR-06 | Risk meter update | After simulation → back to Home | Meter reflects result while still labeled simulation |

## Open questions

1. Should the simulation result be derived from the entered inputs (even as a
   placeholder), or is a fixed 50% demo acceptable for D0?
2. When `latestRiskCategory` is set by a simulation, should the home risk meter
   carry a "SIMULASI" qualifier in all states?

## Out of scope

- Validated screening instruments and real classification (GATED, requires
  ethics/content approval).
- Any automatic clinical recommendation (FR-17).
