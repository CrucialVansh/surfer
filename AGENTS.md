# VS Code Agents Instructions

This file provides instructions for AI coding agents working with the VS Code codebase.

For detailed project overview, architecture, coding guidelines, and validation steps, see the [Copilot Instructions](.github/copilot-instructions.md).

---

# Surfer Fork Directives

<!-- [surfer:P-002] appended section, keep below upstream content on merges -->

This repository is **Surfer**, a local-first AI IDE forked from `microsoft/vscode`.
Read these before doing any work here:

- **Plans:** build plan at `.opencode/surfer.md`, PRD at `.opencode/surfer-prd.md`.
- **The fork rule:** all Surfer code goes in the top-level `surfer/` directory.
  Changes to upstream files are minimal patches, marked `// [surfer:P-###]` and
  registered in `surfer/PATCHES.md`. Details: `surfer/README.md`.
- **Upstream merges:** monthly from the `upstream` remote
  (`https://github.com/microsoft/vscode.git`). On conflict, Surfer identity
  (branding, gallery, `surfer/`) always wins.
- **Product constraints:** no accounts, no telemetry, no MS marketplace
  (Open VSX only), no cloud features. Model providers are user-configured (BYOK).
- **Node version:** `.nvmrc` (currently 24.18.0). The build hard-fails on the
  wrong Node major (preinstall check). System Node is 25.x, so run
  `source surfer/scripts/env.sh` before `npm install` / builds — it PATH-scopes
  homebrew's keg-only `node@24`.
- **Build/run:** `npm install` then `npm run watch` (or `npm run compile`),
  launch with `./scripts/code.sh`. Use the repo-level `launch` skill to drive
  the workbench with Playwright + debugger.
- **Repo-level skills** live in `.agents/skills/` (ponytail for minimal diffs,
  improve-codebase-architecture, playwright-best-practices, rag-architect,
  security-best-practices, vscode-ext-commands, electron-development, launch).
  They are committed — use them.
- **Working style:** smallest change that fully solves the task (ponytail).
  One milestone per session; acceptance criteria live in the plan/PRD.
