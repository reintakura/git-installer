#!/usr/bin/env bash
# Removes everything install.sh added on macOS. No sudo needed.
# Usage: curl -fsSL https://raw.githubusercontent.com/reintakura/git-installer/main/uninstall.sh | bash

set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log()  { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }

PREFIX="${GIT_INSTALL_PREFIX:-$HOME/.local/portable-git}"
BIN_DIR="$HOME/.local/bin"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

# Git symlink (only if it points to our install)
if [[ -L "$BIN_DIR/git" && "$(readlink "$BIN_DIR/git")" == "$PREFIX"* ]]; then
  rm -f "$BIN_DIR/git"; log "Removed $BIN_DIR/git"
fi

# Install folder (micromamba, Git env, package cache)
if [[ -d "$PREFIX" ]]; then
  rm -rf "$PREFIX"; log "Removed $PREFIX"
else
  warn "Nothing found at $PREFIX"
fi

# PATH line in shell profiles (kept if ~/.local/bin still holds other tools)
if [[ -d "$BIN_DIR" && -n "$(ls -A "$BIN_DIR" 2>/dev/null)" ]]; then
  warn "$BIN_DIR still has other files, leaving the PATH line in your shell profile."
else
  rmdir "$BIN_DIR" 2>/dev/null || true
  for rc in "$HOME/.zshrc" "$HOME/.bash_profile"; do
    if [[ -f "$rc" ]] && grep -qxF "$PATH_LINE" "$rc"; then
      grep -vxF "$PATH_LINE" "$rc" > "$rc.tmp" || true
      mv "$rc.tmp" "$rc"; log "Removed PATH line from $rc"
    fi
  done
fi

log "Cleanup done. Open a new terminal to refresh PATH."
