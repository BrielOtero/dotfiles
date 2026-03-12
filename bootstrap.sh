#!/bin/bash
set -eu

# Ask for root password upfront
sudo -v
while true; do
  sudo -n true
  sleep 30
  kill -0 "$$" || exit
done 2>/dev/null &

# Directories
DOTFILES_DIR="$HOME/.dotfiles"
FUNCTIONS_DIR="$DOTFILES_DIR/shell/functions"
SCRIPTS_DIR="$DOTFILES_DIR/shell/scripts"

# Clone dotfiles
if [ ! -d "$HOME/.dotfiles" ]; then
    git clone https://github.com/BrielOtero/dotfiles.git $HOME/.dotfiles 
fi

# Source helper functions
source "$FUNCTIONS_DIR/os.sh"
source "$FUNCTIONS_DIR/logging.sh"
source "$FUNCTIONS_DIR/misc.sh"
chmod +x "$SCRIPTS_DIR"/*.sh

# Install dependencies
install_deps

# Install packages
install_packages

# Install GUI applications (Linux only)
if is_linux; then
    source "$SCRIPTS_DIR/apps.sh"
    install_linux_apps
fi

# Install shell
run_script "$SCRIPTS_DIR/shell.sh"

# Terminal and development tools
run_script "$SCRIPTS_DIR/python.sh"
run_script "$SCRIPTS_DIR/npm.sh"

# Symbolic linking
mkdir -p "$HOME/.config"

# Remove blocking directories only for packages we're stowing
for pkg in git ghostty; do
    if [ -d "$HOME/.config/$pkg" ] && [ ! -L "$HOME/.config/$pkg" ]; then
        rm -rf "$HOME/.config/$pkg"
    fi
done

stow -d ~/.dotfiles -t ~ --adopt zshrc
stow -d ~/.dotfiles -t ~/.config --adopt config

# Set default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s "$(which zsh)" $USER
fi

log_warning "It is recommended to reboot your machine after running this script."
