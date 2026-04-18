#!/bin/bash
set -eu

# Install external oh-my-zsh plugins into $ZSH/custom/plugins.
# Safe to re-run: clones only if missing, pulls updates otherwise.

ZSH="${ZSH:-$HOME/.oh-my-zsh}"
CUSTOM_PLUGINS="$ZSH/custom/plugins"

install_plugin() {
    local name="$1"
    local repo="$2"
    local dest="$CUSTOM_PLUGINS/$name"

    if [ ! -d "$dest" ]; then
        git clone --depth=1 "$repo" "$dest"
    else
        git -C "$dest" pull --ff-only --quiet || true
    fi
}

mkdir -p "$CUSTOM_PLUGINS"
install_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
