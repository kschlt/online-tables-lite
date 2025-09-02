# CLAUDE_TASKS (Phased Plan + Guardrails)

## Guardrails (do not change unless asked)
- Roles: Admin & Editor only (no Viewer).
- Tokens in URL; SHA-256 hashes in DB; never log raw tokens.
- No cookies; no client → DB writes; all through FastAPI.
- CSV export/import permissioned via env flags.
- Mobile-first UX with a bottom toolbar for admin.

## Phase 0 — Bootstrap
- Scaffold monorepo (`apps/web`, `apps/api`), strict TS on web, Pydantic v2 on api.
- Add Socket.IO server in API.
- Add lint/test config; add TECHNOTES & CI files from repo.

## Phase 1 — Create & Read
- Implement `POST /api/table` (generate slug + 2 tokens; store hashes).
- Implement `GET /api/table/{slug}` (admin or editor token).
- Web `/table/[slug]` renders headers; no editing yet.
- Unit tests: token hashing, slug generation.

## Phase 2 — Edit + Realtime
- `POST /api/table/{slug}/cells` (editor/admin) batch upsert + emit.
- Web: optimistic debounced edits; subscribe to patches.
- Tests: two browsers (Playwright) see live cell updates.

## Phase 3 — Admin Config + Limits
- `/config` route (admin): rows/cols/headers/widths/today_hint; enforce limits.
- Web: admin drawer & +row/+col interactions.
- Tests: limits enforced, today highlight visible.

## Phase 4 — CSV import/export
- `/export` CSV stream; `/import` with size cap and snapshot pre-import.
- Flags: `ALLOW_EDITOR_EXPORT`, `ALLOW_EDITOR_IMPORT`.
- Tests: round-trip CSV; permissions respected.

## Phase 5 — Snapshots
- `/snapshot`, `/snapshots`, `/restore` (admin).
- Web: list + restore UI.
- Tests: snapshot → mutate → restore equals previous state.

## Phase 6 — Polish
- Comments (rate-limited), share modal, dark mode, a11y.
- Do not implement auto-retention yet; leave endpoint stub only.

**Definition of Done (per feature)**
- Correct role enforcement with hashed tokens.
- No token leakage in logs; CORS restricted.
- Debounced writes stable; “Saving/Saved/Error” status UX.
- CSV round-trip deterministic; snapshots idempotent.