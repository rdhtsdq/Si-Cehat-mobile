# Assumptions Log — Si-Cehat PlayLab MVP

> **Date:** October 2026  
> **Phase:** Phase 0 Intake & Baseline

This document records all explicit working assumptions made for the MVP implementation. Each assumption addresses an area where a decision or reviewed asset is pending, ensuring implementation proceeds predictably without making irreversible architectural choices.

---

## 1. Clinical & Nutrition Content Assumptions

| ID | Assumption Summary | Rationale & Fallback |
|---|---|---|
| **ASM-01** | **Plate Architecture follows Kemenkes RI "Isi Piringku" 4-part division.** | The Indonesian national guideline divides a balanced plate into 4 main categories: Makanan Pokok (Karbohidrat), Lauk Pauk (Protein), Sayuran, and Buah-buahan. We adopt these 4 quadrants on the interactive plate. |
| **ASM-02** | **Starter food items (14 items) serve as version `1.0.0` content.** | Initial items (Nasi Beras Merah, Kentang, Jagung, Ikan Bakar, Telur, Tempe, Bayam, Wortel, Sop, Pisang, Pepaya, Apel, and 2 distractors: Donat Cokelat, Soda) are defined in an external JSON schema (`v1.json`). If clinical nutritionists modify items or caloric values, only the JSON file changes. |
| **ASM-03** | **Distractor food feedback is constructive and non-punitive.** | Choosing items high in refined sugar (e.g. donut, soda) produces educational coaching from Nimbo (e.g., *"Waduh, donat terlalu manis untuk makanan utama! Ganti dengan buah segar ya."*) without penalty points, fear appeals, or body-shaming. |

---

## 2. Product & UX Assumptions

| ID | Assumption Summary | Rationale & Fallback |
|---|---|---|
| **ASM-04** | **Hybrid interaction: Drag-and-drop with single-tap fallback.** | Children aged 6–12 have varying motor coordination and device screen qualities. The primary interaction is dragging food cards to the plate quadrants; tapping a card directly places it in its matching quadrant. |
| **ASM-05** | **Session length is 3–5 minutes across 3 focused rounds.** | Round 1 introduces staple + protein; Round 2 introduces vegetables; Round 3 challenges the child to complete the entire balanced plate and avoid sugary distractors. |
| **ASM-06** | **Language is simplified Bahasa Indonesia.** | Instructions and feedback use short, direct Indonesian phrases with bold visual cues, accessible for early readers. |

---

## 3. Architecture & Technical Assumptions

| ID | Assumption Summary | Rationale & Fallback |
|---|---|---|
| **ASM-07** | **Stand-alone Web Game repository is `si-cehat-game-web`.** | Built with Vite + React 19 + TypeScript + Tailwind CSS. Can be deployed to any static host (e.g., Vercel, Cloudflare Pages, S3/CloudFront, or served statically by the backend in development). |
| **ASM-08** | **Backend authority for scoring and rewards.** | The client submits chosen item IDs (`plateItems`) and answer IDs; the backend (`POST /api/game-sessions/:id/complete`) computes canonical `gameplayScore` and `knowledgeScore`. Spoofed client scores are ignored. |
| **ASM-09** | **Short-lived bootstrap code protects against token leakage.** | When Flutter launches the WebView, it requests a session from the backend (`POST /api/game-sessions`) and receives a short-lived, single-use bootstrap token (`bootstrapToken`) valid for 60 seconds. The game exchanges this code for session authorization, preventing long-lived JWTs from sitting in browser history or WebView URLs. |
| **ASM-10** | **Online connectivity is required for MVP sessions.** | Playing requires server connection to initialize sessions and confirm results. In the event of network disruption during play, the game retains local state and offers a friendly "Coba Kirim Lagi" retry button. |
| **ASM-11** | **Flutter integration uses `webview_flutter: ^4.10.0`.** | Standard Flutter official plugin supporting Android & iOS WebViews with `JavaScriptChannel` for bridge communications (`PlayLabBridge`). |

---

## 4. Research & Evaluation Assumptions

| ID | Assumption Summary | Rationale & Fallback |
|---|---|---|
| **ASM-12** | **Knowledge assessment is decoupled from practice rounds.** | In-game practice feedback does not affect the research knowledge score. If a research evaluation protocol is active, a distinct knowledge check screen is displayed before or after play without revealing answers beforehand. |
| **ASM-13** | **Data export uses pseudonymized participant codes.** | Direct personal identifiers (child full name, guardian phone number) are excluded from `/api/research/export`. Exports contain `participantCode` (or hashed `childId`), session metadata, versions, and timestamped process events. |
| **ASM-14** | **Formative usability pilot (5–8 participants) evaluates usability, not clinical efficacy.** | Initial testing gathers qualitative UX data (task completion, comprehension of instructions, device touch accuracy) without asserting statistical health outcomes. |
