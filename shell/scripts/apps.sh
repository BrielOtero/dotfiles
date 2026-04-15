#!/bin/bash
set -eu

install_flatpak_apps() {
    if ! command -v flatpak &> /dev/null; then
        echo "Flatpak not found. Skipping GUI app installation."
        return
    fi

    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    xargs -a <(grep -vE '^\s*#' "$DOTFILES_DIR/linux/flatpak/Flatpakfile" | grep -vE '^\s*$') \
        flatpak install --user -y flathub

    flatpak override --user \
        --env=SSH_AUTH_SOCK='$SSH_AUTH_SOCK' \
        --filesystem=~/.1password \
        md.obsidian.Obsidian
}

install_1password() {
    if is_fedora; then
        sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
        sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\repo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
        sudo dnf install -y 1password 1password-cli
    elif is_arch; then
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import
        paru -S --noconfirm 1password 1password-cli
    fi

    # Custom allowed browsers for 1Password integration
    sudo mkdir -p /etc/1password
    sudo truncate -s 0 /etc/1password/custom_allowed_browsers

    if command -v zen-bin &> /dev/null; then
        echo "zen-bin" | sudo tee -a /etc/1password/custom_allowed_browsers > /dev/null
    fi

    if command -v helium &> /dev/null; then
        echo "helium" | sudo tee -a /etc/1password/custom_allowed_browsers > /dev/null
    fi

    sudo chown root:root /etc/1password/custom_allowed_browsers
    sudo chmod 755 /etc/1password/custom_allowed_browsers
}

install_vscode() {
    # Arch: installed via Pacmanfile (visual-studio-code-bin)
    if is_arch; then return; fi

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
