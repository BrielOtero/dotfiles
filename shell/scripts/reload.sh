#!/bin/bash
set -eu
stow -d ~/.dotfiles -t ~ -D zshrc
stow -d ~/.dotfiles -t ~/.config -D config

stow -d ~/.dotfiles -t ~ zshrc
stow -d ~/.dotfiles -t ~/.config config

