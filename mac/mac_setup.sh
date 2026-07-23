#!/bin/bash

set -euo pipefail

# BASEDIR=$(dirname $0)
BASEDIR="$(cd "$(dirname "$0")" && pwd)"
set +u
source "$BASEDIR/base_setup.sh"
set -u

step "Install brew..."
if command -v brew >/dev/null 2>&1; then
  echo "Homebrew is already installed. Updating..."
  brew update
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Only add shellenv if /opt/homebrew exists (Apple Silicon)
if [ -x /opt/homebrew/bin/brew ]; then
    # Load brew into current terminal session
    eval "$(/opt/homebrew/bin/brew shellenv)"

    if ! grep -Fxq 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
fi

success "Done"

step "Installing development tools..."
brew install --cask iterm2
brew install --cask raycast
brew install zsh
brew install git
brew install bat
success "Done"

step "Installing plugins zsh..."

if grep -q '^ZSH_THEME=' ~/.zshrc; then
  # Replace existing ZSH_THEME line
  sed -i '' 's/^ZSH_THEME=.*/ZSH_THEME="gnzh"/' ~/.zshrc
else
  # Add it at the end if missing
  echo 'ZSH_THEME="gnzh"' >> ~/.zshrc
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://install.ohmyz.sh/)"
else
  echo "Oh My Zsh already installed."
fi

export ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_plugin https://github.com/zsh-users/zsh-completions              "$ZSH_CUSTOM/plugins/zsh-completions"
clone_plugin https://github.com/zsh-users/zsh-autosuggestions          "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_plugin https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"
clone_plugin https://github.com/fdellwing/zsh-bat.git                  "$ZSH_CUSTOM/plugins/zsh-bat"
clone_plugin https://github.com/zsh-users/zsh-syntax-highlighting.git  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

if grep -q "^plugins=" ~/.zshrc; then
    sed -i '' -E 's/^plugins=\(.*\)/plugins=(git zsh-completions zsh-autosuggestions you-should-use zsh-bat)/' ~/.zshrc
else
    echo 'plugins=(git zsh-completions zsh-autosuggestions you-should-use zsh-bat)' >> ~/.zshrc
fi

if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
  echo "source \$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
fi

success "Done"

step "Customizing zsh configurations..."

cp -f "$BASEDIR/alias.zsh" "$ZSH_CUSTOM/alias.zsh"

success "Done"