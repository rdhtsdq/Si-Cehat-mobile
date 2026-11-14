# 07 — Nutrition & Food Diary

## Context

`NutritionProvider` (`lib/providers/nutrition_provider.dart`) covers the food
catalog (`GET /api/nutrition/foods`), single/batch calculation
(`POST /api/nutrition/calculate[-batch]`), daily target
(`GET/PUT /api/nutrition/target`), summary (`GET /api/nutrition/summary`), photo
analysis (`POST /api/nutrition/analyze-photo`), and batch save to the food diary
(`POST /api/food-diary/batch`). Offline is handled via a 22-item local catalog
(`lib/data/local_food_catalog.dart`) and a SharedPreferences-backed
`PendingNutritionQueue` (`lib/core/services/pending_nutrition_queue.dart`).
Screens: `NutritionCalculatorScreen`, `PhotoAnalysisFlow`, `FoodDiaryScreen`.

## Findings / Integration Issues

### P1 — `saveDraftToDiary` silently drops data on offline enqueue
`saveDraftToDiary` (`nutrition_provider.dart:280-331`) POSTs; on failure it
enqueues the payload, then **clears the draft** and returns `false`. The UI must
distinguish "saved to server" from "queued offline". If the UI shows a failure
toast while the batch is actually queued (or vice versa), the user may retry and
double-submit. Verify the queued state is surfaced (see `pendingSyncCount`).

### P2 — Photo analysis save has no offline queue
Unlike `saveDraftToDiary`, `savePhotoResultToDiary` (`:371-418`) returns `false`
on failure and does **not** enqueue to `PendingNutritionQueue`. A photo-derived
meal captured offline is lost (no retry), inconsistent with the text-path
offline behavior.

### P2 — Local food ids use `local-` prefix heuristic
`calculateDraft` (`:252`) and `saveDraftToDiary` (`:293`) decide whether to send
`foodId` by checking `item.food.id.startsWith('local-')`. If the local catalog
ids ever change prefix, offline items would be sent as remote `foodId`s and fail.
The contract between `local_food_catalog.dart` ids and this heuristic is implicit.

### P3 — Unit conversions are magic constants
Per `docs/nutrition-module.md`: gram = as-is, porsi = 150g, potong/butir = 60g,
gelas = 200g. These conversions should be tested end-to-end since the doc states
them as the product rule.

## Requirement

- FR-08: filtered traditional menu + detail; nutrition only if approved.
- FR-13: offline; outbox/retry/conflict (D1).
- `docs/nutrition-module.md`: catalog fallback 22 items; target default AKG;
  `yyyy-MM-dd` local date sent as UTC-midnight by backend.
- NFR-09: date handling.

## QA Checklist (manual)

| ID | Scenario | Steps | Expected |
| --- | --- | --- | --- |
| NUT-01 | Catalog offline | Airplane mode → open Nutrition | 22-item local catalog renders; "offline" notice shown |
| NUT-02 | Catalog online | Online → open Nutrition | Remote catalog loads and replaces cache |
| NUT-03 | Quick calculate | Pick food → set weight → calculate | Values computed (local fallback if offline) |
| NUT-04 | Batch totals vs target | Add several items → view total vs daily target | Totals + % vs target correct |
| NUT-05 | Save to diary | Select date + meal slot → save | Summary reloads; entries persist |
| NUT-06 | Save offline → queue | Airplane mode → save batch | Batch queued (pendingSyncCount>0); no data loss on retry |
| NUT-07 | Queue flush on reconnect | Offline save → go online → reopen Nutrition | Pending batch flushes; no duplicates |
| NUT-08 | Photo analysis | Upload food photo → analyze | Result items returned; save-to-diary works (online) |
| NUT-09 | Photo analysis offline | Airplane mode → analyze/save | **Currently expected to fail** — result not queued (record against NUT-06 parity) |
| NUT-10 | Target edit | Edit daily target → save | Persists (cache + `PUT /api/nutrition/target`) |
| NUT-11 | Unit conversion | Test gram/porsi/potong/gelas | Matches doc rules (150/60/200g equivalents) |

## Open questions

1. Should photo-analysis results be enqueued offline like text batches (parity)?
2. How should the UI label a batch that is "queued offline" vs "saved"? Current
   provider returns `false` for both server-failure-queued and hard-failure.
3. Is the `local-` id prefix a stable contract, or should offline items use a
   dedicated `source: 'local'` field?

## Out of scope

- Clinical validity of nutrition values / AKG targets (require review).
- Backend food dataset maintenance.
