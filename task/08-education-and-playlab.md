# 08 — Education & PlayLab

## Context

`EducationProvider` (`lib/providers/education_provider.dart`) loads recipes
(`GET /api/recipes`), meal plans (`GET /api/meal-plan`), education articles
(`GET /api/education/articles`), and dynamic content/quiz (`GET /api/content`),
with bundled `SeedData` recipes/quiz as offline fallback. Screens:
`EducationScreen` (S15), `PustakaEdukasiScreen`, `EducationDetailScreen` (E09),
`QuizScreen` (E10), `MenuCatalogScreen` (S12), `MenuDetailScreen` (S13),
`MealPlanScreen`. PlayLab is a web game embedded via `webview_flutter` in
`PlayLabGameScreen`, communicating through a `PlayLabBridge` JavaScript channel;
scores are persisted by `PlayLabStorageService` and shown in `PlayLabScoreDialog`.
See `docs/playlab-integration-guide.md`.

## Findings / Integration Issues

### ✅ Verified non-bug — PlayLab date handling (NFR-09)
`playlab_storage_service.dart:84` derives the diary date via
`result.completedAt.toIso8601String().substring(0,10)`. `completedAt` defaults to
`DateTime.now()` (local) and the game's `GAME_COMPLETED` payload does not send
`completedAt`, so the value is local and the date is correct. No code change
needed; revisit only if the game later sends a UTC `completedAt`.

### P2 — `fetchRecipeDetail` returns null for bundled ids
`education_provider.dart:112-114`:
```dart
if (id.isEmpty || id.startsWith('rec_')) return null;
```
This intentionally skips the network for local seed recipes, but it means
`MenuDetailScreen` must render the bundled `RecipeModel` directly and can never
fetch an updated server version of a seed item if one later exists.

### P2 — Desktop fallback bypasses the bridge
Per `docs/playlab-integration-guide.md` §6, desktop shows a launcher with a
"Simulasi Selesai" button. Manual simulation writes a score without going through
`GAME_COMPLETED`, so end-to-end bridge verification is only possible on
Android/iOS (or via unit tests on `PlayLabStorageService`).

### P3 — Education content typed as generic, filtered by string
`getVideos/getPodcasts/getArticles` (`:348-355`) filter by `e.type` string
(`'video'`, `'podcast'`, `'artikel'|'makanan'|'umum'`). A backend type value that
doesn't match these literals is silently dropped from all lists (e.g. a new
`'infografis'` type would vanish).

## Requirement

- FR-09: video/podcast/quiz shell; local short content + example quiz; real media
  requires licensed assets.
- FR-08 / FR-19: menu catalog + detail; content must be approved/versioned (D1).
- PlayLab: session bootstrap handshake, `GAME_READY`/`GAME_COMPLETED`/`EXIT_GAME`
  protocol, score persistence + diary auto-log, deduplication.
- Zero-emoticon visual policy (§7 of the guide).

## QA Checklist (manual)

| ID | Scenario | Steps | Expected |
| --- | --- | --- | --- |
| EDU-01 | Recipes offline | Airplane mode → Menu | Bundled recipes (Sayur Asem, Pepes Ikan, Nasi Tutuk Oncom) render |
| EDU-02 | Recipes online | Online → Menu → filter/search | Remote recipes load; category filter + search work |
| EDU-03 | Recipe detail | Tap a recipe | Detail with ingredients/portion/steps |
| EDU-04 | Meal plan | Open Meal Plan | 7-day plan renders; risk + target calories shown |
| EDU-05 | Education tabs | Edukasi → Video/Podcast/Quiz | Correct items per tab; empty state when none |
| EDU-06 | Quiz | Start quiz → answer → finish | Score shown with "Jawaban Benar" feedback (not risk) |
| EDU-07 | PlayLab launch (mobile) | Edukasi/Home → Main Sekarang | WebView loads `/playlab`; loading hides on `GAME_READY` |
| EDU-08 | PlayLab complete | Finish game | `GAME_COMPLETED` → score dialog; score saved; activity auto-logged |
| EDU-09 | PlayLab dedup | Complete + exit + resume same session | No duplicate score dialog or diary entry |
| EDU-10 | PlayLab date boundary | Complete game near midnight (Jakarta) | Diary entry lands on correct local date (NFR-09) |
| EDU-11 | Desktop fallback | Run on desktop → PlayLab | Browser launcher + "Simulasi Selesai" path works |

## Open questions

1. Is `completedAt` sourced from the game in UTC or local? (Drives the NFR-09
   fix.)
2. Should bundled `rec_*` recipes also be fetchable/updatable from the server, or
   is the seed canonical forever?
3. Should unknown education `type` values fall through to "Articles" rather than
   being dropped?

## Out of scope

- The web game itself (React/Vite repo `si-cehat-game-web`).
- Backend game-session/bootstrap endpoints.
- Real (licensed) media content — only shell + sample assets.
