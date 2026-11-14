# 11 — Consultation & Community

## Context

Both features are **transparent unavailable/preview states** in the demo, not
live services. `ConsultationScreen` (S16) shows three practitioner cards (Bidan,
Ahli Gizi, Dokter) that open a "layanan belum aktif" dialog on tap.
`CommunityScreen` (S17) has tabs Semua/Populer/Saya and a "+ Buat Postingan"
button that explains moderation/pilot requirements. `NotificationCenterScreen`
also lives under `screens/consultation/` and is the fallback destination for
non-reminder notification taps.

## Findings / Integration Issues

### P3 — Consultation cards imply availability
Seed notifications (e.g. "Layanan Konsultasi Tenaga Medis Mitra ... telah
tersedia", `seed_data.dart:186-188`) claim consultation is available, while S16
correctly says "belum aktif". This mixed messaging can confuse a demo reviewer.
Confirm copy is consistent with the D0/D2 stance.

### P3 — No deep-link/param handling for consultation/community
`NotificationNavigation` routes `CONSULTATION` → notification center only. A
consultation notification has no route to S16, and community has no notification
type mapping at all.

## Requirement

- FR-11: consultation options (Bidan/Ahli Gizi/Dokter) are P0 UI-unavailable;
  D2 after practitioners/channels approved.
- FR-12: community Semua/Populer/Saya + create post; P0 preview; D2 publication
  after moderation + privacy rules.
- AC-03: consultation & community transparently state "belum aktif".

## QA Checklist (manual)

| ID | Scenario | Steps | Expected |
| --- | --- | --- | --- |
| CONS-01 | Cards render | Home → Konsultasi | Bidan, Ahli Gizi, Dokter cards present |
| CONS-02 | Unavailable dialog | Tap a card | "Layanan konsultasi belum aktif" + emergency-facility guidance |
| CONS-03 | No fake success | Interact with consultation | No booking/chat implied as live |
| COMM-01 | Tabs + feed | Home → Komunitas | Semua/Populer/Saya tabs + labeled preview feed |
| COMM-02 | Create post | + Buat Postingan | Explains moderation/pilot; no real post published |
| COMM-03 | Copy consistency | Check notification vs S16/S17 copy | No "tersedia" claim contradicting "belum aktif" (verify — likely fail) |

## Open questions

1. Should the "Layanan Konsultasi ... telah tersedia" seed notification be
   reworded to "belum aktif pada prototipe" to match S16?
2. Do consultation notifications need to deep-link to S16, or is the notification
   center sufficient for D0?

## Out of scope

- Live telemedicine, chat, moderation, and practitioner onboarding (D2).
- Community governance/privacy (D2).
