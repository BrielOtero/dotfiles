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

install_nvidia() {
    if ! is_fedora; then
        echo "NVIDIA drivers via this script are only supported on Fedora"
        return
    fi

    # Check if NVIDIA GPU is present
    if ! command -v nvidia-smi &> /dev/null && ! lspci | grep -i nvidia &> /dev/null; then
        echo "No NVIDIA GPU detected. Skipping NVIDIA driver installation."
        return
    fi

    echo "Installing NVIDIA drivers for Fedora..."

    # Install kernel headers
    sudo dnf install -y kernel-devel-matched kernel-headers

    # Add NVIDIA network repository
    fedver=$(grep -oP '(?<=VERSION_ID=)\d+' /etc/os-release)
    repodir="fedora${fedver}"
    repourl="https://developer.download.nvidia.com/compute/cuda/repos/$repodir/x86_64/cuda-$repodir.repo"
 
    # Check if NVIDIA has published a repo for this Fedora version
    if ! curl --silent --head --fail "$repourl" &> /dev/null; then
        echo "No official NVIDIA CUDA repo found for Fedora $fedver (tried $repourl). Skipping."
        return
    fi
 
    if ! sudo dnf config-manager addrepo --from-repofile="$repourl"; then
        echo "Failed to add NVIDIA CUDA repo. Skipping NVIDIA driver installation."
        return
    fi

    sudo dnf clean expire-cache

    # Install open kernel modules
    # sudo dnf install -y nvidia-open

    # Alternative: Install proprietary drivers
    sudo dnf install -y cuda-drivers
    sudo dnf install -y nvidia-driver kmod-nvidia-latest-dkms

    echo "NVIDIA drivers installed. Reboot required."
}

install_packages() {
    local os=$(detect_os)
    case "$os" in
        fedora)
            sudo dnf update -y
            
            # Enable COPR repos for packages not in default repos
            sudo dnf copr enable -y dejan/lazygit
            sudo dnf copr enable -y dturner/eza
            
            # Install packages from Dnffile
            xargs -a <(grep -vE '^\s*#' "$DOTFILES_DIR/linux/dnf/Dnffile" | grep -vE '^\s*$') \
                sudo dnf install -y
            
            # Install gitflow via pip
            if ! command -v gitflow &> /dev/null; then
                sudo dnf install -y python3-pip
                pip3 install --user gitflow-cli
            fi

            # Install NVIDIA drivers
            install_nvidia
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
            sudo dnf install -y gcc gcc-c++ make git stow flatpak curl
            ;;
        debian)
            sudo apt-get update && sudo apt-get upgrade -y
            sudo apt install -y libz-dev libssl-dev liblzma-dev libcurl4-gnutls-dev libexpat1-dev gettext cmake gcc bc flatpak
            sudo apt-get install -y git stow
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                brew update && brew upgrade
            fi
            for pkg in git stow; do
                command -v $pkg &> /dev/null || brew install $pkg
            done
            ;;
    esac
}
