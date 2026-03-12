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
    is_linux && [[ -f /etc/fedora-release ]] || command -v dnf &> /dev/null
}

install_packages() {
    local os=$(detect_os)
    case "$os" in
        fedora)
            sudo dnf update -y
            xargs -a <(grep -vE '^\s*#' "$DOTFILES_DIR/linux/dnf/Dnffile" | grep -vE '^\s*$') \
                sudo dnf install -y
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
            sudo dnf install -y gcc gcc-c++ make git zsh stow flatpak starship
            ;;
        debian)
            sudo apt-get update && sudo apt-get upgrade -y
            sudo apt install -y libz-dev libssl-dev liblzma-dev libcurl4-gnutls-dev libexpat1-dev gettext cmake gcc bc flatpak
            sudo apt-get install -y git zsh stow
            curl -sS https://starship.dev/install.sh | sh -s -- -y
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
