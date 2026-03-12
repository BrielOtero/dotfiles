#!/bin/bash

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Install pyenv
if [ ! -d "$HOME/.pyenv" ]; then
    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
fi

if command -v pyenv &> /dev/null; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    
    py_versions=("3.12" "3.13.6")
    for py_version in "${py_versions[@]}"; do
        if ! pyenv versions | grep -q "$py_version"; then
            CONFIGURE_OPTS=--disable-install-docular pyenv install -s "$py_version" 2>/dev/null || true
        fi
    done
    
    if pyenv versions | grep -q "3.13"; then
        pyenv global 3.13.6
    fi
fi
