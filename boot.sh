#!/usr/bin/env bash
set -euo pipefail

# Ensure local binaries are in PATH for the duration of this script
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

echo "[stage0] Initializing sound foundation..."

# 1. Install Foundation
sudo apt update
sudo apt install -y extrepo git stow just luajit

# 2. System Configuration
echo "[stage0] Configuring architecture and repository policies..."
# required for wine32:i386
sudo dpkg --add-architecture i386

# Enable extrepo policies (main, contrib, non-free)
if [ -f /etc/extrepo/config.yaml ]; then
	sudo sed -i 's/^#\s*- contrib/- contrib/'   /etc/extrepo/config.yaml
	sudo sed -i 's/^#\s*- non-free/- non-free/' /etc/extrepo/config.yaml
fi

# 3. Third-Party Repositories
echo "[stage0] Enabling third-party repositories..."
sudo extrepo enable nushell
# The Nushell extrepo source needs a specific fix for the Suites line
if [ -f /etc/apt/sources.list.d/extrepo_nushell.sources ]; then
	sudo sed -i '/Uris:/a Suites: /' /etc/apt/sources.list.d/extrepo_nushell.sources
fi

sudo extrepo enable brave_release

# 4. Final Apt Prep & Shell dependencies
echo "[stage0] System update & shell setup..."
sudo apt update
sudo apt install -y nushell starship
sudo apt upgrade -y

# 5. Dotfiles Acquisition
DOTFILES_DIR="$HOME/Dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
	echo "[stage0] Cloning dotfiles..."
	git clone https://github.com/yilisharcs/Dotfiles "$DOTFILES_DIR"
fi

# 6. Backup original sources.list
if [ -f /etc/apt/sources.list ] && [ ! -f /etc/apt/sources.list.bak ]; then
	echo "[stage0] Backing up sources.list..."
	sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
fi

# 7. Initial Scaffolding (Stow & Sudo Adopt)
echo "[stage0] Applying initial dotfiles setup (adopt)..."
(cd "$DOTFILES_DIR" && just --unstable stow adopt)
(cd "$DOTFILES_DIR" && just --unstable sudo adopt)

# 8. Review Pause
echo ""
echo "[stage0] Files have been adopted into ~/Dotfiles."
echo "[stage0] Please review any changes (e.g. using git diff)."
read -p "[stage0] Press Enter to restore git state and continue hand-off..."

# 9. Restoration
echo "[stage0] Restoring dotfiles repository state..."
(cd "$DOTFILES_DIR" && git restore .)

# 10. Hand-off to Lua Engine
echo "[stage0] Executing boot.lua..."
luajit "$HOME/Dotfiles/boot.lua"

# 11. Finalization (The Pivot)
# Refresh shell hash to pick up the new cargo-just binary.
hash -r
if command -v just >/dev/null 2>&1; then
	echo "[stage0] Finalizing with $(just --version)..."
	(cd "$DOTFILES_DIR" && just --unstable stow adopt)
	(cd "$DOTFILES_DIR" && just --unstable sudo adopt)
else
	echo "[error] just binary not found in PATH after hand-off."
	exit 1
fi

echo "[stage0] Success. System is enforced."
