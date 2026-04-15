#!/bin/bash

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
source "$DOTFILES_DIR/shell/functions/os.sh"

install_shell() {
    local os=$(detect_os)

    # Install Zsh
    case "$os" in
        arch)   paru -S --noconfirm --needed zsh ;;
        fedora) sudo dnf install -y zsh ;;
        debian) sudo apt-get install -y zsh ;;
        macos)  brew install zsh ;;
    esac

    # Install Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        ZSH= sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

install_shell
