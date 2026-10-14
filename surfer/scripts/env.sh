#!/usr/bin/env bash
# Surfer build environment. Source before building:
#   source surfer/scripts/env.sh
#
# VS Code requires the Node major pinned in .nvmrc (currently 24.x).
# System Node is 25.x, so we PATH-scope homebrew's keg-only node@24
# for build commands only — the system default stays untouched.

set -e

REQUIRED_MAJOR="$(tr -d '[:space:]' < "$(dirname "${BASH_SOURCE[0]}")/../../.nvmrc" | cut -d. -f1)"

NODE24_BIN="$(brew --prefix "node@${REQUIRED_MAJOR}" 2>/dev/null)/bin"

if [ ! -x "${NODE24_BIN}/node" ]; then
	echo "surfer env: node@${REQUIRED_MAJOR} not found. Install with: brew install node@${REQUIRED_MAJOR}" >&2
	return 1 2>/dev/null || exit 1
fi

case ":${PATH}:" in
	*":${NODE24_BIN}:"*) ;;                    # already scoped
	*) export PATH="${NODE24_BIN}:${PATH}" ;;
esac

echo "surfer env: node $(node --version) (required major ${REQUIRED_MAJOR})"
