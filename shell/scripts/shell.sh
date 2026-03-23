#!/bin/bash

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
source "$DOTFILES_DIR/shell/functions/os.sh"

install_shell() {
    local os=$(detect_os)
    
    # Install Zsh
    case "$os" in
        arch)
            sudo pacman -S --noconfirm zsh
            ;;
        fedora)
            sudo dnf install -y zsh
            ;;
        debian)
            sudo apt-get install -y zsh
            ;;
        macos)
            brew install zsh
            ;;
    esac
    
    # Install Oh My Zsh
    OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
    if [ ! -d "$OH_MY_ZSH_DIR" ]; then
        ZSH= sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    
    # Install Starship
    case "$os" in
        arch)
            sudo pacman -S --noconfirm starship
            ;;
        fedora)
            sudo dnf copr enable -y atim/starship
            sudo dnf install -y starship
            ;;
        debian)
            curl -sS https://starship.rs/install.sh | sh
            ;;
        macos)
            brew install starship
            ;;
    esac
}

install_shell
