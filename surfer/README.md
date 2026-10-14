# surfer/ — Surfer Fork Code

All Surfer product code lives in this top-level directory. This is the fork's
survival rule: upstream merges from `microsoft/vscode` must almost never touch
files in here, which keeps merge conflicts rare and mechanical.

## Rules

1. **New code goes in `surfer/`**, mirroring upstream layout where sensible
   (e.g. `surfer/workbench/ai/...`). Never add Surfer logic to `src/`,
   `extensions/`, or `build/` directly.
2. **Core changes are patches, not edits.** When upstream code must change,
   make the smallest possible diff, mark it with a comment
   (`// [surfer:P-###]`), and register it in `surfer/PATCHES.md`.
3. **No Microsoft dependencies.** Surfer code must not rely on the MS
   marketplace, MS telemetry endpoints, or Copilot services. Extension
   gallery is Open VSX (see `product.json`).
4. **Local-first.** No accounts, no telemetry, no cloud calls except
   user-configured model providers, Open VSX, and update checks.

## Layout (grows per milestone, see `.opencode/surfer.md`)

```
surfer/
  README.md          this file
  PATCHES.md         registry of every patch to upstream code
  workbench/         Phase 1+: model layer, chat, agent, inline edit
  ...                (created as milestones land)
```

## Plans

- Build plan: `.opencode/surfer.md`
- PRD: `.opencode/surfer-prd.md`
