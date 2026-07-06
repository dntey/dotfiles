#!/bin/bash
set -e

# --- 1. Detect Operating System and Package Manager ---
if [ -f /etc/os-release ]; then
    source /etc/os-release
    # $ID is set in the sourced file (e.g., 'fedora', 'debian', 'ubuntu')
    case "$ID" in
        fedora|rhel|centos)
            echo "Detected Fedora/RHEL-based system. Using dnf."
            PACKAGE_MANAGER="dnf"
            TAILSCALE_REPO_URL="https://pkgs.tailscale.com/stable/fedora/tailscale.repo"
            ;;
        debian|ubuntu|mint)
            echo "Detected Debian/Ubuntu-based system. Using apt."
            PACKAGE_MANAGER="apt"
            TAILSCALE_REPO_URL="https://pkgs.tailscale.com/stable/debian/tailscale.repo"
            ;;
        *)
            echo "Error: Unsupported OS ID: $ID"
            exit 1
            ;;
    esac
else
    echo "Error: /etc/os-release not found. Cannot determine OS."
    exit 1
fi

# --- 2. Execute Bootstrap ---
if [ "$PACKAGE_MANAGER" == "dnf" ]; then
    echo "Starting Fedora System Bootstrap..."
else
    echo "Starting Debian System Bootstrap..."
fi

# --- Add Tailscale Repository ---
TAILSCALE_REPO_DIR="/etc/yum.repos.d/tailscale.repo" # Path is similar for both, or use /etc/apt/sources.list.d/ for apt if needed
# Note: For apt, Tailscale usually adds a .list file, but the repo URL provided is valid.
# We will check if the repo exists using the package manager's list command.

if [ "$PACKAGE_MANAGER" == "dnf" ]; then
    REPO_CHECK="dnf repolist | grep -q '^tailscale-stable'"
    ADD_REPO_CMD="sudo dnf config-manager addrepo --from-repofile=\"$TAILSCALE_REPO_URL\""
else
    # For apt, we check if the package is available or the source list exists
    REPO_CHECK="apt-cache policy tailscale | grep -q 'tailscale-stable'"
    # For apt, we can add the repo using add-apt-repository or manually echoing to sources.list
    # Using the official repo file approach with apt:
    ADD_REPO_CMD="sudo curl -fsSL \"$TAILSCALE_REPO_URL\" -o /etc/apt/sources.list.d/tailscale.list && sudo apt update"

    # Add tailscale's gpg key
    sudo mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkgs.tailscale.com/stable/debian/trixie.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    curl -fsSL https://pkgs.tailscale.com/stable/debian/trixie.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
fi

if $REPO_CHECK; then
    echo "Tailscale repo already exists, skipping repo setup..."
else
    echo "Adding Tailscale repo..."
    $ADD_REPO_CMD
    
    # Install tailscale
    if [ "$PACKAGE_MANAGER" == "dnf" ]; then
        sudo dnf install -y tailscale
    else
        sudo apt-get update && sudo apt-get install -y tailscale
    fi
fi

# --- Update System and Install Native Packages ---
if [ "$PACKAGE_MANAGER" == "dnf" ]; then
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
else
    sudo apt update -y
    sudo apt install -y \
        htop \
        zsh \
        gh \
        syncthing \
        zoxide \
        stow \
        emacs \
        neovim \
        git curl ripgrep findutils \
        r-base
fi

# set Zsh as default shell
echo "Configuring Zsh as default shell..."

ZSH_PATH="$(command -v zsh || true)"

if [ -z "$ZSH_PATH" ]; then
    echo "Error: zsh is not installed or not found in PATH."
    exit 1
fi

# Ensure zsh is listed in /etc/shells
if ! grep -qxF "$ZSH_PATH" /etc/shells; then
    echo "Adding $ZSH_PATH to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
fi

# Determine the real user, even if script is run with sudo
TARGET_USER="${SUDO_USER:-$USER}"

CURRENT_SHELL="$(getent passwd "$TARGET_USER" | cut -d: -f7)"

if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    echo "Changing default shell for $TARGET_USER from $CURRENT_SHELL to $ZSH_PATH..."
    sudo chsh -s "$ZSH_PATH" "$TARGET_USER"
else
    echo "Zsh is already the default shell for $TARGET_USER"
fi

# --- Homebrew Installation (Linux) ---
# Logic remains the same regardless of OS
if command -v brew &> /dev/null; then
    echo "Homebrew already installed: $(brew --version | head -n 1)"
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    echo "Homebrew already installed at /home/linuxbrew/.linuxbrew/bin/brew"
else
    echo "Installing Homebrew for Linux..."
    
    sudo mkdir -p /home/linuxbrew/.linuxbrew
    sudo chown -R "$(whoami)" /home/linuxbrew/.linuxbrew
    
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc
    
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# --- Persist Homebrew PATH ---
if command -v brew &> /dev/null; then
    BREW_SHELLENV_LINE='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'

    if ! grep -qxF "$BREW_SHELLENV_LINE" ~/.zshrc 2>/dev/null; then
        echo "$BREW_SHELLENV_LINE" >> ~/.zshrc
        echo "Added Homebrew shellenv to ~/.zshrc"
    else
        echo "Homebrew shellenv already present in ~/.zshrc"
    fi

    if ! grep -qxF "$BREW_SHELLENV_LINE" ~/.bashrc 2>/dev/null; then
        echo "$BREW_SHELLENV_LINE" >> ~/.bashrc
        echo "Added Homebrew shellenv to ~/.bashrc"
    else
        echo "Homebrew shellenv already present in ~/.bashrc"
    fi
fi

# --- Install Homebrew Packages ---
echo "Installing packages from Homebrew..."
brew install yazi lazygit

# --- Fonts ---
echo "Installing SF Mono Nerd Fonts..."
SF_FONT_DIR="$HOME/.local/share/fonts/SF-Mono-Nerd-Font"
if [ ! -d "$SF_FONT_DIR" ]; then
    mkdir -p "$HOME/.local/share/fonts"
    git clone https://github.com/epk/SF-Mono-Nerd-Font.git "$SF_FONT_DIR"
    fc-cache -fv
fi

# --- Dotfiles from Stow ---
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Enter the URL for the dotfiles repo"
    read REPO_URL
    git clone "$REPO_URL" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
    echo "Stowing configs..."
    stow emacs terminal gnome
    cd "$HOME"
fi

# --- Enable and Start Services ---
sudo systemctl enable --now tailscaled
sudo systemctl start tailscaled
sudo tailscale up
systemctl --user enable --now syncthing

# --- DOOM Emacs ---
git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install

echo "Bootstrap complete! Log out and back in to fully apply Zsh and groups"
