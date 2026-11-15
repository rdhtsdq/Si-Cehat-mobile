# Rencana — Settings AI Vision (Analisis Foto Makanan)

> Lokasi: fitur ini berada di **backend + web admin** (`../Si-Cehat/`).
> Flutter **tidak** berubah (kontrak respons `/api/nutrition/analyze-photo` tetap).

---

## 1. Konteks

Fitur "foto makanan" meminta pengguna memotret makanannya, lalu backend
mengirim gambar ke model AI (vision) untuk menebak makanan dan nilai gizinya.

**Kondisi saat ini (`src/server/services/vision.ts`):**
- Selalu memanggil `${baseUrl}/chat/completions` dengan `Authorization: Bearer`
  dan content `image_url` — **hanya kompatibel OpenAI**.
- Membaca model & API key dari konfigurasi **chat bot** (`getResolvedBotConfig`),
  bukan konfigurasi vision terpisah.
- Prompt hanya meminta `[{name, weightGram}]`, lalu backend mencocokkan nama ke
  katalog `foodItems` untuk menghitung gizi (bukan AI yang mengeluarkan gizi).

**Dokumentasi provider (sudah diverifikasi, 2026):**

| Provider | Endpoint | Auth | Model vision | Protokol |
| --- | --- | --- | --- | --- |
| OpenAI | `https://api.openai.com/v1/chat/completions` | `Bearer` | `gpt-4o-mini` | OpenAI `chat/completions` + `image_url` |
| DeepSeek | `https://api.deepseek.com/chat/completions` | `Bearer` | `deepseek-flash` (vision ✓) | OpenAI-compatible + `image_url`, `detail:"low"`, `thinking:disabled`, `response_format:json_object` |
| Google Gemini | `https://generativelanguage.googleapis.com/v1beta/interactions` | `x-goog-api-key` | `gemini-4-hydrogen` | `interactions`, `input:[text,image(data)]`, `response_format:application/json+schema` |

Catatan: `deepseek-v4-pro` **tidak** mendukung vision; hanya `deepseek-flash`.

**Keputusan yang sudah dikonfirmasi:**
1. Output AI = **nutrisi langsung** (per item: `name, weightGram, caloriesKkal,
   carbsGram, proteinGram, fatGram, sugarGram, fiberGram`). Tanpa pencocokan
   katalog (`foodId = null`, `isEstimate = true`).
2. Settings vision disimpan di **tabel terpisah** (`visionConfigs`), bukan
   digabung ke `botConfigs`.

---

## 2. Tujuan

Membangun **settings admin untuk AI vision (foto makanan)** yang:
1. Punya **skema endpoint + key** per provider (`openai`, `deepseek`, `google`),
   bisa dikonfigurasi dari web admin dan disimpan ke DB.
2. **Menambah provider DeepSeek dan Google (Gemini)** selain OpenAI.
3. **Mengkonfigurasi AI agar merespon sependek mungkin** dan **langsung
   mengeluarkan nutrisi** (JSON ringkas, tanpa kalimat pengantar).
4. Tetap menjaga kontrak respons `/nutrition/analyze-photo` (`items[] + totals`)
   sehingga Flutter tidak berubah.

---

## 3. Batasan

### 3.1 Batasan fungsional
- Hanya menyentuh **backend + web admin**. Tidak ada perubahan Flutter.
- Output per item memuat 8 field; **tanpa pencocokan katalog** (`foodId` selalu
  `null`, `isEstimate` selalu `true`).
- Provider yang didukung: `openai`, `deepseek`, `google`. Provider lain (mis.
  Anthropic) di luar lingkup.
- **Tanpa upload gambar permanen / Files API** — gambar dikirim inline base64.
- **Tanpa perubahan kontrak** `PhotoAnalysis { items, totals }`.

### 3.2 Batasan teknis
- **Respon pendek**: `temperature = 0.1`, `maxTokens = 400`, mode JSON, dan untuk
  DeepSeek `thinking: disabled` + `detail: "low"` (downscale 512px).
- Protokol berbeda per provider: OpenAI/DeepSeek pakai `chat/completions`;
  Google pakai `interactions` (auth `x-goog-api-key`, bukan Bearer).
- Konfigurasi disimpan di tabel baru `visionConfigs` (id = `default`), dengan
  fallback env. DB override menang atas env.
- Migrasi DB baru (`db:generate` + `db:migrate`).

### 3.3 Batasan keamanan
- API key tidak pernah dikirim balik dalam bentuk mentah — selalu di-mask
  (`maskApiKey`), pola sama seperti `bot-config`.
- Prompt vision tetap edukatif (asisten gizi, bukan tenaga medis; tanpa
  diagnosis/saran medis).

### 3.4 Di luar lingkup (out of scope)
- Provider Anthropic/Vertex, multi-key per provider, upload File API.
- Perubahan alur Flutter (pick → analyze → simpan) atau UI mobile.
- Auto-retry / failover multi-provider.

---

## 4. Objektif Pencapaian (kriteria sukses)

1. **Settings tersedia di admin** — admin bisa memilih provider
   (`openai`/`deepseek`/`google`), mengisi/mengganti endpoint + API key + model +
   prompt, dan menyimpannya; nilai tersimpan ke `visionConfigs` dan terbaca ulang.
2. **DeepSeek & Google berfungsi** — `POST /api/nutrition/analyze-photo` berhasil
   mengembalikan `items[] + totals` untuk ketiga provider (openai, deepseek,
   google) tanpa crash pada perbedaan protokol.
3. **Output pendek & langsung nutrisi** — respons AI berupa JSON array 8 field
   (tanpa preamble), terparse menjadi `items` dengan nilai gizi per item.
4. **Kontrak respons stabil** — payload `/nutrition/analyze-photo` identik
   bentuknya dengan sebelumnya (Flutter tak berubah).
5. **Tes hijau** — `bun run typecheck` bersih, `bun test` lulus (termasuk tes
   parser nutrisi + builder request per provider + resolusi config).
6. **Migrasi diterapkan** — tabel `VisionConfig` ada di DB, seed/fallback aman.

---

## 5. Rencana Teknis (file & langkah)

### Backend (`../Si-Cehat/`)
1. **Schema** (`src/server/db/schema.ts`) — tabel `visionConfigs`:
   `id ("default"), provider, model, baseUrl, apiKey, systemPrompt, temperature
   (0.1), maxTokens (400), updatedAt`. → `db:generate` + `db:migrate`.
2. **Env** (`src/server/env.ts`, `.env.example`) — tambah `VISION_PROVIDER`,
   `VISION_BASE_URL`, `VISION_API_KEY`, `DEEPSEEK_API_KEY`, `GEMINI_API_KEY`
   (pertahankan `VISION_MODEL`).
3. **Service baru** (`src/server/services/vision-config.ts`) —
   `getResolvedVisionConfig()` dengan preset endpoint/model/key per provider +
   fallback env + override DB.
4. **Refactor** (`src/server/services/vision.ts`):
   - Prompt baru (JSON-only, ringkas).
   - Parser baru (nama + berat + 6 nilai gizi).
   - Helper murni `buildVisionRequest(provider, config, imageBase64)`.
   - `analyzeFoodPhoto` memakai `getResolvedVisionConfig()` + helper.
5. **Admin routes** — `GET/PUT /api/admin/vision-config` +
   `POST /api/admin/vision-config/test` (mirror `bot-config`; test = ping +
   opsional `imageBase64`).
6. **Admin UI** (`AdminDashboardClient.tsx`) — section/tab "Vision / Foto Makanan":
   dropdown provider (auto-isi baseUrl + model), key, prompt, temperature,
   maxTokens, tombol test.
7. **Tes** (`src/server/__tests__/vision.test.ts`) — parser + `buildVisionRequest`
   + resolusi config.

### Verifikasi
- `bun run typecheck`, `bun test`.
- `bun run db:generate` + `bun run db:migrate`.

### Perlu diverifikasi saat implementasi
- Field respons Gemini `interactions` (`output_text` vs `outputText`) — cek
  referensi REST sebelum menulis parser.
- Model Gemini default: `gemini-4-hydrogen` (dokumen) vs `gemini-3.5-flash-lite`
  (lebih cepat) — pakai `gemini-4-hydrogen` dulu, bisa diubah via settings.

---

## 6. Tambahan — Mencoba model gratis Gemini

Jalur `google` (Interactions API) tidak ideal untuk uji cepat karena dokumentasi
Gemini 2026 memakai `POST /v1beta2/interactions` dengan output berupa
`steps[] { type: "model_output", content: [{ type: "text" }] }`, sementara
beberapa halaman lain masih menampilkan `/v1beta/interactions` + `output_text`.

Agar uji model gratis aman, ditambahkan provider **`gemini-openai`**:

| Item | Nilai |
| --- | --- |
| Base URL | `https://generativelanguage.googleapis.com/v1beta/openai` |
| Model default | `gemini-3.1-flash-lite` (tersedia di free tier) |
| Auth | `Authorization: Bearer <GEMINI_API_KEY>` |
| Protokol | OpenAI-compatible `chat/completions` + `image_url` data URL |
| Structured output | `response_format: { type: "json_object" }` |

Cara pakai:
1. Ambil API key gratis di Google AI Studio (`aistudio.google.com/apikey`).
2. Admin → **Vision (Foto Makanan)** → Provider = **Gemini via OpenAI-compatible (gratis)**.
3. Tempel API key → Simpan.
4. Di panel **Uji Vision**, pilih gambar makanan → **Kirim Uji**. Hasil harus
   berupa JSON array 8 field (`name, weightGram, caloriesKkal, ...`).

Catatan free tier Gemini (2026): `gemini-3-flash-preview` dan
`gemini-3.1-flash-lite` memiliki free tier di Gemini API. Model paid seperti
`gemini-3.1-pro-preview` tidak punya free tier.

Parser Google juga dibuat toleran terhadap `steps[]` (v1beta2) selain
`output_text` / `outputText` / `candidates[].content.parts`.
