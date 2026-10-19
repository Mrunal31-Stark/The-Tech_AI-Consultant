# Decisions

One line each: decision — reason — date. Open questions live in `docs/PLAN.md` §6.

## Repo skeleton

- Postgres 17 + pgvector, one server, one database per task (`kb`, `inbox`, `scope`) — one store to explain; tasks never share tables (PLAN A3 option a) — 2026-10-18
- Postgres published on host port 5433, not 5432 — a local PostgreSQL 18 already uses 5432 — 2026-10-18
- Postgres port bound to 127.0.0.1 only — the local-dev default password is weak; binding keeps the no-`.env` run safe on shared networks — 2026-10-19
- Ports: Task 1 = 8001, Task 2 = 3000, Task 3 = 8003 — fixed, easy to remember, one per task — 2026-10-18
- Every service exposes `GET /health` → 200 `{"status":"ok","service":"<name>"}`, also used as the compose healthcheck — one uniform liveness check — 2026-10-18
- `/health` does not ping the database yet — no service uses the DB yet; add the check when the first one does — 2026-10-18
- Python deps pinned in `requirements.txt` / `requirements-dev.txt`; `pyproject.toml` holds tool config only — plain pip, nothing extra to learn — 2026-10-18
- Python checks: ruff (lint + format), mypy `--strict`, pytest + pytest-asyncio (`asyncio_mode=auto`) — matches the "typed, tested" bar — 2026-10-18
- Task 2: Next.js 16 + React 19, TypeScript 6.0 with `strict` and `noUncheckedIndexedAccess`, vitest — TypeScript 7 (Go rewrite) skipped until Next 16 supports it — 2026-10-18
- `make test` runs lint, typecheck and tests inside the service images (dev deps baked in) — CI and local use the same toolchain; costs some image size — 2026-10-18
- `docker compose up` works with no `.env`; every value has a local-dev default and `.env` is optional — one-command run on a fresh clone — 2026-10-18
