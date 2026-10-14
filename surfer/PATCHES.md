# PATCHES.md — Registry of Surfer patches to upstream code

Every change outside `surfer/` must be registered here so upstream merges
stay reviewable. Format: ID, file, what, why, upstream-merge risk.

| ID | File(s) | Change | Merge risk |
|----|---------|--------|------------|
| P-001 | `product.json` | Rebrand (Surfer identity strings) + Open VSX `extensionsGallery` + `linkProtectionTrustedDomains` | Low — conflicts resolved by keeping ours |
| P-002 | `AGENTS.md` | Appended "Surfer Fork Directives" section below upstream content | Low — append-only, keep both sides on conflict |

## TODO (not yet patched)

- `product.json`: new GUIDs for `win32*AppId`, `darwinProfileUUID`,
  `darwinProfilePayloadUUID` (needed before first signed release, not before)
- `product.json`: `reportIssueUrl` → Surfer repo issue tracker once it exists
- App icons: `resources/darwin/`, `resources/win32/`, `resources/linux/`
  still ship Code - OSS artwork; replace with Surfer branding before release
- `defaultChatAgent` block in `product.json` references GitHub Copilot;
  superseded when Surfer chat/agent (Phase 1-2) lands — do not remove before
