# ~/.config/fish/config.fish

# Ensure user bin paths are visible
set -gx PATH $HOME/.local/bin $PATH

# Preferred editor
set -U EDITOR nvim

# --- Starship prompt ---
if type -q starship
    starship init fish | source
end

# --- Aliases (bash → fish) ---
alias ls='eza --icons=always'
alias ll='eza -lah --icons=always'
alias grep='rg --color=auto'
alias cat='bat'

# --- fzf defaults (bash → fish) ---
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_DEFAULT_OPTS "--height=40% --layout=reverse --ansi \
--preview 'bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || sed -n \"1,200p\" {}' \
--preview-window=up:60%"

# --- zoxide (smart cd) ---
zoxide init fish | source

# --- fzf keybindings (bash → fish) ---
if test -f ~/.fzf/fish/key-bindings.fish
    source ~/.fzf/fish/key-bindings.fish
end
if test -f ~/.fzf/fish/completion.fish
    source ~/.fzf/fish/completion.fish
end

# --- Git prompt integration (bash __git_ps1 not needed; starship handles this) ---

# --- Functions (bash → fish) ---
# Fuzzy select directory from zoxide



function zfz
    set dir (zoxide query -l | fzf +s --tiebreak=index --preview='eza -la {}')
    if test -n "$dir"
        cd "$dir"
    end
end

# Fuzzy cd using fd + fzf
function fzfcd
    set dir (fd --hidden --type d --exclude .git | fzf --height 40% --preview 'eza -la {}')
    if test -n "$dir"
        cd "$dir"
    end
end

# --- Cargo env (Rust) ---
if test -f ~/.cargo/env.fish
    source ~/.cargo/env.fish
end

# --- Hyprland autostart (bash if → fish) ---
# if test -z "$DISPLAY"; and test -z "$WAYLAND_DISPLAY"; and test (tty) = "/dev/tty1"
#    exec Hyprland
# end

# --- Misc vars ---
set -gx HYPRSHOT_DIR ~/Documents/screenshots

set -x PATH $PATH /home/andre/.local/share/gem/ruby/3.4.0/bin

abbr vim nvim
abbr cd z
abbr gc 'git clone'
abbr docb 'docker compose up --build'
abbr docr 'docker compose up'
abbr docd 'docker compose down'
abbr l 'eza --icons=always'
abbr sshseed 'ssh -i ~/.ssh/seed_ubuntu seed@192.168.1.221'
abbr bgrep 'batgrep'


abbr fzd fzfcd

abbr wifion 'nmcli radio wifi on'
abbr wifioff 'nmcli radio wifi off'

alias sur='su -s /usr/bin/fish'
alias savvy='~/.savvy/SavvyCAN-x86_64.AppImage'
alias cansingle='sudo ip link set can0 type can bitrate 500000 2>/dev/null; sudo ip link set up can0'
alias please='sudo'

function redo --description 'Re-run last command with sudo (no double-sudo)'
    # Get the last command from history
    set -l last (history --max=1)

    # Trim leading whitespace
    set last (string trim --left $last)

    # If it already starts with sudo, just re-run it
    if string match -qr '^sudo(\s|$)' -- $last
        eval $last
    else
        eval sudo $last
    end
end

