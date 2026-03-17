# DOTFILES & ENV DETECTION
export DOTFILES="$HOME/.dotfiles"

# STARSHIP
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"

# NVM
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi

# PYENV
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  command -v pyenv-virtualenv >/dev/null 2>&1 && eval "$(pyenv virtualenv-init -)"
fi

# DEFAULT EDITOR SELECTION
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="nano"
else
  export EDITOR="code"
fi

# ZSH + OH-MY-ZSH SETUP
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="$DOTFILES/zsh/themes"
ZSH_THEME=""
HYPHEN_INSENSITIVE="true"
plugins=(git)
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# CLI TOOLS
# Load zoxide for smart directory navigation (z)
eval "$(zoxide init zsh)"
alias cd='z'

# 1password
if [ -S "$HOME/.1password/agent.sock" ]; then
    export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
elif [ -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]; then
    export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
fi

# USER ALIASES

# Update packages based on OS
update() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        echo "Updating macOS packages..."
        brew update && brew upgrade
    elif [[ "$(uname -s)" == "Linux" ]]; then
        if command -v dnf &> /dev/null; then
            echo "Updating Fedora packages..."
            sudo dnf update -y
        else
            echo "Updating Debian/Ubuntu packages..."
            sudo apt-get update && sudo apt-get upgrade -y
        fi
    fi
    
    # Update Flatpak if available
    if command -v flatpak &> /dev/null; then
        echo "Updating Flatpak packages..."
        flatpak update -y
    fi
    
    # Update pip if available
    if command -v pip &> /dev/null; then
        echo "Updating pip packages..."
        pip install --upgrade pip 2>/dev/null || true
    fi
    
    # Update npm global packages if available
    if command -v npm &> /dev/null; then
        echo "Updating npm global packages..."
        npm update -g 2>/dev/null || true
    fi
}

# Reload config
alias reload='source ~/.zshrc'

# LM Studio (if exists)
if [ -d "$HOME/.lmstudio/bin" ]; then
    export PATH="$PATH:$HOME/.lmstudio/bin"
fi

# Eza
alias l="eza -l --icons --git -a"
alias ll="eza -l --icons --git"
alias la="eza -la --icons --git"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# FZF
if command -v fzf &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    eval "$(fzf --zsh)"
fi


# pnpm
if [ -d "$HOME/Library/pnpm" ]; then
    export PNPM_HOME="$HOME/Library/pnpm"
elif [ -d "$HOME/.local/share/pnpm" ]; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) [ -n "$PNPM_HOME" ] && export PATH="$PNPM_HOME:$PATH" ;;
esac

# ffmpeg (macOS homebrew path)
if [ -d "/opt/homebrew/opt/ffmpeg-full/bin" ]; then
    export PATH="/opt/homebrew/opt/ffmpeg-full/bin:$PATH"
fi

# opencode
if [ -d "$HOME/.opencode/bin:$PATH" ]; then
    export PATH="$HOME/.opencode/bin:$PATH"
fi


