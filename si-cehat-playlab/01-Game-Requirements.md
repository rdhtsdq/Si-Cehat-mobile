# 01 — Game Requirements

## 1. Purpose

Specify the user-facing behavior of the MVP game **Piring Sehat Nimbo**. The game is a short, touch-first educational mini-game in which a child helps Nimbo select a variety of foods and receives age-appropriate educational feedback.

The health content, accepted answers, and explanations must be reviewed by an appropriate nutrition/health subject-matter expert before use with research participants.

## 2. Learning objective

Proposed objective: help the child recognize food variety and understand basic principles of a balanced meal.

This is a working objective, not a validated learning standard. The study owner must approve its wording and map it to assessment items before implementation is considered final.

## 3. User flow and screens

### 3.1 Game entry

- The game is launched from the existing Si-Cehat app.
- The app must have an authenticated, authorized context or an explicitly approved alternative for the study.
- A session is created through the backend before a session-dependent game begins.
- The game must display loading and recoverable-error states.

### 3.2 Instructions

- Show one short instruction at a time.
- Use clear language suitable for the selected age group.
- Explain how to select or drag food cards.
- Provide a visible way to continue or exit.
- Avoid instructions that rely only on color.

### 3.3 Gameplay

- Display a plate area and a limited set of food cards.
- Support touch input.
- Allow the child to select or drag food cards into the target area.
- Provide a clear confirm/continue action if immediate validation would interrupt exploration.
- Show feedback based on versioned game rules.
- Provide a way to recover from accidental selection.
- Avoid punitive or shaming feedback.
- Avoid time pressure in the first MVP unless the research protocol specifically requires it.

### 3.4 Knowledge check

- Use items approved for the intended learning objective and age group.
- Keep assessment items distinct from practice feedback where possible.
- Do not reveal the correct answer before the response is recorded.
- Record the instrument version and the answers needed for scoring.
- Assessment score must be calculated or verified by the backend using a versioned scoring key.
- If the research protocol uses separate pre-test and post-test screens outside the game, follow that protocol rather than duplicating assessments inside the game.

### 3.5 Results

Display:
- Completion status.
- A child-friendly summary of the activity.
- An approved educational takeaway.
- A simple reward, if enabled.
- A clear return-to-app action.

Do not present a gameplay score as a health rating or as proof that the child has learned the material.

## 4. Gameplay rules

- Use a finite number of rounds suitable for a 3–5 minute target session.
- The initial set of foods and accepted responses must be defined in versioned content data.
- The game must handle invalid placement and accidental input gracefully.
- Scoring rules must be deterministic and unit-tested.
- The backend must not blindly trust a score supplied by the web client.
- If a final result depends on submitted answers, the backend should calculate the result from those answers and the relevant rules/instrument version.
- Keep gameplay score and knowledge score in separate fields and reporting.

## 5. Feedback requirements

Feedback should:
- Explain why a choice is appropriate or needs reconsideration.
- Use neutral, encouraging language.
- Be short enough for the target age group.
- Avoid shame, fear, or body-image language.
- Match content reviewed by the relevant subject-matter expert.
- Remain stable for the same content/rules version.

## 6. UX and accessibility

- Mobile-first responsive layout.
- Touch targets sized and spaced for children in the target age group.
- Do not rely on hover or mouse-only behavior.
- Support tap as a fallback if drag-and-drop is difficult.
- Text must remain readable at supported device sizes.
- Do not use color as the sole signal for correct/incorrect states.
- Provide visible focus/selection states where relevant.
- Avoid unnecessary motion and allow the game to remain usable on lower-powered devices.
- Provide a clear exit and prevent accidental loss of a completed result.
- Test on real devices, not only browser emulation.

## 7. Session and error states

The game must account for:
- Loading.
- Ready.
- In progress.
- Completion requested.
- Completion confirmed by backend.
- Recoverable network failure.
- Session expired or unauthorized.
- Exit requested.
- Game reload or app background/resume.

The UI must distinguish “result submitted” from “result saved on server.” Do not display a successful synchronization state before server confirmation.

## 8. Minimum analytics events

Track only events needed for the product and research objectives. Candidate events:

- `game_started`
- `round_started`
- `item_selected` or a suitably aggregated choice event
- `hint_used`, if hints exist
- `round_completed`
- `knowledge_check_submitted`
- `game_completion_requested`
- `game_completion_confirmed`
- `game_error`

Each event should have a schema, purpose, and retention policy. Do not record every pointer movement by default. Avoid direct identifiers and sensitive data in event payloads.

## 9. Acceptance criteria

- A child can complete the core flow using touch.
- Instructions and feedback are understandable in formative usability testing.
- Gameplay can be completed without a critical UI blocker.
- Incorrect or invalid input does not crash the game.
- Gameplay and knowledge scores remain separate.
- The game handles back navigation and recoverable failures.
- All content and scoring rules have version identifiers.
- The game does not make unsupported health claims.
