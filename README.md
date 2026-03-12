# Dotfiles

## Installation

```bash
# Clone to ~/.dotfiles
git clone https://github.com/BrielOtero/dotfiles.git ~/.dotfiles

# Run bootstrap
cd ~/.dotfiles && chmod +x bootstrap.sh && ./bootstrap.sh
```

Or via curl:

```bash
curl -sSL https://raw.githubusercontent.com/BrielOtero/dotfiles/main/bootstrap.sh | bash
```

## Usage

```bash
./shell/scripts/reload.sh   # Reload stow symlinks
source ~/.zshrc             # Reload shell config
```