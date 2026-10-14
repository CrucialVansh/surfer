# Surfer — Product Requirements Document

**Version:** 1.0 · **Date:** 2026-10-14 · **Status:** Approved for build
**Companion:** `surfer.md` (build plan & milestones)

---

## 1. Vision

A local-first AI IDE that matches the Cursor experience while charging users nothing for model access beyond what model providers themselves charge. Bring Your Own Keys (BYOK), zero markup, zero accounts, zero telemetry. An optional paid tier (Surfer Pro) adds a managed model subscription for users who don't want to manage keys.

## 2. Problem

1. **Markup:** Cursor/Windsurf charge $20+/mo subscriptions plus usage limits on top of model API costs. The real margin is model-access markup and the subscription gate.
2. **Lock-in:** Model choice is curated by the vendor; users can't pick arbitrary providers or local models as first-class citizens.
3. **Cloud dependency:** Accounts, sync, and routing through vendor backends are mandatory — a privacy and reliability cost many developers don't want.
4. **Opacity:** Users can't see what each request actually costs.

## 3. Target Users

| Persona | Need | Surfer answer |
|---|---|---|
| **Cost-sensitive power user** | Cursor features without $20/mo + caps | Free app, BYOK at API cost, visible per-request cost meter |
| **Privacy-sensitive dev** | No code through third-party backends | Direct provider calls; fully-local mode via Ollama; no telemetry |
| **Tinkerer / multi-model user** | Use any model incl. local, OpenRouter's catalog, new releases day-one | Open provider abstraction + OpenRouter + Ollama |
| **Convenience user (v1.1)** | One bill, no key management | Surfer Pro: managed gateway, transparent pricing |

## 4. Competitive Positioning

| | Cursor | Windsurf | Zed | Continue | **Surfer** |
|---|---|---|---|---|---|
| Base | VS Code fork | VS Code fork | Custom | Extension | VS Code fork |
| Free BYOK tier | No | No | BYOK yes | Yes | **Yes, full-featured** |
| Cost transparency | Hidden | Hidden | Partial | Partial | **Per-request meter** |
| Local models | No | No | Yes | Yes | **Yes (Ollama first-class)** |
| No account required | No | No | Yes | Yes | **Yes** |
| Full VS Code ext. compat | Yes | Yes | No | N/A | **Yes (Open VSX)** |

Differentiators: true pass-through pricing, visible costs, local-first privacy, full VS Code extension compatibility. Cursor parity features (agent tab, Cmd+K, Tab) are table stakes, not differentiators.

## 5. Goals / Non-Goals

### Goals (v1)
- G1: VS Code fork on macOS (arm64+x64), signed, notarized, auto-updating.
- G2: Model layer supporting Anthropic, OpenAI, Google, xAI, DeepSeek, OpenRouter, Ollama/LM Studio.
- G3: Chat sidebar, agent tab with tools + checkpoints, Cmd+K inline edit, Tab autocomplete.
- G4: Local codebase context engine (semantic search, @-mentions).
- G5: Per-request token/cost transparency UI.
- G6: Zero network calls except user-configured providers + update checks + extension fetches.

### Non-Goals (v1)
- NG1: Accounts, login, billing (v1.1 only, and only for Pro).
- NG2: Settings sync, teams, collaboration, shared workspaces.
- NG3: Cloud/background agents, web/mobile versions.
- NG4: Windows/Linux builds.
- NG5: Microsoft extension marketplace (Open VSX instead).
- NG6: Training/custom models, fine-tuning, prompt marketplaces.

## 6. Functional Requirements

### FR-1 — Model Layer (P0, the foundation everything uses)
- FR-1.1 Provider abstraction: unified streaming chat + tool-calling interface over Anthropic, OpenAI, Google, xAI, DeepSeek, OpenRouter, Ollama (OpenAI-compatible local servers).
- FR-1.2 Hand-rolled thin clients; no heavy vendor SDKs. OpenAI-compatible path reused for xAI/DeepSeek/OpenRouter/Ollama.
- FR-1.3 API keys in OS keychain (macOS Keychain at v1); never plaintext, never in settings.json.
- FR-1.4 Per-feature model assignment: agent model, chat model, inline-edit model, fast-apply model, tab model, embedding model — independently configurable.
- FR-1.5 Cost meter: tokens in/out + estimated $ (from a bundled price table, user-overridable) shown per message and aggregated per session/day.
- FR-1.6 Retry/rate-limit handling, timeouts, cancellation on every request path.
- FR-1.7 Model capability registry (context window, tool-calling support, FIM support) so the UI can warn on bad assignments.

### FR-2 — Chat Sidebar (P0)
- FR-2.1 Streaming markdown chat with code blocks; insert-at-cursor and apply-to-file actions per block.
- FR-2.2 Context attachment: current file/selection auto-included; manual @-mentions (from FR-6).
- FR-2.3 Conversation history persisted locally (sqlite), searchable, deletable. Never leaves machine except as provider request content.
- FR-2.4 Per-conversation model switcher + cost meter footer.

### FR-3 — Agent Tab (P0)
- FR-3.1 Dedicated agent panel (tab or sidebar mode) running a tool-calling loop.
- FR-3.2 Tools: read file, write file, edit file (diff-based, never full-file rewrite), list dir, grep, glob, run terminal command, web fetch.
- FR-3.3 Approval gates: terminal commands require approval (allowlist/denylist + "always allow this pattern"); file edits inside workspace auto-allowed with review UI; outside-workspace writes blocked by default.
- FR-3.4 Diff review: per-file accept/reject, keep-all/undo-all, inline hunk controls.
- FR-3.5 Checkpoints: shadow git repo snapshots before every agent turn; one-click restore.
- FR-3.6 Visible step log (tool calls + results), running cost, max-turns budget, interrupt button that cancels cleanly mid-tool.
- FR-3.7 Graceful degradation: if assigned model lacks tool-calling, agent explains and suggests alternatives.

### FR-4 — Inline Edit + Fast Apply (P0)
- FR-4.1 Cmd+K floating input at cursor/selection; streamed edit with inline diff (green/red), per-hunk accept/reject.
- FR-4.2 Fast-apply pipeline: primary model emits edit hints; small cheap model merges into file; speculative application during streaming for perceived-instant edits.
- FR-4.3 Works in any file type; falls back to chat for non-editable contexts.

### FR-5 — Tab Autocomplete (P0)
- FR-5.1 Ghost-text completion at cursor, Tab to accept, Esc/word-by-word partial accept.
- FR-5.2 Local-first default: FIM model via Ollama (e.g., Qwen/DeepSeek coder variants) = $0 marginal cost, fully private.
- FR-5.3 Optional API-backed completion models for users who prefer them.
- FR-5.4 Next-edit prediction: track recent edit history, predict likely next edit location, pre-fill.
- FR-5.5 Debounced (<300ms trigger), aggressively cached, cancelled on keystroke; p95 suggestion latency < 500ms local, < 800ms API.
- FR-5.6 Ships behind a setting; default OFF until internal quality bar (acceptance rate ≥ 20% on dogfood) is met.

### FR-6 — Local Context Engine (P0)
- FR-6.1 Workspace index: Merkle-tree change detection; reindex only changed files; index stored in `sqlite-vec` (single file in workspace storage, no daemon).
- FR-6.2 Chunking: AST-aware where cheap, line-window fallback; embeddings via local model (default, free/private) or user-selected API embedding model.
- FR-6.3 @-mentions: `@file`, `@folder`, `@codebase` (semantic search), `@docs` (user-added doc URLs, fetched and cached locally).
- FR-6.4 Agent gets semantic-search as a tool; chat auto-ranks context within the model's window.
- FR-6.5 Index excludes gitignored files + configurable denylist (secrets, binaries, large files).

### FR-7 — Fork / Platform (P0)
- FR-7.1 Fork of `microsoft/vscode`; all Surfer code in top-level `surfer/` dir; core touched only via minimal documented patches.
- FR-7.2 Rebrand: name, icons, product strings, first-run experience. No MS trademarks.
- FR-7.3 Open VSX as default extension marketplace.
- FR-7.4 macOS signed + notarized builds (arm64, x64); auto-update via electron-updater + GitHub Releases.
- FR-7.5 Monthly upstream merge cadence with a documented merge checklist.
- FR-7.6 One-click "import settings/keybindings/extensions list from VS Code" onboarding.

### FR-8 — Surfer Pro (P1, v1.1)
- FR-8.1 Minimal stateless gateway: auth (email/OAuth), provider-key injection, per-user usage metering, plan rate limits. Only cloud component in the product.
- FR-8.2 Stripe billing: monthly subscription; transparent pricing page showing underlying provider costs.
- FR-8.3 IDE side: login button + "Surfer Pro" entry in the model picker exposing the managed catalog ("lots of models" — leverage OpenRouter-style breadth).
- FR-8.4 BYOK and Pro coexist; Pro is never required for any local feature. No-login functionality must not regress.

## 7. UX Requirements

- UX-1: AI features discoverable but not intrusive; no upsell banners in v1 (none exist to sell).
- UX-2: Every AI action shows cost impact; every destructive agent action is reversible (checkpoints).
- UX-3: Latency: chat first-token < 2s (network-dependent), inline edit perceived-instant via fast-apply, tab per FR-5.5.
- UX-4: Keyboard-first: all AI features have shortcuts; agent actions operable without mouse.
- UX-5: Offline behavior: with Ollama configured, chat/agent/inline/tab all work with zero internet.

## 8. Non-Functional Requirements

- **Privacy:** No analytics, crash reporting, or telemetry by default. Network calls limited to: configured providers, update check, extension marketplace, user-invoked web fetches. Documented in a PRIVACY.md shipped in-app.
- **Security:** Keys in keychain; terminal approval gates; workspace-write sandboxing; shadow-repo checkpoints; no eval of model output outside sanctioned tool paths.
- **Performance:** Startup within 10% of stock VS Code; idle RAM overhead < 300MB for AI subsystems; indexer throttled (no indexing during typing bursts; battery-aware pause).
- **Reliability:** Provider failures never crash the workbench; every request cancellable; chat history survives crashes.
- **Maintainability:** `surfer/` isolation rule (see FR-7.1); every patch to core has a comment + entry in `surfer/PATCHES.md`.

## 9. Monetization

- **v1:** Free. Pure BYOK. Growth + trust phase.
- **v1.1:** Surfer Pro subscription (target: below Cursor's $20/mo all-in for equivalent usage). Gateway costs covered by transparent markup on metered usage. Initial catalog via OpenRouter resale if direct provider deals aren't in place.
- **Never:** paywalling local features, selling data, dark patterns.

## 10. Success Metrics

| Metric | v1 target | How measured |
|---|---|---|
| Weekly active users | 1,000 within 90 days of launch | Opt-in-only anonymous counter (or download counts if none) |
| Agent accept rate (diff hunks kept) | ≥ 60% | Local-only, user-visible stat |
| Tab completion acceptance | ≥ 20% | Local-only, user-visible stat |
| Dogfood cost transparency | 100% of requests priced | Cost meter coverage |
| Upstream merge lag | < 30 days per release | Merge checklist |
| Pro conversion (v1.1) | 3–5% of WAU | Stripe |

## 11. Release Plan

v1 per `surfer.md` milestones 0–6 (~24 weeks, macOS only). v1.1 adds FR-8 (+4–5 weeks). Public launch at v1; Pro waitlist opens at v1 launch.

## 12. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Upstream drift / merge hell | `surfer/` isolation, monthly cadence, PATCHES.md |
| Autocomplete cost/latency | Local-model default; acceptance gate before default-on |
| Solo-maintainer treadmill | Scope limits (§5); defer Pro until v1 proves out |
| Marketplace gaps (Pylance etc.) | Open VSX + documented workaround; accepted loss |
| Provider API churn | Thin adapters, capability registry, contract tests per provider |
| Gateway scope creep | Stateless proxy only; no IDE coupling beyond a provider entry |

## 13. Open Questions

1. Pro pricing: flat sub + fair-use cap vs. pure metered passthrough + margin? (Decide during v1.1 design.)
2. Ollama bundling: prompt-and-install on first run vs. ship an embedded runner? (Decide in Phase 4.)
3. Default tab model when no Ollama present: cheapest API FIM model, or autocomplete simply off?
4. Update channel strategy: stable-only vs. stable+insiders (mirrors VS Code's cadence but doubles CI cost).

---

## 14. Agent Build Tooling — Recommended Skills

Skills verified against the live skills.sh registry (install counts as of 2026-10-14). Install user-level: `npx skills add <pkg> -g -y`.

### Already installed — mapped to this build

| Skill | Use for |
|---|---|
| **caveman-explore** | Navigating the enormous `microsoft/vscode` codebase without polluting main context; returns path:line citations only. Highest-leverage skill for a fork. |
| **caveman** / caveman modes | Compressing long build sessions to stretch the OpenCode Go quota. |
| **caveman-commit** | Commit messages on every milestone merge. |
| **caveman-review** | One-line-per-finding diff review before merging build-session output. |
| **caveman-compress** | Keeping `AGENTS.md` cheap to load as it grows across phases. |
| **lean-build** | Every milestone: strict scope, reuse-first, explicit stop conditions — the anti-overbuilding harness this project needs. |
| **surgical-patch** | The fork rule made executable: narrowest-layer edits to VS Code core, regression-proofed. |
| **safe-refactor** | Restructuring `surfer/` modules (model layer, agent loop) without behavior change. |
| **migration** | Provider API/schema changes in the model layer; rollback-safe. |
| **investigate-first** | Diagnosing weird fork bugs (Electron, workbench, extension host) before touching code. |
| **verify-and-stop** | Milestone acceptance: prove the phase's acceptance criteria, add nothing. |

### Install now (verified, high-signal)

| Skill | Installs | Why for Surfer | Install |
|---|---|---|---|
| **ponytail** (`DietrichGebert/ponytail`) | ~162K | "Laziest senior dev": forces minimal diffs, YAGNI, no speculative abstraction. Pairs with lean-build to stop agent over-engineering on a 1.5M-line codebase. Independently tested (JetBrains) to cut generated code ~50%. | `npx skills add DietrichGebert/ponytail -g -y` |
| **improve-codebase-architecture** (`mattpocock/skills`) | 1.1M | Architecture discipline for a giant TS monorepo fork. | `npx skills add mattpocock/skills@improve-codebase-architecture -g -y` |
| **playwright-best-practices** (`currents-dev/playwright-best-practices-skill`) | 93.2K | E2E testing of the Electron app (Playwright drives Electron). | `npx skills add currents-dev/playwright-best-practices-skill@playwright-best-practices -g -y` |
| **security-best-practices** (`openai/skills`) | 10.4K | Keychain handling, terminal-gate design, gateway (v1.1) threat model. | `npx skills add openai/skills@security-best-practices -g -y` |
| **vscode-ext-commands** (`github/awesome-copilot`, official) | 9K | Command-palette/contribution conventions when surfacing Surfer features through VS Code's command system. | `npx skills add github/awesome-copilot@vscode-ext-commands -g -y` |
| **typescript-best-practices** (`cursor/plugins`) | 6.4K | TS discipline for `surfer/` modules (fittingly, from Cursor's own plugin repo). | `npx skills add cursor/plugins@typescript-best-practices -g -y` |
| **rag-architect** (`jeffallan/claude-skills`) | 4.5K | Phase 5 context engine: chunking, embedding, retrieval design. | `npx skills add jeffallan/claude-skills@rag-architect -g -y` |
| **electron** (`partme-ai/full-stack-skills`) | 2.4K | Electron build/signing/updater patterns. (Category is thin — verify quality on first use; fallback: `mindrally/skills@electron-development`, 1.3K.) | `npx skills add partme-ai/full-stack-skills@electron -g -y` |
| **stripe-payments** (`jezweb/claude-skills`) | 1.1K | v1.1 billing integration. Install when Phase 7 starts, not before. | `npx skills add jezweb/claude-skills@stripe-payments -g -y` |

### Optional

- `phuryn/pm-skills@create-prd` (10.5K) or `github/awesome-copilot@prd` (23.8K) — generate per-feature PRDs (agent tab, autocomplete) as the build reaches them.
- `github/awesome-copilot@breakdown-feature-prd` (10K) — split this PRD into per-milestone work items.

## 15. Build-Execution Model Assignment (summary)

Driver: `deepseek-v4-pro` (high). Sprints: `kimi-k2.7-code`. Architecture/merges: `kimi-k3` (max), sparingly. Chores: `cat-jam-free`. Details in `surfer.md`.
