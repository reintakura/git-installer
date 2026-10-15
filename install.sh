#!/usr/bin/env bash
# macOS Homebrew + Git installer
# Designed to be executed via: curl -fsSL https://raw.githubusercontent.com/reintakura/git-installer/main/install.sh | bash
# Authorized/public distribution context assumed.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log()   { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[x]${NC} $*" >&2; exit 1; }

# Ensure we're on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
  error "This script is for macOS only."
fi

# Detect architecture
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

# Function to ensure brew is in PATH for the current session
ensure_brew_path() {
  if [[ -x "${BREW_PREFIX}/bin/brew" ]]; then
    eval "$(${BREW_PREFIX}/bin/brew shellenv)"
  fi
}

# --- Step 1: Install Homebrew if missing ---
log "Checking for Homebrew..."
if command -v brew >/dev/null 2>&1; then
  log "Homebrew already installed: $(brew --version | head -n1)"
else
  log "Homebrew not found. Installing..."
  # Official non-interactive-friendly installer
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error "Homebrew installation failed."

  # Make brew available in this session
  ensure_brew_path

  if ! command -v brew >/dev/null 2>&1; then
    error "Homebrew installed but not found in PATH. Please open a new terminal and re-run, or source your shell profile."
  fi
  log "Homebrew installed successfully."
fi

# Ensure PATH is set for the rest of the script
ensure_brew_path

# --- Step 2: Install Git via Homebrew ---
log "Checking for Git..."
if command -v git >/dev/null 2>&1 && git --version >/dev/null 2>&1; then
  CURRENT_GIT="$(git --version)"
  # Prefer brew's git if available
  if brew list git >/dev/null 2>&1; then
    log "Git already installed via Homebrew: $CURRENT_GIT"
  else
    log "Git found (system/Xcode): $CURRENT_GIT — installing Homebrew version for consistency..."
    brew install git || error "Failed to install git via Homebrew."
    log "Homebrew Git installed: $(git --version)"
  fi
else
  log "Git not found. Installing via Homebrew..."
  brew install git || error "Failed to install git via Homebrew."
  log "Git installed: $(git --version)"
fi

# Final verification
log "Verification:"
echo "  Homebrew: $(brew --version | head -n1)"
echo "  Git:      $(git --version)"
echo "  Prefix:   ${BREW_PREFIX}"

log "Done. Homebrew and Git are ready."
log "Note: You may need to restart your terminal or run 'source ~/.zshrc' (or ~/.bash_profile) for PATH changes to persist in new sessions."
