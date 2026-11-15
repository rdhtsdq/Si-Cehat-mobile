# 11 — Consultation & Community

## Context

**Consultation (S16)** remains a transparent preview state: three practitioner
cards (Bidan, Ahli Gizi, Dokter) that open a "layanan belum aktif" dialog.

**Community (S17)** is now a **live feature** (implemented after the initial
audit). `CommunityScreen` is a real feed with tabs Semua/Populer/Saya backed by
the backend, plus like, comment, create, and author self-delete. Moderation
happens in the web admin (`CommunityModerationTab`). See
`task/12-community-implementation-plan.md` and the full spec in
`/home/sectra/.opencode/plan/community-feature-plan.md`.

`NotificationCenterScreen` also lives under `screens/consultation/` and is the
fallback destination for non-reminder notification taps.

## Findings / Integration Issues

### P3 — Consultation cards imply availability
Seed notifications (e.g. "Layanan Konsultasi Tenaga Medis Mitra ... telah
tersedia", `seed_data.dart:186-188`) claim consultation is available, while S16
correctly says "belum aktif". This mixed messaging can confuse a demo reviewer.
Confirm copy is consistent with the D0/D2 stance.

### P3 — No deep-link/param handling for consultation/community
`NotificationNavigation` routes `CONSULTATION` → notification center only. A
consultation notification has no route to S16, and community has no notification
type mapping at all. (Community itself is live, but there is no notification
type that deep-links to it — deferred.)

## Requirement

- FR-11: consultation options (Bidan/Ahli Gizi/Dokter) are P0 UI-unavailable;
  D2 after practitioners/channels approved.
- FR-12: community Semua/Populer/Saya + create post — **implemented** (live feed,
  like, comment, author self-delete, admin moderation). P0 preview requirement
  superseded.
- AC-03: consultation still transparently states "belum aktif"; community is now
  live (no longer a preview banner).

## QA Checklist (manual)

| ID | Scenario | Steps | Expected |
| --- | --- | --- | --- |
| CONS-01 | Cards render | Home → Konsultasi | Bidan, Ahli Gizi, Dokter cards present |
| CONS-02 | Unavailable dialog | Tap a card | "Layanan konsultasi belum aktif" + emergency-facility guidance |
| CONS-03 | No fake success | Interact with consultation | No booking/chat implied as live |
| COMM-01 | Tabs + feed | Home → Komunitas | Semua/Populer/Saya load real posts (empty/error/loading handled) |
| COMM-02 | Create post | + Buat Postingan (real login) | Post publishes; appears in Semua + Saya (rate-limited 5/hr) |
| COMM-03 | Demo read-only | Mode demo → like/comment/create | Login prompt; feed still readable |
| COMM-04 | Author self-delete | Detail → Hapus Postingan (own post) | Post removed (cascade comments/likes) |
| COMM-05 | Admin moderation | Web admin → Komunitas | Hide/restore/delete posts + comments; scoped by posyandu |
| COMM-06 | Masked authors | Inspect feed | Author shown as "Ibu R***", no email/phone in payload |

## Open questions

1. Should the "Layanan Konsultasi ... telah tersedia" seed notification be
   reworded to "belum aktif pada prototipe" to match S16?
2. Do consultation notifications need to deep-link to S16, or is the notification
   center sufficient for D0?
3. Should community interaction (like/comment) trigger push notifications?
   (Deferred per product decision.)

## Out of scope

- Live telemedicine, chat, moderation, and practitioner onboarding (D2).
- Community reports, image upload, edit, and push notifications (deferred).

