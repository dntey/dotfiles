#!/bin/bash
set -e

echo "Starting Fedora System Bootstrap..."

# add tailscale repository to dnf list
TAILSCALE_REPO_URL="https://pkgs.tailscale.com/stable/fedora/tailscale.repo"
TAILSCALE_REPO_DIR="/etc/yum.repos.d/tailscale.repo"
if dnf repolist | grep -q '^tailscale-stable'; then
    echo "Tailscale repo already exists, skipping repo setup..."
else
    echo "Adding Tailscale repo..."
    sudo dnf config-manager addrepo --from-repofile="$TAILSCALE_REPO_URL"
    sudo dnf install tailscale
fi

# Update system and install native DNF packages
sudo dnf upgrade -y
sudo dnf install -y \
    htop \
    zsh \
    gh \
    syncthing \
    zoxide \
    stow \
    emacs \
    neovim \
    git curl ripgrep fd-find \
    R

# set Zsh as default shell
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "Changing default shell to Zsh..."
    chsh -s $(which zsh)
fi


# Homebrew installation
if command -v brew &> /dev/null; then
    echo "Homebrew already installed: $(brew --version | head -n 1)"
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    echo "Homebrew already installed at /home/linuxbrew/.linuxbrew/bin/brew"
else
    echo "Installing homebrew for linux..."
  
    # 1. Manually create the directory and set ownership to avoid sudo permission errors
    sudo mkdir -p /home/linuxbrew/.linuxbrew
    sudo chown -R "$(whoami)" /home/linuxbrew/.linuxbrew
  
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc
  
    # add brew to PATH for this script session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Persist Homebrew PATH setup for future shells
if command -v brew &> /dev/null; then
    # Define the exact line we want to add
    BREW_SHELLENV_LINE='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'

    # Check if the line already exists in ~/.zshrc and add it if it doesn't
    # The `grep -qxF` command checks for an exact match of the line.
    # `2>/dev/null` suppresses any error messages from grep if the file doesn't exist yet.
    if ! grep -qxF "$BREW_SHELLENV_LINE" ~/.zshrc 2>/dev/null; then
        echo "$BREW_SHELLENV_LINE" >> ~/.zshrc
        echo "Added Homebrew shellenv to ~/.zshrc"
    else
        echo "Homebrew shellenv already present in ~/.zshrc"
    fi

    # Do the same for ~/.bashrc if you still use bash for some reason
    # (though you set zsh as default)
    if ! grep -qxF "$BREW_SHELLENV_LINE" ~/.bashrc 2>/dev/null; then
        echo "$BREW_SHELLENV_LINE" >> ~/.bashrc
        echo "Added Homebrew shellenv to ~/.bashrc"
    else
        echo "Homebrew shellenv already present in ~/.bashrc"
    fi
fi

# install homebrew packages
echo "Installing packages from homebrew..."
brew install yazi lazygit

# Fonts
echo "Installing SF Mono Nerd Fonts..."
SF_FONT_DIR="$HOME/.local/share/fonts/SF-Mono-Nerd-Font"
if [ ! -d "$SF_FONT_DIR" ]; then
    mkdir -p "$HOME/.local/share/fonts"
    git clone https://github.com/epk/SF-Mono-Nerd-Font.git "$SF_FONT_DIR"
    fc-cache -fv
fi

# Dotfiles from stow
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR"  ]; then
    echo "Enter the URL for the dotfiles repo"
    read REPO_URL
    git clone "$REPO_URL" "$DOTFILE_DIR"
    cd "$DOTFILES_DIR"
    echo "Stowing configs..."
    stow emacs terminal gnome
    cd "$HOME"
fi

# enable and start services
sudo systemctl enable --now tailscaled
sudo systemctl start tailscaled
sudo tailscale up
systemctl --user enable --now syncthing

# DOOM Emacs
git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install

echo "Bootstrap complete! Log out and back in to fully apply Zsh and groups"
