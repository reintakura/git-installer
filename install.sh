#!/usr/bin/env bash
# macOS Git installer — NO sudo / admin needed.
# Installs Git from conda-forge via micromamba into your home folder.
# Usage: curl -fsSL https://raw.githubusercontent.com/reintakura/git-installer/main/install.sh | bash

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()   { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[x]${NC} $*" >&2; exit 1; }

OS="$(uname -s)"
if [[ "$OS" != "Darwin" && "${GIT_INSTALLER_ALLOW_LINUX:-}" != "1" ]]; then
  error "This script is for macOS only."
fi

case "$OS-$(uname -m)" in
  Darwin-arm64)  PLATFORM="osx-arm64" ;;
  Darwin-x86_64) PLATFORM="osx-64" ;;
  Linux-x86_64)  PLATFORM="linux-64" ;;
  *) error "Unsupported platform: $OS $(uname -m)" ;;
esac

PREFIX="${GIT_INSTALL_PREFIX:-$HOME/.local/portable-git}"
MAMBA="$PREFIX/micromamba/bin/micromamba"
ENV_DIR="$PREFIX/env"
BIN_DIR="$HOME/.local/bin"

log "Install location: $PREFIX (no sudo needed)"
mkdir -p "$PREFIX/micromamba" "$BIN_DIR"

# --- Step 1: micromamba (single static binary, user scope) ---
if [[ ! -x "$MAMBA" ]]; then
  log "Downloading micromamba ($PLATFORM)..."
  curl -fsSL "https://micro.mamba.pm/api/micromamba/$PLATFORM/latest" \
    | tar -xj -C "$PREFIX/micromamba" bin/micromamba \
    || error "Failed to download micromamba."
fi

# --- Step 2: Git from conda-forge ---
if [[ -x "$ENV_DIR/bin/git" ]]; then
  log "Git already installed, updating..."
  "$MAMBA" update -y -q -r "$PREFIX/root" -p "$ENV_DIR" -c conda-forge git >/dev/null \
    || warn "Update failed, keeping existing Git."
else
  log "Installing Git (this can take a minute)..."
  "$MAMBA" create -y -q -r "$PREFIX/root" -p "$ENV_DIR" -c conda-forge git >/dev/null \
    || error "Git installation failed."
fi

# --- Step 3: expose git on PATH ---
ln -sf "$ENV_DIR/bin/git" "$BIN_DIR/git"

PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
for rc in "$HOME/.zshrc" "$HOME/.bash_profile"; do
  touch "$rc"
  grep -qxF "$PATH_LINE" "$rc" || { echo "$PATH_LINE" >> "$rc"; log "Added ~/.local/bin to PATH in $rc"; }
done
export PATH="$BIN_DIR:$PATH"

# --- Verify ---
GIT_VER="$("$BIN_DIR/git" --version)" || error "Git installed but failed to run."
log "Success: $GIT_VER"
log "Location: $ENV_DIR/bin/git"
log "Open a new terminal (or run: source ~/.zshrc) to use git everywhere."
log "Uninstall: rm -rf \"$PREFIX\" \"$BIN_DIR/git\""
