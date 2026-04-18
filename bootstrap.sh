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

log_step "Detected OS: $(detect_os)"

# Install dependencies
log_step "Installing base dependencies"
install_deps
log_success "Base dependencies installed"

# Install packages
log_step "Installing packages"
install_packages
log_success "Packages installed"

# Install GUI applications (Linux only)
if is_linux; then
    log_step "Installing Linux GUI applications"
    source "$SCRIPTS_DIR/apps.sh"
    install_linux_apps
    log_success "GUI applications installed"
fi

# Install shell
log_step "Setting up shell (zsh + oh-my-zsh)"
run_script "$SCRIPTS_DIR/shell.sh"
run_script "$SCRIPTS_DIR/zsh-plugins.sh"
log_success "Shell configured"

# Terminal and development tools
log_step "Installing development tools"
run_script "$SCRIPTS_DIR/python.sh"
run_script "$SCRIPTS_DIR/npm.sh"
log_success "Development tools installed"

# Symbolic linking
log_step "Linking dotfiles with stow"
mkdir -p "$HOME/.config"

# Remove blocking directories only for packages we're stowing
for pkg in git ghostty; do
    if [ -d "$HOME/.config/$pkg" ] && [ ! -L "$HOME/.config/$pkg" ]; then
        rm -rf "$HOME/.config/$pkg"
    fi
done

stow -d ~/.dotfiles -t ~ --adopt zshrc gitconfig
stow -d ~/.dotfiles -t ~/.config --adopt config

# Platform-specific git config (signingkey + gpg ssh program)
mkdir -p "$DOTFILES_DIR/config/git/platform"
if is_macos; then
    ln -sf ../macos/gitconfig "$DOTFILES_DIR/config/git/platform/gitconfig"
else
    ln -sf ../linux/gitconfig "$DOTFILES_DIR/config/git/platform/gitconfig"
fi

# macOS-only configs (AeroSpace tiling WM + JankyBorders focus indicator)
if is_macos; then
    for pkg in aerospace borders; do
        if [ -d "$HOME/.config/$pkg" ] && [ ! -L "$HOME/.config/$pkg" ]; then
            rm -rf "$HOME/.config/$pkg"
        fi
    done
    stow -d ~/.dotfiles/macos -t ~/.config --adopt config
fi

log_success "Dotfiles linked"

# Set default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    log_step "Setting zsh as default shell"
    sudo chsh -s "$(which zsh)" $USER
    log_success "Default shell set to zsh"
fi

echo ""
log_success "Bootstrap complete!"
log_warning "It is recommended to reboot your machine after running this script."
