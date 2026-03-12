#!/bin/bash
set -eu

install_flatpak_apps() {
    if ! command -v flatpak &> /dev/null; then
        echo "Flatpak not found. Skipping GUI app installation."
        return
    fi

    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    xargs -a <(grep -vE '^\s*#' "$DOTFILES_DIR/linux/flatpak/Flatpakfile" | grep -vE '^\s*$') \
        flatpak install -y flathub
}


install_zen_browser() {
    if is_fedora; then
        sudo dnf copr enable -y firminunderscore/zen-browser
        sudo dnf install -y zen-browser
    else
        echo "Zen Browser is only supported on Fedora/RHEL for now"
    fi
}

install_helium() {
    if is_fedora; then
        sudo dnf copr enable -y jhuang6451/helium-browser
        sudo dnf install -y helium-browser
    else
        sudo apt-get install -y helium
    fi
}

install_ghostty() {
    if is_fedora; then
        sudo dnf copr enable -y scottames/ghostty
        sudo dnf install -y ghostty
    else
        echo "Ghostty via COPR is only available on Fedora"
    fi
}


install_1password() {
    if is_fedora; then
        sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
        sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
        sudo dnf install -y 1password 1password-cli
    else
        sudo apt-get update
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor -o /usr/share/keyrings/1password-archive-keyring.gpg
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/edge main' | sudo tee /etc/apt/sources.list.d/1password.list
        sudo apt-get update && sudo apt-get install -y 1password 1password-cli
    fi

    # Create Custom Allowed Browsers file for Zen and Helium
    sudo mkdir -p /etc/1password
    sudo touch /etc/1password/custom_allowed_browsers
    
    # Add Zen Browser if installed
    if command -v zen-browser &> /dev/null; then
        echo "zen-browser" | sudo tee -a /etc/1password/custom_allowed_browsers
    elif command -v zen-bin &> /dev/null; then
        echo "zen-bin" | sudo tee -a /etc/1password/custom_allowed_browsers
    fi
    
    # Add Helium Browser if installed
    if command -v helium-browser &> /dev/null; then
        echo "helium-browser" | sudo tee -a /etc/1password/custom_allowed_browsers
    elif command -v helium &> /dev/null; then
        echo "helium" | sudo tee -a /etc/1password/custom_allowed_browsers
    fi
    
    sudo chown root:root /etc/1password/custom_allowed_browsers
    sudo chmod 755 /etc/1password/custom_allowed_browsers
}

install_vscode() {
    if is_fedora; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf check-update
        sudo dnf install -y code
    else
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
        sudo apt update
        sudo apt install -y code
    fi
}

install_vicinae() {
    if is_fedora; then
        sudo dnf copr enable -y quadratech188/vicinae
        sudo dnf install -y vicinae
    else
        echo "Vicinae is only available on Fedora via COPR"
    fi
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
 
    if ! sudo dnf config-manager addrepo --from-repofile"$repourl"; then
        echo "Failed to add NVIDIA CUDA repo. Skipping NVIDIA driver installation."
        return
    fi

    sudo dnf clean expire-cache

    # Install open kernel modules
    # sudo dnf install -y nvidia-open

    # Alternative: Install proprietary drivers
    sudo dnf install -y cuda-drivers

    echo "NVIDIA drivers installed. Reboot required."
}

install_linux_apps() {
    install_flatpak_apps
    install_zen_browser
    install_helium
    install_ghostty
    install_1password
    install_vscode
    install_vicinae
    install_nvidia

    echo ""
    echo "=============================================="
    echo "IMPORTANT: Restart 1Password and your browsers"
    echo "=============================================="
    echo "For 1Password browser integration to work:"
    echo "- Restart 1Password app"
    echo "- Restart Zen Browser and/or Helium"
    echo "=============================================="
    echo ""
}
