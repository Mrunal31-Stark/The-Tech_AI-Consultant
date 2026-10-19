# CLAUDE.md — AI Tech Consultant (Capstone)

Source of truth for requirements: `rules/PROJECT_BRIEF.md`. If anything here conflicts with it, the brief wins. Re-read the relevant section of the brief before starting any task. `rules/` is gitignored (the brief is marked CONFIDENTIAL) — never copy its text into committed files.

## What we are building
One system, three connected tasks, built so ANY software/service business can plug in its own help center, inbox and meetings (no Brilliant Directories hardcoding outside config).

| Folder | Task | Language |
|---|---|---|
| `task1-knowledge-brain/` | Crawl + RAG + chatbot + API over the Brilliant Directories help center | Python 3.12, async, FastAPI, type hints, Pydantic v2 |
| `task2-inbox-agent/` | Email classify → fetch facts from Task 1 API → draft → learn from human edits → earned autonomy | TypeScript strict, Node/Next.js, typed end to end |
| `task3-scope-agents/` | Multi-agent: transcripts → scope of work + estimate + proposal, with meeting-to-meeting diff | Python 3.12, async, FastAPI |

## Hard rules (never break)
1. **One language per task.** No Python inside task2, no TS inside task1/task3. Python UIs = Streamlit or FastAPI+Jinja/HTMX. Task 2 UI = Next.js.
2. **Tasks 2 and 3 call Task 1 only over HTTP.** Never import Task 1 code. Task 2 generates its types from Task 1's `openapi.json` (openapi-typescript) so the contract is typed end to end.
3. **Claude is at the center.** Any non-Claude model (e.g. embeddings) needs a numbers-backed justification in EVALS.md.
4. **Every model choice is an eval decision.** For each place a model is chosen (classifier, drafter, answerer, image captioner, each Task 3 agent), compare ≥2 models (e.g. `claude-haiku-5-5` vs `claude-sonnet-5-5`) on 20–30 cases, recording quality, cost per call, latency p50/p95. Verify current model IDs against Anthropic docs before coding.
5. **All LLM outputs that code consumes use JSON schemas** (Pydantic / Zod), validated, with retry-on-invalid (max 2) then human fallback.
6. **Prompts are versioned files**, never inline strings: `prompts/<name>/v<N>.md` + a changelog line. Runtime logs record which prompt version produced each output. Rolling back = switching a version pointer.
7. **Human-in-the-loop:** nothing reaches a client (email or proposal) without approval, except email categories that have earned autonomy (Task 2 rules below).
8. **One command runs everything:** `docker compose up` from repo root. Keep it working after every change.
9. **Secrets** only via `.env` (commit `.env.example`). Never log API keys or full customer emails at info level.
10. **Polite crawling:** respect robots.txt, ≤1 req/sec with jitter, identifiable User-Agent, exponential backoff on 429/5xx, resumable checkpoint.

## Working agreement with me (the developer)
- I must be able to explain every line in a live review and make a change live. So: small modules, plain names, no clever abstractions, no framework I didn't approve.
- Before writing code for any new component: show a short plan (files, data flow, schemas) and wait for my OK.
- After each component: explain in ≤10 bullets what you built and the one thing most likely to break.
- Ask before adding any dependency. Prefer boring, well-known libraries.
- Write tests for main paths as you go (pytest + pytest-asyncio; vitest for TS). Do not mark work done if tests fail.
- Suggest a commit message after each logical unit. Small commits; I will commit myself.
- If a requirement in the brief is ambiguous, list the options with trade-offs and let me decide. Record the decision in `docs/DECISIONS.md` (one line each: decision, reason, date). These feed DESIGN.md.
- Never fake eval numbers. If something wasn't measured, say so.

## Task 1 — Knowledge Brain (definition of done)
- Ingest from `https://support.brilliantdirectories.com/support/sitemap.xml`; keep category → folder → article hierarchy as metadata.
- Batched, rate-limited, resumable first crawl (state in SQLite: url, lastmod, content_hash, status).
- Images: download, caption with Claude vision, store caption + alt + article link; captions are retrievable chunks tied to their article.
- Daily job (APScheduler): diff sitemap → add / update (re-embed only changed) / delete (tombstone so removed articles never appear in answers). Log a change report.
- Chat endpoint returns: answer, cited article URLs, confidence, and an honest "I don't know" below a threshold.
- Unanswered → creates an expert task (queue + simple UI); expert answer is stored as a first-class knowledge source with provenance and becomes retrievable.
- Clean REST API with OpenAPI docs + `API.md` usable by another developer alone (`/ask`, `/search`, `/articles/{id}`, `/expert-tasks`, `/health`).
- Simple chat UI.

## Task 2 — Inbox Agent (definition of done)
- `data/emails/` with ≥50 hand-written realistic emails covering: how-to, bug, refund, cancellation, complaint, quote request, new project, follow-up on old work, billing, angry, multi-intent, spam/abusive, non-English, prompt-injection attempt.
- Pipeline: classify (schema: category, intent, urgency, needs_followup) → query Task 1 API → draft in company voice with citations → human sends / edits / rewrites.
- Learning: store every (draft, final) pair with diff metrics; feed recent accepted edits as few-shot examples and style rules into the next prompt version. Must be measurable and undoable.
- Autonomy: a category auto-sends only after 20 consecutive drafts sent unchanged (define "unchanged" precisely, e.g. normalized edit distance ≤ threshold — document it). Any substantive edit, complaint or failed eval revokes autonomy. Risky categories (refund, complaint, legal) never auto-send.
- Follow-up tracker. Inbox UI with one-click send.

## Task 3 — Meeting → Scope of Work (definition of done)
- Agents with ONE job each (e.g. Extractor → Clarifier/Questioner → Product-fit checker (calls Task 1 to find existing settings vs custom code) → Estimator → Reviewer → Proposal writer). Orchestrator passes typed handoff objects.
- Long transcripts: chunk + map-reduce extraction with speaker/timestamp references.
- Outputs: scope of work, task list with hour estimates (with assumptions), client-ready proposal.
- Second meeting: versioned scope diff → changed / new / removed / out-of-scope-quote-extra.
- Human approval gate before anything is "sent".
- Transcripts in `data/transcripts/` are REAL recordings of role-played meetings (≥3, one is a follow-up). Do not generate fake transcripts as substitutes.

## Evals (`evals/` per task, results feed EVALS.md)
- ≥20 cases per task + a held-out set we never tune on (hidden tests exist).
- Measure: quality (rubric or LLM-judge with spot-checked human labels), cost per task in ₹ and $, latency, failure/retry rate, safety (bad input, injection, empty/garbage input).
- One script per task: `make eval-task1` etc. Output a markdown table.

## Repo layout
```
CLAUDE.md  README.md (≤1 page)  DESIGN.md (3–5 pages)  EVALS.md (2–3 pages)  AI_LOG.md (≤1 page)
docker-compose.yml  .env.example  Makefile
rules/            # gitignored
docs/DECISIONS.md
task1-knowledge-brain/  task2-inbox-agent/  task3-scope-agents/
```

## Writing style for all docs
Plain English, short sentences, written for a busy founder. Why before what. Numbers, not adjectives. Be honest about what does not work.