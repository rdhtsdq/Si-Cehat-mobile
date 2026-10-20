# Si-Cehat PlayLab — Documentation Index

This folder contains the MVP requirements and implementation references for the Si-Cehat PlayLab web-based educational mini-game embedded in the Si-Cehat Flutter application.

## Document set

1. [`00-MVP-Overview.md`](00-MVP-Overview.md) — product scope, goals, non-goals, milestones, and acceptance criteria.
2. [`01-Game-Requirements.md`](01-Game-Requirements.md) — gameplay, user flow, UX states, scoring, feedback, and accessibility.
3. [`02-Technical-Architecture.md`](02-Technical-Architecture.md) — Flutter WebView, web game, backend integration, deployment, and architecture decisions.
4. [`03-API-Database-Spec.md`](03-API-Database-Spec.md) — proposed API contracts, data entities, validation, session lifecycle, and errors.
5. [`04-Research-Requirements.md`](04-Research-Requirements.md) — research objectives, assessments, event tracking, pilot plan, and data export.
6. [`05-Security-Privacy-Testing.md`](05-Security-Privacy-Testing.md) — child privacy, WebView security, authorization, test plans, and release gates.
7. [`docs/flutter-integration-guide.md`](docs/flutter-integration-guide.md) — Panduan integrasi teknis Flutter mobile (WebView, Bridge, Persistensi Skor, SQLite Diari Kesehatan).

The previously created comprehensive reference, `Si-Cehat-PlayLab-Game-Web-Reference.md`, may be retained as background material. These documents are the actionable, separated specifications.

## Recommended reading and implementation order

1. Read `00-MVP-Overview.md`.
2. Read `01-Game-Requirements.md` and confirm the learning content and scoring rules with the appropriate subject-matter reviewer.
3. Audit the existing repository before implementation; then read `02-Technical-Architecture.md` and `03-API-Database-Spec.md`.
4. Review `04-Research-Requirements.md` with the study owner before collecting participant data.
5. Apply `05-Security-Privacy-Testing.md` throughout development, not only before release.

## Instructions for a coding agent

- Treat these documents as requirements proposals, not proof that the current repository already has the named models, routes, or packages.
- Inspect the repository and report the current architecture before changing code.
- Reuse existing authentication, user/profile models, API conventions, logging, and test patterns where appropriate.
- Do not create duplicate user or child-profile models without a justified need.
- Do not perform destructive migrations or remove existing data.
- Build one end-to-end vertical slice before adding more games.
- Keep gameplay score separate from knowledge-assessment score.
- The backend must validate final results; do not trust a client-provided score.
- Record game, content, rules, and assessment versions for research traceability.
- Do not claim a test passed unless it was actually run.
- Do not claim educational effectiveness based on technical tests or a small usability pilot.

## Status and open decisions

These documents define an initial MVP proposal. Before implementation, confirm:
- Actual target age and participant population.
- Health topic and approved learning objectives.
- Whether a suitable assessment instrument already exists.
- Whether gameplay must work offline.
- Existing profile/authentication model and API conventions.
- Research protocol, consent/ethics requirements, data access, retention, and deletion rules.
- Whether the study uses a comparison group and requires follow-up assessment.

Use explicit assumptions in pull requests when a decision remains unresolved.
