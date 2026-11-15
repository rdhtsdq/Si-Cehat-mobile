# Rencana — Chatbot "Tanya Si Cehat" + Multi-provider Bot Config

## 1. Konteks

Backend sudah punya chat (OpenAI-only): `POST /api/chat` → `ai-orchestrator.ts`
→ `getResolvedBotConfig()` (selalu `Bearer` + `/chat/completions`), dengan
guardrail (blokir obat/diagnosis) + fallback mock + persistensi
`chatSessions/chatMessages`. Flutter belum punya UI chat. Modul admin
"Konfigurasi AI & System Prompt" ada tapi belum seperti Vision (provider
free-text, field endpoint/key/temperature/maxTokens tidak diekspos).

Pekerjaan = mirror yang sudah dilakukan untuk Vision: (1) layar chat Flutter,
(2) bot config multi-provider + orchestrator sadar-provider, (3) kuota harian.

## 2. Tujuan

1. Tambah tab bottom-nav ke-5 **"Tanya Si Cehat" di posisi tengah**, layar chat
   untuk pengguna umum.
2. Chatbot umum (bukan khusus anak) tetapi **dibatasi ke topik harian**
   (makan/minum, aktivitas, tidur, kebiasaan sehat) dan menolak hal
   klinis/diagnosis/obat.
3. Modul admin Bot AI & Prompt jadi **multi-provider**
   (`openai`/`deepseek`/`google`/`gemini-openai`) dengan dropdown provider +
   endpoint + API key + model + prompt + temperature + maxTokens + playground.
4. Tambah **kuota harian per pengguna** di atas rate-limit per-request.

## 3. Batasan

### 3.1 Fungsional
- Chat teks saja (tanpa upload gambar ke chat).
- Riwayat in-memory: kirim ulang seluruh utas tiap giliran (klien stateless).
  Tidak memuat sesi lama.
- Kuota harian default 30 pesan/pengguna/hari; user-id bila login, else IP.

### 3.2 Teknis
- Provider chat: `openai`, `deepseek`, `gemini-openai` (OpenAI-compatible) +
  `google` (native Interactions, teks saja, riwayat dilipat ke teks).
  `gemini-openai` = rute gratis yang disarankan.
- Kuota & rate-limit in-memory per instance (multi-instance butuh Redis —
  dicatat, tidak dikerjakan).
- Tidak ada tabel DB baru; `botConfigs` sudah memuat semua kolom. Tidak ada
  migrasi.

### 3.3 Keamanan
- API key selalu di-mask; guardrail obat/diagnosis tetap; prompt default baru
  tetap tanpa diagnosis/saran medis.
- Kuota memakai identity user-id/IP, bukan body yang bisa dipalsukan.

### 3.4 Di luar lingkup
- Multi-instance (Redis), upload gambar di chat, riwayat lintas sesi,
  streaming SSE, persona ganda.

## 4. Skema

### 4.1 Kontrak API (tetap)
```
POST /api/chat
req:  { messages: [{role:"user"|"assistant", content:string}], childId?, sessionId? }
resp: { message: string, sessionId?: string }
err:  429 { error:{ code:"RATE_LIMIT_EXCEEDED"|"DAILY_QUOTA_EXCEEDED", retryAfterSeconds? } }
```

### 4.2 Provider preset bot
| provider | baseUrl | model default | auth |
|---|---|---|---|
| openai | `https://api.openai.com/v1` | `gpt-4o-mini` | Bearer |
| deepseek | `https://api.deepseek.com` | `deepseek-chat` | Bearer |
| google | `https://generativelanguage.googleapis.com/v1beta/interactions` | `gemini-4-hydrogen` | `x-goog-api-key` |
| gemini-openai | `https://generativelanguage.googleapis.com/v1beta/openai` | `gemini-3.1-flash-lite` | Bearer |

### 4.3 Prompt default
`dailyAssistantSystemPrompt` di `@/lib/chat.ts`: asisten kesehatan harian umum,
Bahasa Indonesia, ringkas, scope harian, tolak diagnosis/obat/diet ekstrem.

## 5. Objektif Pencapaian (kriteria sukses)

1. Tab "Tanya" muncul di tengah (indeks 2 dari 5); chat dua arah jalan ke
   `/api/chat`.
2. Jawaban sesuai scope harian; pertanyaan obat/diagnosis dijawab guardrail.
3. Admin bisa pilih provider, isi endpoint/key/model/prompt/temperature/
   maxTokens, simpan, dan uji dari playground.
4. `openai`/`deepseek`/`gemini-openai` berfungsi; `google` tidak crash.
5. Kuota harian aktif (pesan ke-31 → 429 `DAILY_QUOTA_EXCEEDED`).
6. Tes hijau: `bun run typecheck` + `bun test`, `flutter analyze` +
   `flutter test`.

## 6. Rencana Teknis

### Backend (`../Si-Cehat/`)
- `services/bot-config.ts` — `BotProvider`, `BOT_PRESETS`, `resolveBotPreset()`,
  `resolveEnvBotKey()`, default prompt baru.
- `services/chat-request.ts` (baru) — `buildChatRequestBody()` murni per provider
  + `extractChatContent()`.
- `services/ai-orchestrator.ts` — pakai builder; hapus asumsi OpenAI.
- `services/chat-quota.ts` (baru) — `checkDailyQuota(identity, max)`.
- `routes/public.routes.ts` — identity via `getSession`/IP → cek kuota → 429.
- `env.ts` — `CHAT_DAILY_LIMIT` (default 30).
- `routes/admin.routes.ts` — provider enum + test route provider-aware.
- Tes: `chat-request.test.ts`, `chat-quota.test.ts`.

### Admin (`src/app/admin/`)
- Inline tab bot di `AdminDashboardClient.tsx` di-upgrade: dropdown provider +
  preset, endpoint, key, temperature, maxTokens (mirror Vision).

### Flutter (`Si-Cehat-mobile/`)
- `core/api/api_constants.dart` — `chat = '/api/chat'`.
- `data/models/chat_message.dart` (baru).
- `providers/chat_provider.dart` (baru) + daftar di `app_providers.dart`.
- `screens/chat/chat_screen.dart` (baru) — bubbles + input + typing + empty/error.
- `screens/shell/main_shell_screen.dart` — sisip tab indeks 2.
- Tes: `chat_provider_test.dart`, `chat_screen_test.dart`; update
  `si_cehat_full_test.dart`.

## 7. Risiko
- Indeks tab bergeser (Edukasi 2→3, Profil 3→4); tidak ada referensi indeks
  numerik di luar shell (kecuali test `initialIndex: 1` = Tracker, tetap).
- Kuota in-memory per instance.
- Google native chat riwayat dilipat ke teks; `gemini-openai` disarankan.
