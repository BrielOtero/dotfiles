#!/bin/bash
set -eu

detect_os() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        echo "macos"
    elif [[ "$(uname -s)" == "Linux" ]]; then
        if [[ -f /etc/fedora-release ]] || command -v dnf &> /dev/null; then
            echo "fedora"
        else
            echo "debian"
        fi
    else
        echo "unknown"
    fi
}

is_linux() {
    [[ "$(uname -s)" == "Linux" ]]
}

is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

is_fedora() {
    is_linux && ([[ -f /etc/fedora-release ]] || command -v dnf &> /dev/null)
}

install_packages() {
    local os=$(detect_os)
    case "$os" in
        fedora)
            sudo dnf update -y
            
            # Enable COPR repos for packages not in default repos
            sudo dnf copr enable -y delen/lazygit 2>/dev/null || true
            sudo dnf copr enable -y dturner/eza 2>/dev/null || true
            
            # Install packages from Dnffile
            xargs -a <(grep -vE '^\s*#' "$DOTFILES_DIR/linux/dnf/Dnffile" | grep -vE '^\s*$') \
                sudo dnf install -y
            
            # Install gitflow via pip
            if ! command -v gitflow &> /dev/null; then
                sudo dnf install -y python3-pip
                pip3 install --user gitflow-cli
            fi
            ;;
        debian)
            sudo apt-get update && sudo apt-get upgrade -y
            xargs -a <(grep -vE '^\s*#' "$DOTFILES_DIR/linux/apt/Aptfile" | grep -vE '^\s*$') \
                sudo apt install -y
            ;;
        macos)
            brew update && brew upgrade
            brew bundle --file="$DOTFILES_DIR/macos/homebrew/Brewfile"
            ;;
    esac
}

install_deps() {
    local os=$(detect_os)
    case "$os" in
        fedora)
            sudo dnf update -y
            sudo dnf install -y gcc gcc-c++ make git zsh stow flatpak curl
            sudo dnf copr enable -y atim/starship 2>/dev/null || true
            sudo dnf install -y starship
            ;;
        debian)
            sudo apt-get update && sudo apt-get upgrade -y
            sudo apt install -y libz-dev libssl-dev liblzma-dev libcurl4-gnutls-dev libexpat1-dev gettext cmake gcc bc flatpak
            sudo apt-get install -y git zsh stow
            curl -sS https://starship.rs/install.sh | sh
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                brew update && brew upgrade
            fi
            for pkg in git zsh stow; do
                command -v $pkg &> /dev/null || brew install $pkg
            done
            brew install starship
            ;;
    esac
}
