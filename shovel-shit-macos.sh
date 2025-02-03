#!/bin/bash
mkdir -p ~/.config/nvim/ && cp -r nvim-config ~/.config/nvim/
mkdir -p ~/.config/kitty/ && cp kitty.conf ~/.config/kitty/

cp .zprofile .zshrc ~

git config --global fetch.prune true
