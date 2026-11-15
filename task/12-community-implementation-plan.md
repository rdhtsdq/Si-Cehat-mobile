# Community Feature Implementation Plan

> Tracks the end-to-end build across two repos:
> - Backend + admin: `../Si-Cehat/` (Hono + Drizzle + React/Vite admin)
> - Flutter: `lib/` (Riverpod ChangeNotifier + http)
>
> Full feature/flow/boundary spec: `/home/sectra/.opencode/plan/community-feature-plan.md`

## Decisions (confirmed)
- Moderation: **post-moderation** (PUBLISHED immediately; admin hide/restore/delete).
- Demo: **read-only** (write requires real login).
- Scope: **feed + create + like + comment**.
- **Author self-delete** posts & comments.
- **Rate-limit**: 5 posts/hr, 20 comments/hr (IP).
- **Mask author name** in public payload.
- **Popular = 30-day window**.
- Push notifications: deferred.
- Always-online; no offline queue.

## Tracks
- [x] 1. Backend schema + relations + `db:generate` (+ applied via `db:migrate`).
- [x] 2. Backend parent routes `community.routes.ts` + mount.
- [x] 3. Backend admin routes `admin-community.routes.ts` + mount.
- [x] 4. Seed posts/comments.
- [x] 5. Backend tests (schemas/serializers); typecheck + `bun test` green.
- [x] 6. Admin UI `CommunityModerationTab.tsx` + wiring.
- [x] 7. Flutter constants + models + `CommunityProvider` + `app_providers.dart`.
- [x] 8. Backend additions: self-delete, rate-limit, mask, popular-30d, admin comment delete + tests.
- [x] 9. Flutter screens: rewrite `community_screen.dart`, add detail + create screens, self-delete UI.
- [x] 10. Flutter tests + `flutter analyze` + `flutter test`.
- [x] 11. Update `task/11-consultation-and-community.md` status.
