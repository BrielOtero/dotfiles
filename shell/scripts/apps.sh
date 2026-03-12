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

install_1password() {
    if is_fedora; then
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
    if command -v zen-bin &> /dev/null; then
        echo "zen-bin" | sudo tee -a /etc/1password/custom_allowed_browsers
    fi
    
    # Add Helium Browser if installed
    if command -v helium &> /dev/null; then
        echo "helium" | sudo tee -a /etc/1password/custom_allowed_browsers
    fi
    
    sudo chown root:root /etc/1password/custom_allowed_browsers
    sudo chmod 755 /etc/1password/custom_allowed_browsers
}

install_zen_browser() {
    if is_fedora; then
        sudo dnf config-manager --add-repo https://dl.zen-browser.dev/rpm/zen-browser.repo
        sudo dnf install -y zen-browser
    else
        echo "Zen Browser is only supported on Fedora/RHEL for now"
    fi
}

install_helium() {
    if is_fedora; then
        # Helium not in Fedora repos, install via direct download or skip
        echo "Helium Browser not available in Fedora repos. Skipping."
    else
        sudo apt-get install -y helium
    fi
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

install_linux_apps() {
    install_flatpak_apps
    install_1password
    install_zen_browser
    install_helium
    install_vscode

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
