# Surfer — Build Plan

> Local-first AI IDE. VS Code fork. BYOK at true API cost. No cloud, no accounts, no telemetry.
> Companion document: `surfer-prd.md` (full product requirements).

## Positioning

| | Cursor | Surfer |
|---|---|---|
| Base | VS Code fork | VS Code fork (same) |
| Model access | Curated list, marked up | BYOK: any provider, at API cost |
| Price | $20/mo + usage caps | Free BYOK app + optional paid managed-model tier (v1.1) |
| Cloud | Accounts, sync, teams, background agents | None. Local-only, no login required |
| Privacy | Code passes their backend | Code goes straight from user machine to chosen provider |

**Pitch:** "Same IDE experience; you pay Anthropic/OpenAI/DeepSeek directly at API prices. No middleman."

## Locked decisions

- **Monetization:** Free BYOK forever + paid subscription tier (Surfer Pro) with managed model access ("lots of models") via a minimal gateway. Paid tier is v1.1, never blocks v1.
- **Platforms:** macOS only for v1 (arm64 + x64). Windows/Linux after v1.1.
- **Autocomplete:** IN scope for v1 (local-model-first via Ollama).

## Milestones

| # | Milestone | Weeks | Notes |
|---|---|---|---|
| 0 | Fork bootstrap: fork `microsoft/vscode`, rebrand, Open VSX as marketplace, macOS signing/notarization, `surfer/` dir convention, electron-updater + GitHub Releases, AGENTS.md | 1–3 | Follow VSCodium's licensing/branding playbook |
| 1 | Model layer: provider abstraction (Anthropic, OpenAI, Google, xAI, DeepSeek, OpenRouter, Ollama/LM Studio), OS-keychain key storage, per-request cost meter, chat sidebar (streaming) | 3–6 | OpenRouter in from day 1 = "lots of models" for BYOK users |
| 2 | Agent tab: tools (file read/edit, terminal w/ approval, grep/glob, web fetch), diff review UX, git-plumbing checkpoints, step log, interrupt | 6–10 | Cursor parity feature #1 |
| 3 | Inline edit (Cmd+K) + fast-apply (cheap small model merges streamed edit hints) | 10–13 | Overlaps Phase 4 |
| 4 | Tab autocomplete: FIM via local models through Ollama ($0 marginal cost), optional API models, next-edit prediction, debounce + cache | 13–18 | Starts in parallel from week 10; default OFF until quality bar met |
| 5 | Local context engine: Merkle-tree change detection, chunking, sqlite-vec store, local embeddings (free/private) or cheap API embeddings, `@file/@folder/@codebase` mentions | 18–21 | Single file DB, no daemon, no Docker |
| 6 | Polish: settings UI, per-feature model assignment, "import VS Code settings" onboarding, docs, v1 launch (BYOK only) | 21–24 | Ship. Get users. |
| 7 | v1.1 — Surfer Pro: Stripe + minimal stateless gateway (auth, key injection, usage metering, plan rate limits) + "Surfer Pro" provider entry in model picker | +4–5 post-v1 | Only cloud component; separate tiny service, not IDE code |

## Fork discipline (survival rules)

1. All custom code in top-level `surfer/` directory; core changes only as minimal, documented patches.
2. Merge upstream `microsoft/vscode` releases monthly. Budget merge time forever.
3. Never fork an extension API surface in a way that breaks Open VSX extensions.
4. Write/maintain `AGENTS.md` at bootstrap — every build session loads context from the repo, never re-pasted.

## Execution model strategy (OpenCode Go)

| Role | Model | Why |
|---|---|---|
| Daily driver (~80% of work) | `opencode-go/deepseek-v4-pro` (high) | $0.66/$1.98 per Mtok, strong coder, ~22x cheaper output than K3 |
| Implementation sprints | `opencode-go/kimi-k2.7-code` | $0.95/$4, coding-tuned, well-scoped edits |
| Architecture + gnarly debugging (fork design, gateway design, upstream merges) | `opencode-go/kimi-k3` (max) | $3/$15 — sparingly |
| Chores, renames, docs | `opencode-go/cat-jam-free` | $0 |

Avoid for build work: Grok 4.7, Qwen3.8 Max ($2/$6, worst value), free preview models (quality risk).

**Quota protection:** one milestone = one OpenCode session; one prompt = one shippable unit; context always from `AGENTS.md`.

## Hard scope limits (do not build)

No accounts for BYOK. No settings sync. No teams. No background/cloud agents. No web version. No Windows/Linux until v1.1+. No MS marketplace (Open VSX only; document the MS-marketplace pointing trick at users' own risk).

## Risks

- Upstream drift → `surfer/` isolation + monthly merges.
- Autocomplete economics → local models default; paid tab-completion models are where cost creep lives.
- Maintenance treadmill → monthly merge budget is permanent.
- Marketplace lock-in → some MS extensions (Pylance etc.) unavailable; accepted.
- Paid-tier scope creep → gateway stays stateless and tiny; resell OpenRouter credits at transparent markup to start if provider negotiations stall.

---

## Progress Log

### Phase 0 — Fork bootstrap (started 2026-10-14)

Done:
- Repo initialized at `~/surfer` with `upstream` = microsoft/vscode, full history (167,680 commits) + tags. Local LFS filters disabled (global gitconfig had `filter.lfs.*` set but git-lfs not installed; vscode repo doesn't use LFS).
- Rebrand patch P-001: `product.json` → Surfer identity + Open VSX gallery (VSCodium-verified endpoints).
- Patch P-002: `AGENTS.md` Surfer Fork Directives appended.
- `surfer/` scaffold: README (fork rules), PATCHES.md registry (incl. TODOs: GUIDs, icons, reportIssueUrl, defaultChatAgent).
- Repo-level skills installed in `.agents/skills/` + `skills-lock.json`: ponytail suite, improve-codebase-architecture, playwright-best-practices, rag-architect, security-best-practices, vscode-ext-commands, electron-development (+ upstream's `launch`). Stale registry entries skipped: cursor/plugins@typescript-best-practices, partme-ai@electron (removed upstream); stripe-payments deferred to Phase 7 per PRD.

In progress / blocked:
- `npm install` running (node 25.6.1 vs `.nvmrc` 24.18.0 — if it fails, need Node 24 via nvm/fnm/brew: system change, needs owner action).
- Not yet: git commits (awaiting owner OK), `origin` remote (needs GitHub repo decision), macOS signing cert (needs Apple Developer account), updater wiring, build verification (`npm run compile` + `./scripts/code.sh`).
