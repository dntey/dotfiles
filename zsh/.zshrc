# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"
export PATH=$HOME/bin:/usr/local/bin:$PATH
export nvim="/usr/local/bin/nvim"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

export EDITOR="nvim"
# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='gls --color --hyperlink=auto'
alias la='gls -a --color --hyperlink=auto'
alias lt='eza -Tl'
alias c='clear'
alias skim='/Applications/Skim.app/Contents/MacOS/Skim'
alias icat='kitten icat'
alias diff='kitten diff'
alias gitdiff='git difftool --no-symlinks --dir-diff'
alias wordlelist="curl -s https://raw.githubusercontent.com/tabatkins/wordle-list/main/words"
alias ssh="kitten ssh"
alias ddgr="BROWSER=w3m ddgr -n 5"
alias qvim="NVIM_APPNAME=quarto-nvim-kickstarter nvim"
alias tvim="NVIM_APPNAME=neotex/nvim nvim"
alias rg="rg --hyperlink-format=kitty"
alias du="du -sh"
alias csv="csvlens"

# Shell integrations

eval "$(zoxide init --cmd cd zsh)"
# enable vi mode
# bindkey -v
# enable emacs mode
bindkey -e

# enable imagemagick to be found from homebrew?
export DYLD_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_LIBRARY_PATH"

# mactex install location
eval "$(/usr/libexec/path_helper)"

path=('/Users/dante/Library/Python/3.9/bin' $path)
export PATH

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/Users/dante/.juliaup/bin' $path)
export PATH

# <<< juliaup initialize <<<

source ~/.chatGPT_APIKEY
export GOPATH=$HOME/go
export PATH=/Users/dante/.juliaup/bin:/Users/dante/Library/Python/3.9/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/TeX/texbin:/Applications/quarto/bin:/Users/dante/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/dante/.juliaup/bin:/Users/dante/Library/Python/3.9/bin:/Users/dante/.local/share/zinit/polaris/bin:/Applications/kitty.app/Contents/MacOS:/bin:$GOPATH/bin
# export PATH=$HOME/.docker/bin

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/dante/.lmstudio/bin"
# End of LM Studio CLI section
#
export PATH='/Users/dante/.duckdb/cli/latest':$PATH

export PATH='/Users/dante/.config/emacs/bin':$PATH

# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"
