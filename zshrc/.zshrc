# DOTFILES & ENV DETECTION
export DOTFILES="$HOME/Developer/personal/dotfiles"

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
ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"
plugins=(git)
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# CLI TOOLS
# Load zoxide for smart directory navigation (z)
eval "$(zoxide init zsh)"

# USER ALIASES

# Reload config
alias reload='source ~/.zshrc'

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/id/.lmstudio/bin"

# Eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

