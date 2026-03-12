#!/bin/bash

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

OH_MY_ZSH_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"

if [ ! -d "$OH_MY_ZSH_DIR" ]; then
    sh -c "$(curl -fsSL "$OH_MY_ZSH_INSTALL_SCRIPT_URL")" "" --unattended
else
    echo "Oh My Zsh is already installed. Skipping installation."
fi

mkdir -p "$HOME/.config"
cp "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"
