# 00 — MVP Overview

## 1. Summary

**Working name:** Si-Cehat PlayLab  
**MVP game:** Piring Sehat Nimbo  
**Delivery:** HTML5 web game displayed inside the Si-Cehat Flutter application using a WebView  
**Primary purpose:** Deliver a short health-education experience and support structured evaluation of learning outcomes.

The MVP must prove that one game can be played reliably, integrated safely, persist results correctly, and produce data suitable for a planned research protocol. It is not intended to be a full game platform.

## 2. Product goals

1. Teach a clearly defined health-learning objective through interaction.
2. Provide a child-friendly, touch-first experience.
3. Integrate the game into the existing Flutter app.
4. Store sessions and validated results through the existing Si-Cehat backend where feasible.
5. Separate game performance from measured knowledge.
6. Record game/content/rules/instrument versions for research traceability.
7. Support a controlled usability pilot and, if approved, a learning-outcome study.

## 3. Target users

The initial working age range is 6–12 years, subject to confirmation against the actual research population. UI, language, task difficulty, touch targets, and assessment items must be reviewed for the selected age group.

Primary user: child using the Si-Cehat app.  
Secondary user: parent/guardian supporting app access where appropriate.  
Administrative user: authorized researcher or study staff accessing approved aggregate or pseudonymized data.

## 4. MVP scope

### In scope

- One game: Piring Sehat Nimbo.
- Intro/instructions screen.
- Touch-friendly food-card selection and drag-and-drop interaction.
- A defined set of game rounds.
- Educational feedback reviewed by a relevant subject-matter expert.
- A knowledge-check flow, if an appropriate instrument and protocol are approved.
- Results screen.
- Flutter WebView launcher and lifecycle handling.
- Backend-created game session.
- Server-side validation of completion and final results.
- Minimal, purpose-limited event tracking.
- Game and assessment version tracking.
- Authorized research data export sufficient for the pilot.
- Functional, security, usability, and data-integrity tests.

### Out of scope

- Multiplayer or public leaderboards.
- Complex virtual-pet systems.
- Multiple games in the first release.
- Virtual currency, stores, or transferable rewards.
- AI-generated or dynamically changing health guidance.
- A generic game-authoring platform.
- Complex real-time research dashboards.
- Claims that gameplay alone proves real-world behavior change.

## 5. Core user journey

1. The child opens the game area in Si-Cehat.
2. Flutter requests an authorized game session from the backend.
3. Flutter opens the allowlisted web-game origin.
4. The game presents instructions and runs the gameplay.
5. The child completes the knowledge-check flow, if enabled by the approved study design.
6. The game requests completion through the agreed API/bridge contract.
7. The backend validates the session and calculates or verifies results.
8. Flutter fetches the final result from the backend and displays it.
9. Authorized study staff can export the minimum required research dataset.

## 6. Success criteria

The MVP is ready for a controlled pilot when:

- The core game flow works on supported target devices.
- The game can be opened and exited from Flutter without breaking session state.
- Critical API and authorization tests pass.
- Final scoring is server-validated or independently recomputed from submitted answers under a versioned ruleset.
- Retried completion requests do not duplicate results or rewards.
- Game and instrument versions are recorded.
- Required data can be exported under access control without unnecessary direct identifiers.
- Usability testing identifies no unresolved critical blocker.
- Research and child-protection procedures have been reviewed by the responsible study owner.

Educational effectiveness is **not** an MVP engineering acceptance criterion. It requires an appropriate research design and analysis.

## 7. Proposed schedule

Indicative estimate for one developer already familiar with the repository:

| Phase | Estimate | Deliverable |
|---|---:|---|
| Repository audit and specification | 2–3 working days | Architecture findings, confirmed assumptions, UI/API plan |
| Standalone web gameplay | 3–5 working days | Playable game and unit-tested rules |
| Flutter/backend integration | 3–5 working days | End-to-end session and result flow |
| QA and initial usability pilot preparation | 3–5 working days | Test report, fixes, data verification |

Indicative total: 11–18 working days, excluding ethics approval, participant recruitment, instrument validation, and substantial changes to existing authentication or data models.

## 8. Delivery principles

- Build one end-to-end vertical slice before expanding scope.
- Audit the repository before changing it.
- Reuse existing architecture if appropriate.
- Keep the game independently buildable and testable.
- Treat the backend as the authority for sessions and results.
- Keep gameplay and knowledge scores distinct.
- Minimize child data collection.
- Version content and rules used in a study.
- Document unresolved assumptions rather than silently deciding them.

## 9. Decisions required before implementation

- Confirm target age and participant population.
- Confirm learning objectives and health content with a qualified reviewer.
- Confirm the assessment instrument and study design.
- Decide whether offline play is required.
- Identify existing user, child-profile, and authentication models.
- Decide which events are necessary for the research question.
- Confirm data access, retention, deletion, and consent/ethics procedures.
