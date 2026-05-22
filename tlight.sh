#!/bin/bash
###############################################
##  tahio.syndykat server scripts - LIGHT    ##
##  (c) kofany - made with <3                ##
##                                           ##
##  Light variant: no eggdrop/psotnic auto   ##
##  install, no starship (native zsh PS1     ##
##  with Catppuccin Mocha colors), no login  ##
##  fade-in (only animated MOTD).            ##
###############################################

# Colors
light_blue='\033[1;34m'
green='\033[0;32m'
cyan='\033[0;36m'
red='\033[0;31m'
metalic_gray='\033[0;37m'
yellow='\033[1;33m'
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"
NC='\033[0m' # No color


####################################### Text printing
tt() {
    if [ "$#" -eq 1 ]; then
        text="${1}"
        color='\033[1;33m'
        printf "${color}${text}\n${NC}"
    elif [ "$#" -eq 2 ]; then
        color="${1}"
        text="${2}"
        printf "${color}${text}\n${NC}"
    fi
}

####################################### Progress Bar System

# Global variables for the progress bar
declare -a TASKS_NAMES
declare -a TASKS_STATUS  # 0=pending, 1=in_progress, 2=completed
CURRENT_TASK_IDX=0
START_TIME=0
SPINNER_PID=0
SPINNER_CHARS='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

# Initialize tasks - Light edition (no eggdrop, no psotnic)
init_tasks() {
    TASKS_NAMES=(
        "⚡ IPv6 network detection & GitHub proxy setup"
        "⬢ APT repository synchronization & package matrix"
        "∞ Zsh + Catppuccin Mocha prompt + modern CLI (eza/zoxide/fzf)"
        "◆ SSH hardening & Fail2Ban protection matrix"
        "⧗ Animated MOTD deployment"
        "⚙ BIND9 DNS server configuration"
        "➜ KNB bot initialization protocol"
        "⚡ Binary update & system finalization"
    )

    # Initialize all as pending (0)
    for i in "${!TASKS_NAMES[@]}"; do
        TASKS_STATUS[$i]=0
    done

    START_TIME=$(date +%s)
}

# Function drawing progress bar - Light edition (open-ended frame)
draw_progress() {
    printf '\033[0m' 2>/dev/null
    tput sgr0 2>/dev/null
    tput colors >/dev/null 2>&1 || return

    local total_tasks=${#TASKS_NAMES[@]}
    local completed_tasks=0

    for status in "${TASKS_STATUS[@]}"; do
        if [ "$status" -eq 2 ]; then
            ((completed_tasks++))
        fi
    done

    local percent=$((completed_tasks * 100 / total_tasks))

    local current_time=$(date +%s)
    local elapsed=$((current_time - START_TIME))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))

    tput cup 0 0 2>/dev/null
    tput ed 2>/dev/null
    sleep 0.01
    tput civis 2>/dev/null

    echo -e "${cyan}╔═══[${yellow}⚡ tlight v1.0 ⚡${cyan}]═══[${green}DEPLOYING LIGHT MAINFRAME${cyan}]${NC}"
    echo -e "${cyan}║${NC}"

    local bar_width=40
    local filled=$((percent * bar_width / 100))
    local empty=$((bar_width - filled))

    printf "${cyan}║${NC}  ${yellow}⬢${NC} SYSTEM INIT :: ["
    printf "${green}%${filled}s" | tr ' ' '█'
    printf "${metalic_gray}%${empty}s" | tr ' ' '░'
    printf "${NC}] ${cyan}%d/%d${NC} ${green}(%d%%)${NC}\n" "$completed_tasks" "$total_tasks" "$percent"

    echo -e "${cyan}║${NC}"
    echo -e "${cyan}╠═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${cyan}║${NC}"

    for i in "${!TASKS_NAMES[@]}"; do
        local task_name="${TASKS_NAMES[$i]}"
        local status="${TASKS_STATUS[$i]}"
        local icon=""
        local color="${NC}"

        if [ "$status" -eq 2 ]; then
            icon="${green}✓${NC}"
            color="${metalic_gray}"
        elif [ "$status" -eq 1 ]; then
            icon="${yellow}${SPINNER_CURRENT_CHAR}${NC}"
            color="${cyan}"
        else
            icon="${metalic_gray}○${NC}"
            color="${metalic_gray}"
        fi

        echo -e "${cyan}║${NC}  $icon ${color}${task_name}${NC}"
    done

    echo -e "${cyan}║${NC}"
    echo -e "${cyan}╠═══════════════════════════════════════════════════════════════════${NC}"
    printf "${cyan}║${NC}  ${green}⧗ ELAPSED: %02d:%02d${NC}\n" "$minutes" "$seconds"
    echo -e "${cyan}║${NC}"
    echo -e "${cyan}╚═══════════════════════════[${metalic_gray}made with <3 by kofany & yooz${cyan}]${NC}"
}

# Background spinner
spinner_animation() {
    local idx=0
    while true; do
        SPINNER_CURRENT_CHAR="${SPINNER_CHARS:$idx:1}"
        draw_progress
        sleep 0.25
        idx=$(( (idx + 1) % ${#SPINNER_CHARS} ))
    done
}

# Start task
start_task() {
    local task_idx=$1
    CURRENT_TASK_IDX=$task_idx
    TASKS_STATUS[$task_idx]=1
    SPINNER_CURRENT_CHAR="${SPINNER_CHARS:0:1}"

    spinner_animation &
    SPINNER_PID=$!

    sleep 0.2
}

# Complete task
complete_task() {
    local task_idx=$1

    if [ $SPINNER_PID -ne 0 ]; then
        kill $SPINNER_PID 2>/dev/null
        wait $SPINNER_PID 2>/dev/null
        SPINNER_PID=0
        sleep 0.15
    fi

    TASKS_STATUS[$task_idx]=2

    printf '\033[0m'
    tput sgr0 2>/dev/null

    tput cup 0 0 2>/dev/null
    tput ed 2>/dev/null
    sleep 0.02

    draw_progress
    sleep 0.4
}


####################################### Root check

if [ "$(id -u)" -ne 0 ]; then
    tt "⚠ ACCESS DENIED: Root privileges required for mainframe breach."
    exit 1
fi

# Variables storing SSH port and server name
SSH_PORT="${1:-}"
SERVER_NAME="${2:-}"
# Parameter validation
if [ -z "${SSH_PORT}" ] || [ -z "${SERVER_NAME}" ]; then
    tt "⚠ SYNTAX ERROR: bash $0 ${red}SSH_PORT ${yellow}SERVER_NAME\n"
    tt "⚡ MISSING PARAMETERS: SSH port and server hostname required.\n"
    exit 1
fi
# Check if provided SSH port value is valid
if ! [[ "${SSH_PORT}" =~ ^[1-9][0-9]{0,4}$ ]] || [ "${SSH_PORT}" -gt 65535 ]; then
    tt "⚠ INVALID PORT: ${SSH_PORT}. Valid range: 1-65535.\n"
    exit 1
fi

####################################### Helper functions

####################################### Remove file if exists
rm_file()
{
if [ -f "${*}" ]; then
rm -rf ${*} >/dev/null 2>&1
fi
}

# Exit

do_abort()
{
    tt "${red}" "⚠ BREACH ABORTED: Disconnecting from mainframe.\n"
    exit 1
}

# Yes or No

yes_or_no() {
    while true; do
        echo -e "${metalic_gray}$* [y/n]? \c"
        read -n 1 REPLY
        echo -e "\n"
        case "$REPLY" in
            Y|y) return 0 ;;
            N|n) do_abort ;;
        esac
    done
}

####################################### Matrix Intro Banner
banner()
{
    local INTRO_SCRIPT="/tmp/.tlight_intro_$$"

    trap "rm -f '$INTRO_SCRIPT' 2>/dev/null" EXIT INT TERM

    cat > "$INTRO_SCRIPT" << 'INTRO_EOF'
#!/usr/bin/env bash
SSH_PORT="$1"
SERVER_NAME="$2"

printf '\033c\033[?47l\033[?1049l\033[?25l\033[2J'
stty -echo

init_term_matrix() {
    printf '\e[?1049h\e[2J\e[?25l'
    IFS='[;' read -p $'\e[999;999H\e[6n' -rd R -s _ LINES COLUMNS
}

deinit_term_matrix() {
    printf '\e[?1049l\e[?25h'
    stty echo
}

print_to() {
    printf '\e[%d;%dH\e[%d;38;2;%sm%s\e[m' "$2" "$3" "${5:-2}" "$4" "$1"
}

rain() {
    ((dropStart=RANDOM%LINES/9))
    ((dropCol=RANDOM%COLUMNS+1))
    ((dropLen=RANDOM%(LINES/2)+2))
    ((dropSpeed=RANDOM%9+1))
    ((dropColDim=RANDOM%4))
    color=${rain_colors[RANDOM%${#rain_colors[@]}]}
    for ((i=dropStart; i <= LINES+dropLen; i++)); do
        symbol=${1:RANDOM%${#1}:1}
        (( dropColDim )) || print_to "$symbol" $i $dropCol "$color" 1
        (( i > dropStart )) && print_to "$symbol" $((i-1)) $dropCol "$color"
        (( i > dropLen )) && printf '\e[%d;%dH\e[m ' $((i-dropLen)) $dropCol
        sleep 0.$dropSpeed
    done
}

logo=(
"                                             ,ggg, ,ggggggg,  "
"   I8               ,dPYb,                  dP\"\"Y8,8P\"\"\"\"\"Y8b "
"   I8               IP'\`Yb                  Yb, \`8dP'     \`88 "
"88888888            I8  8I      gg           \`\"  88'       88 "
"   I8               I8  8'      \"\"               88        88 "
"   I8     ,gggg,gg  I8 dPgg,    gg     ,ggggg,   88        88 "
"   I8    dP\"  \"Y8I  I8dP\" \"8I   88    dP\"  \"Y8ggg88        88 "
"  ,I8,  i8'    ,8I  I8P    I8   88   i8'    ,8I  88        88 "
" ,d88b,,d8,   ,d8b,,d8     I8,_,88,_,d8,   ,d8'  88        Y8,"
" 8P\"\"Y8P\"Y8888P\"\`Y888P     \`Y88P\"\"Y8P\"Y8888P\"    88        \`Y8"
)

fade_in_logo() {
    local start_line=$(( (LINES - ${#logo[@]}) / 2 ))
    local max_col=0
    for line in "${logo[@]}"; do
        (( ${#line} > max_col )) && max_col=${#line}
    done
    local start_col=$(( (COLUMNS - max_col) / 2 ))
    local fade_colors=("40;40;40" "80;80;80" "120;120;120" "180;180;180" "255;255;255")
    for color in "${fade_colors[@]}"; do
        local line_num=$start_line
        for line in "${logo[@]}"; do
            printf '\e[%d;%dH\e[38;2;%sm%s\e[m' "$line_num" "$start_col" "$color" "$line"
            ((line_num++))
        done
        sleep 0.2
    done
    printf '\e[2J'
    line_num=$start_line
    for line in "${logo[@]}"; do
        local r=$((50 + RANDOM % 50))
        local g=$((200 + RANDOM % 55))
        local b=$((100 + RANDOM % 100))
        printf '\e[%d;%dH\e[38;2;%d;%d;%sm%s\e[m' "$line_num" "$start_col" "$r" "$g" "$b" "$line"
        ((line_num++))
    done
    sleep 2
}

typewriter() {
    local text="$1" color="$2" delay="${3:-0.03}" newline="${4:-yes}"
    for ((i=0; i<${#text}; i++)); do
        printf "\e[38;2;%sm%s\e[m" "$color" "${text:$i:1}"
        sleep "$delay"
    done
    [[ "$newline" == "yes" ]] && echo
}

trap 'kill 0 2>/dev/null; deinit_term_matrix; exit' INT TERM
trap init_term_matrix WINCH
export LC_ALL=en_US.UTF-8

symbols='カキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン0123456789'
rain_colors=('102;255;102' '51;255;51' '0;255;0')

init_term_matrix
stty -echo

rain_pids=()
end_time=$((SECONDS + 5))
while ((SECONDS < end_time)); do
    rain "$symbols" &
    rain_pids+=($!)
    sleep 0.1
done
for pid in "${rain_pids[@]}"; do kill "$pid" 2>/dev/null || true; done
sleep 0.5

printf '\e[2J'
fade_in_logo

printf '\e[2J'
start_line=$(( LINES / 2 - 9 ))
green="0;255;0" cyan="0;255;255" yellow="255;255;0" red="255;0;0" white="255;255;255"

printf '\e[%d;1H' "$start_line"; typewriter "Wake up, Neo..." "$green" 0.05; sleep 0.3; ((start_line++))
printf '\e[%d;1H' "$start_line"; typewriter "The Matrix has you..." "$cyan" 0.04; sleep 0.3; ((start_line++))
printf '\e[%d;1H' "$start_line"; typewriter "Follow the white rabbit 🐇" "$green" 0.03; sleep 0.5; ((start_line++))
printf '\e[%d;1H' "$start_line"; typewriter "Knock, knock, Neo." "$green" 0.03; sleep 0.3; ((start_line+=2))
printf '\e[%d;1H' "$start_line"; typewriter "Port ${SSH_PORT} at ${SERVER_NAME}" "$cyan" 0.03; sleep 0.5; ((start_line+=2))
printf '\e[%d;1H' "$start_line"; typewriter "WARNING: This is your last chance." "$yellow" 0.03; sleep 0.3; ((start_line++))
printf '\e[%d;1H' "$start_line"; typewriter "After this, there is no turning back." "$yellow" 0.03; sleep 0.5; ((start_line+=2))
printf '\e[%d;1H' "$start_line"; typewriter "Blue pill - the story ends, you disconnect." "$cyan" 0.03; sleep 0.3; ((start_line++))
printf '\e[%d;1H' "$start_line"; typewriter "Red pill - you stay and see how deep the rabbit hole goes." "$red" 0.03; sleep 0.5; ((start_line+=2))
printf '\e[%d;1H' "$start_line"
typewriter "Make your choice [" "$green" 0.04 no
typewriter "red" "$red" 0.04 no
typewriter "/" "$green" 0.04 no
typewriter "blue" "$cyan" 0.04 no
typewriter "]: " "$green" 0.04 no
echo ""; ((start_line++))
printf '\e[%d;1H' "$start_line"; typewriter "y = red pill (continue) / n = blue pill (abort)" "$white" 0.02
sleep 2

deinit_term_matrix

exec < /dev/tty
stty sane
reset

exit 0
INTRO_EOF

    chmod +x "$INTRO_SCRIPT"
    bash "$INTRO_SCRIPT" "$SSH_PORT" "$SERVER_NAME"
    rm -f "$INTRO_SCRIPT"

    printf '\033c\033[?1049l\033[?47l\033[?25h\033[0m'
    tput reset 2>/dev/null
    tput init 2>/dev/null
    tput sgr0 2>/dev/null
    export TERM=xterm-256color
    clear

    logo=(
    "                                             ,ggg, ,ggggggg,  "
    "   I8               ,dPYb,                  dP\"\"Y8,8P\"\"\"\"\"Y8b "
    "   I8               IP'\`Yb                  Yb, \`8dP'     \`88 "
    "88888888            I8  8I      gg           \`\"  88'       88 "
    "   I8               I8  8'      \"\"               88        88 "
    "   I8     ,gggg,gg  I8 dPgg,    gg     ,ggggg,   88        88 "
    "   I8    dP\"  \"Y8I  I8dP\" \"8I   88    dP\"  \"Y8ggg88        88 "
    "  ,I8,  i8'    ,8I  I8P    I8   88   i8'    ,8I  88        88 "
    " ,d88b,,d8,   ,d8b,,d8     I8,_,88,_,d8,   ,d8'  88        Y8,"
    " 8P\"\"Y8P\"Y8888P\"\`Y888P     \`Y88P\"\"Y8P\"Y8888P\"    88        \`Y8"
    )

    for line in "${logo[@]}"; do
        r=$((50 + RANDOM % 50))
        g=$((200 + RANDOM % 55))
        b=$((100 + RANDOM % 100))
        echo -e "\e[38;2;${r};${g};${b}m${line}\e[0m"
    done
    echo
    echo -e "${yellow}⚡ tlight v1.0 — light variant${NC}"
    echo -e "${metalic_gray}   no eggdrop/psotnic autoinstall · no starship · native zsh prompt${NC}\n"

    yes_or_no "Ready to enter the Matrix"
}


####################################### IPv6 GitHub Support

do_ipv6_setup()
{
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        GITHUB_URL="https://github.com"
        IPV6_ONLY=false
    else
        if ping -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
            GITHUB_URL="https://danwin1210.de:1443"
            IPV6_ONLY=true
        else
            echo "ERROR: No network connectivity detected!"
            exit 1
        fi
    fi

    export GITHUB_URL
    export IPV6_ONLY
}

####################################### Zsh Configuration with native Catppuccin Mocha prompt

do_zsh_setup()
{
# Install zinit globally (using detected GitHub URL for IPv6 support)
if [ ! -d "/usr/local/share/zinit/zinit.git" ]; then
    mkdir -p /usr/local/share/zinit
    git clone ${GITHUB_URL}/zdharma-continuum/zinit.git /usr/local/share/zinit/zinit.git

    if [ ! -f "/usr/local/share/zinit/zinit.git/zinit.zsh" ]; then
        echo "ERROR: Failed to install zinit from ${GITHUB_URL}/zdharma-continuum/zinit.git" >&2
        exit 1
    fi
fi

# Create global .zshrc for all users (native Catppuccin Mocha prompt, no starship)
cat <<'ZSHRC' > /etc/skel/.zshrc
# Trigger animated MOTD once per login (interactive shells only)
if [[ $- == *i* ]] && [ -z "$TAHION_MOTD_SHOWN" ] && [ -t 1 ]; then
    export TAHION_MOTD_SHOWN=1
    if [ -d /etc/update-motd.d ]; then
        run-parts --lsbsysinit /etc/update-motd.d 2>/dev/null
    fi
fi

# Use globally installed zinit
ZINIT_HOME="/usr/local/share/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

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

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --color=always --icons $realpath 2>/dev/null || ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --tree --color=always --icons $realpath 2>/dev/null || ls --color $realpath'

# Modern CLI aliases
if command -v eza &> /dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --git --group-directories-first'
  alias la='eza -la --icons --git --group-directories-first'
  alias lt='eza --tree --level=2 --icons'
else
  alias ls='ls --color'
  alias ll='ls -lh'
  alias la='ls -lah'
fi

alias c='clear'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias glog='git log --oneline --graph --decorate --all'
alias gundo='git reset --soft HEAD~1'
alias gwip='git add -A && git commit -m "WIP"'
alias myip='curl ifconfig.me'
alias ports='lsof -PiTCP -sTCP:LISTEN'

# Helper functions
mkcd() { mkdir -p "$1" && cd "$1"; }

backup() {
  if [ -f "$1" ]; then
    cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
    echo "✓ Backup created: $1.backup-$(date +%Y%m%d-%H%M%S)"
  else
    echo "✗ File not found: $1"
  fi
}

backupdir() {
  local backup_dir="$HOME/Backups"
  mkdir -p "$backup_dir"
  if [ -f "$1" ]; then
    local filename=$(basename "$1")
    local backup_path="$backup_dir/${filename}.backup-$(date +%Y%m%d-%H%M%S)"
    cp "$1" "$backup_path"
    echo "✓ Backup saved to: $backup_path"
  else
    echo "✗ File not found: $1"
  fi
}

ex() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"   ;;
      *.tar.gz)    tar xzf "$1"   ;;
      *.bz2)       bunzip2 "$1"   ;;
      *.rar)       unrar x "$1"   ;;
      *.gz)        gunzip "$1"    ;;
      *.tar)       tar xf "$1"    ;;
      *.tbz2)      tar xjf "$1"   ;;
      *.tgz)       tar xzf "$1"   ;;
      *.zip)       unzip "$1"     ;;
      *.Z)         uncompress "$1";;
      *.7z)        7z x "$1"      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

gcommit() { git add -A && git commit -m "$*"; }
killport() { lsof -ti:$1 | xargs kill -9; }

# Shell integrations
source <(fzf --zsh)
eval "$(zoxide init --cmd cd zsh)"

# PATH
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.dotnet:$PATH"

############################################################
# Catppuccin Mocha powerline-style prompt (native zsh)
# Inspired by starship catppuccin-powerline preset.
# Requires a Nerd Font for the  arrow glyphs.
############################################################

autoload -Uz vcs_info
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '●'
zstyle ':vcs_info:git:*' unstagedstr '✚'
zstyle ':vcs_info:git:*' formats ' %b %u%c'
zstyle ':vcs_info:git:*' actionformats ' %b|%a %u%c'
zstyle ':vcs_info:*' enable git
setopt PROMPT_SUBST

# Catppuccin Mocha palette
_CTP_BLUE='#89b4fa'
_CTP_PEACH='#fab387'
_CTP_GREEN='#a6e3a1'
_CTP_RED='#f38ba8'
_CTP_MAUVE='#cba6f7'
_CTP_YELLOW='#f9e2af'
_CTP_BASE='#1e1e2e'
_CTP_OVERLAY0='#6c7086'
_CTP_SURFACE0='#313244'

# Powerline arrow glyph (Nerd Font)
_PL_ARROW=$''

# Build a powerline-style prompt on each command
_tahion_build_prompt() {
    local last_exit=$?
    vcs_info

    # Root → red user@host segment, normal user → blue
    local user_bg="$_CTP_BLUE"
    [[ $EUID -eq 0 ]] && user_bg="$_CTP_RED"

    local p=""

    # Segment 1: user@host
    p+="%K{$user_bg}%F{$_CTP_BASE} %n@%m %k"

    # Transition: user_bg → peach
    p+="%F{$user_bg}%K{$_CTP_PEACH}${_PL_ARROW}%F{$_CTP_BASE} %~ %k"

    if [[ -n "$vcs_info_msg_0_" ]]; then
        # Transition: peach → green (git segment)
        p+="%F{$_CTP_PEACH}%K{$_CTP_GREEN}${_PL_ARROW}%F{$_CTP_BASE}${vcs_info_msg_0_} %k"
        # End cap: green → default
        p+="%F{$_CTP_GREEN}${_PL_ARROW}%f"
    else
        # End cap: peach → default
        p+="%F{$_CTP_PEACH}${_PL_ARROW}%f"
    fi

    # Newline + tri-arrow prompt char (mauve/blue/green when ok, all red on error)
    p+=$'\n'
    if [[ $last_exit -eq 0 ]]; then
        p+="%F{$_CTP_MAUVE}❯%F{$_CTP_BLUE}❯%F{$_CTP_GREEN}❯%f "
    else
        p+="%F{$_CTP_RED}❯❯❯%f "
    fi

    PROMPT="$p"
}

precmd_functions+=(_tahion_build_prompt)

# Right prompt: clock in muted overlay color
RPROMPT='%F{#6c7086}%D{%H:%M:%S}%f'
ZSHRC

chmod 644 /etc/skel/.zshrc

# Copy to root
cp /etc/skel/.zshrc /root/.zshrc

# Ghostty terminal compatibility fix
if [ ! -f "/usr/share/terminfo/x/xterm-ghostty" ]; then
    if [ -f "/usr/share/terminfo/g/ghostty" ]; then
        mkdir -p /usr/share/terminfo/x
        cp /usr/share/terminfo/g/ghostty /usr/share/terminfo/x/xterm-ghostty
    fi
fi
}

####################################### Update .zshrc for existing users

do_update_existing_users()
{
for user_home in /home/*; do
    if [ -d "${user_home}" ]; then
        username=$(basename "${user_home}")

        if ! id "${username}" &>/dev/null; then
            continue
        fi

        if [ -f "${user_home}/.zshrc" ]; then
            cp "${user_home}/.zshrc" "${user_home}/.zshrc.backup-$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
        fi

        # Remove leftover p10k / starship configs if present
        rm -f "${user_home}/.p10k.zsh" 2>/dev/null || true
        rm -rf "${user_home}/.cache/p10k-instant-prompt-${username}.zsh" 2>/dev/null || true
        rm -f "${user_home}/.config/starship.toml" 2>/dev/null || true

        cp /etc/skel/.zshrc "${user_home}/.zshrc"
        chown "${username}:${username}" "${user_home}/.zshrc" 2>/dev/null || true
    fi
done
}

####################################### Animated MOTD (no login fade-in)

do_motd_animated()
{
# Create /etc/tahion/ directory for configuration
mkdir -p /etc/tahion

# Rotating ad lines
cat > /etc/tahion/ads.txt <<'ADS'
∞ tb.tahio.eu - Free ipv6 tunnelbroker
⚡ erssi.org - Modern IRC Client
⬢ sshm.io - SSH Management Tool
∞ tb.tahio.eu - Free ipv6 tunnelbroker
⚡ erssi.org - Modern IRC Client
∞ tb.tahio.eu - Free ipv6 tunnelbroker
ADS

# Disable old MOTD methods
rm -f /etc/motd
rm -f /etc/profile.d/motd.sh
# Remove any old tahion welcome (no login fade-in in tlight)
rm -f /etc/profile.d/tahion_welcome.sh

# Clear old update-motd.d scripts
rm -f /etc/update-motd.d/*

# Animated MOTD: per-line color reveal, no full-screen fade-in
cat > /etc/update-motd.d/00-animated <<'MINIMAL'
#!/bin/bash

# Colors
cyan='\e[36m'
neon_blue='\e[96m'
yellow='\e[33m'
green='\e[32m'
magenta='\e[35m'
NC='\e[0m'

# ASCII logo tahioN
logo=(
"                                             ,ggg, ,ggggggg,  "
"   I8               ,dPYb,                  dP\"\"Y8,8P\"\"\"\"\"Y8b "
"   I8               IP'\`Yb                  Yb, \`8dP'     \`88 "
"88888888            I8  8I      gg           \`\"  88'       88 "
"   I8               I8  8'      \"\"               88        88 "
"   I8     ,gggg,gg  I8 dPgg,    gg     ,ggggg,   88        88 "
"   I8    dP\"  \"Y8I  I8dP\" \"8I   88    dP\"  \"Y8ggg88        88 "
"  ,I8,  i8'    ,8I  I8P    I8   88   i8'    ,8I  88        88 "
" ,d88b,,d8,   ,d8b,,d8     I8,_,88,_,d8,   ,d8'  88        Y8,"
" 8P\"\"Y8P\"Y8888P\"\`Y888P     \`Y88P\"\"Y8P\"Y8888P\"    88        \`Y8"
)

# Line-by-line animated reveal with random green palette
for line in "${logo[@]}"; do
    r=$((50 + RANDOM % 50))
    g=$((200 + RANDOM % 55))
    b=$((100 + RANDOM % 100))
    printf "\e[38;2;%d;%d;%dm%s\e[0m\n" "$r" "$g" "$b" "$line"
    sleep 0.05
done

echo ""

# Pick a random ad line
if [ -f /etc/tahion/ads.txt ]; then
    ad=$(shuf -n 1 /etc/tahion/ads.txt 2>/dev/null)
    [ -n "$ad" ] && echo -e "  ${magenta}${ad}${NC}\n"
fi

echo -e "${cyan}${NC} ${magenta}ℹ${NC} Commands: ${neon_blue}motd ${magenta}❯${NC} tahion ${magenta}❯${NC} tahion pl ${magenta}❯${NC} pomoc ${NC}"
echo ""
MINIMAL
chmod +x /etc/update-motd.d/00-animated

# Disable default Ubuntu/Debian MOTD scripts if they exist
chmod -x /etc/update-motd.d/10-help-text 2>/dev/null || true
chmod -x /etc/update-motd.d/50-landscape-sysinfo 2>/dev/null || true
chmod -x /etc/update-motd.d/50-motd-news 2>/dev/null || true
chmod -x /etc/update-motd.d/80-esm 2>/dev/null || true
chmod -x /etc/update-motd.d/80-livepatch 2>/dev/null || true
chmod -x /etc/update-motd.d/90-updates-available 2>/dev/null || true
chmod -x /etc/update-motd.d/91-release-upgrade 2>/dev/null || true
chmod -x /etc/update-motd.d/95-hwe-eol 2>/dev/null || true
}

####################################### Installing packages via APT

do_apt()
{
    DEBIAN_FRONTEND=noninteractive apt-get -y update >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y upgrade >/dev/null 2>&1

    # Basic tools and utilities
    DEBIAN_FRONTEND=noninteractive apt-get -y install sudo telnet wget curl git >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install irssi screen iptables dialog mc htop >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install znc oidentd jq figlet lsof dnsutils >/dev/null 2>&1

    # Build tools and compilers (kept so users can still run get-egg / get-psotnic manually)
    DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential gcc make >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install automake autoconf libtool pkg-config >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install cmake meson ninja-build >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install python3 python3-pip >/dev/null 2>&1

    # Crypto and security
    DEBIAN_FRONTEND=noninteractive apt-get -y install openssl libssl-dev >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install libgcrypt20-dev libotr5-dev >/dev/null 2>&1

    # Core libraries
    DEBIAN_FRONTEND=noninteractive apt-get -y install libglib2.0-dev >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install libutf8proc-dev >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install libncurses-dev >/dev/null 2>&1

    # TCL for eggdrop (optional manual install later)
    DEBIAN_FRONTEND=noninteractive apt-get -y install tcl tcl-dev >/dev/null 2>&1

    # Server software
    DEBIAN_FRONTEND=noninteractive apt-get -y install bind9 fail2ban systemd >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install caddy php-cli php-fpm >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install net-tools >/dev/null 2>&1

    # Zsh and modern CLI tools (no starship)
    DEBIAN_FRONTEND=noninteractive apt-get -y install zsh fzf eza zoxide >/dev/null 2>&1

    # Perl modules for IRC bots
    DEBIAN_FRONTEND=noninteractive apt-get -y install libdbi-perl libwww-perl liburi-escape-xs-perl >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install libhtml-html5-entities-perl libxml-xpath-perl >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install libdbd-mysql-perl liburi-perl libnet-dns-perl >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install libjson-perl libtext-aspell-perl >/dev/null 2>&1

    # Remove unwanted packages
    DEBIAN_FRONTEND=noninteractive apt-get -y remove nftables >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y remove resolvconf >/dev/null 2>&1

    # Clean up
    DEBIAN_FRONTEND=noninteractive apt-get -y autoremove >/dev/null 2>&1
}

####################################### SSH hardening + Fail2Ban

do_sshd_f2b()
{
trusted_ips="127.0.0.1/8"
ssh_port="$SSH_PORT"
max_attempts="4"

rm_file "/etc/fail2ban/jail.local"
if [ ! -f /etc/fail2ban/jail.local ]; then
     cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
fi

echo -e "[DEFAULT]\nignoreip = $trusted_ips\n$(cat /etc/fail2ban/jail.local)" > /etc/fail2ban/jail.local
rm_file "/etc/fail2ban/jail.d/jail-debian.local"
if [ ! -f /etc/fail2ban/jail.d/jail-debian.local ]; then
     touch /etc/fail2ban/jail.d/jail-debian.local
fi

echo -e "[sshd]\nmaxretry = $max_attempts\nport = $ssh_port" > /etc/fail2ban/jail.d/jail-debian.local

systemctl restart fail2ban --quiet --no-pager >/dev/null 2>&1

rm_file "/etc/ssh/sshd_config"
rm_file "/var/log/ssh.txt"
touch /var/log/ssh.txt
echo -e "${SSH_PORT}" >> /var/log/ssh.txt
echo -e "Port ${SSH_PORT}" >> /etc/ssh/sshd_config

if [ "$IPV6_ONLY" = true ]; then
    echo "ListenAddress ::" >> /etc/ssh/sshd_config
else
    echo "ListenAddress 0.0.0.0" >> /etc/ssh/sshd_config
    echo "ListenAddress ::" >> /etc/ssh/sshd_config
fi

cat <<'EOF' >> /etc/ssh/sshd_config
PermitRootLogin no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
Banner /etc/banner
AcceptEnv LANG LC_*
Subsystem       sftp    /usr/lib/openssh/sftp-server
PrintLastLog no

# Keep SSH connections alive
ClientAliveInterval 60
ClientAliveCountMax 3
EOF
rm_file "/etc/resolv.conf"
cat <<'EOF' >> /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 9.9.9.9
nameserver 2001:4860:4860::8888
nameserver 2606:4700:4700::1111
EOF

rm_file "/etc/banner"
cat <<'EOF' >> /etc/banner

                                               ,ggg, ,ggggggg,
     I8               ,dPYb,                  dP""Y8,8P"""""Y8b
     I8               IP'`Yb                  Yb, `8dP'     `88
  88888888            I8  8I      gg           `"  88'       88
     I8               I8  8'      ""               88        88
     I8     ,gggg,gg  I8 dPgg,    gg     ,ggggg,   88        88
     I8    dP"  "Y8I  I8dP" "8I   88    dP"  "Y8ggg88        88
    ,I8,  i8'    ,8I  I8P    I8   88   i8'    ,8I  88        88
   ,d88b,,d8,   ,d8b,,d8     I8,_,88,_,d8,   ,d8'  88        Y8,
   8P""Y8P"Y8888P"`Y888P     `Y88P""Y8P"Y8888P"    88        `Y8

EOF
}

do_bind()
{
rm_file "/etc/bind/named.conf.local"
rm_file "/etc/bind/db.v6"

cat <<'EOF' >> /etc/bind/named.conf.local
//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include "/etc/bind/zones.rfc1918";
#dig +trace -x prefix::/?

#zone "XXXXXXXXXX"      { type master; file "/etc/bind/db.v6"; };
EOF
cat <<'EOF' >> /etc/bind/db.v6
$TTL    60
@       IN      SOA     domena.net. root.domena.net. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          60 )  ; Negative Cache TTL
;
@       IN      NS      domena.net.

#1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0 IN PTR .
EOF
}

do_knb()
{
pushd /root/ >> /dev/null
git clone ${GITHUB_URL}/kofany/knb
if [ -d "/root/knb" ]; then
    cd /root/knb/src/

    if [ -f "./configure" ]; then
        chmod +x configure
        ./configure --without-validator

        if [ $? -eq 0 ]; then
            make dynamic

            if [ $? -ne 0 ]; then
                echo "ERROR: knb make dynamic failed" >&2
                cd /root
                rm -rf /root/knb*
                popd >/dev/null 2>&1
                return 1
            fi

            KNB_BINARY=$(find /root/knb -type f -name "knb-*-*" | head -1)

            if [ -n "$KNB_BINARY" ] && [ -f "$KNB_BINARY" ]; then
                cp "$KNB_BINARY" /bin/knb
                chmod +x /bin/knb
                cd /root
                rm -rf /root/knb*
                popd >/dev/null 2>&1
                return 0
            else
                echo "ERROR: knb binary not found after compilation" >&2
                cd /root
                rm -rf /root/knb*
                popd >/dev/null 2>&1
                return 1
            fi
        else
            echo "ERROR: knb ./configure failed" >&2
            cd /root
            rm -rf /root/knb*
            popd >/dev/null 2>&1
            return 1
        fi
    else
        echo "ERROR: knb configure script not found" >&2
        cd /root
        rm -rf /root/knb*
        popd >/dev/null 2>&1
        return 1
    fi
else
    echo "ERROR: Failed to clone knb from ${GITHUB_URL}/kofany/knb" >&2
    popd >/dev/null 2>&1
    return 1
fi
}


do_update()
{
pushd /root/ >> /dev/null

REPO_URL="${GITHUB_URL}/kofany/tahioN.git"
CLONE_DIR="tahioN"
UPDATE_DIR="${CLONE_DIR}/update"

rm -rf "/root/${CLONE_DIR}"

if git clone --depth 1 "${REPO_URL}" "${CLONE_DIR}" >/dev/null 2>&1; then

    if [ -d "/root/${UPDATE_DIR}" ]; then
        pushd /root/${UPDATE_DIR} >/dev/null 2>&1

        FILES_LIST=$(ls)

        for FILE in ${FILES_LIST}; do
            if [ -f "${FILE}" ]; then
                [ -f "/bin/${FILE}" ] && rm -f "/bin/${FILE}"
                cp "${FILE}" "/bin/${FILE}"
                chmod +x "/bin/${FILE}"
            fi
        done

        popd >/dev/null 2>&1

        if [ ! -f "/bin/tahion" ]; then
            echo "ERROR: tahion binary not installed to /bin/" >&2
            rm -rf /root/${CLONE_DIR}
            popd >/dev/null 2>&1
            return 1
        fi

        rm -rf /root/${CLONE_DIR}

        popd >/dev/null 2>&1
        return 0
    else
        echo "ERROR: update directory not found in cloned repo" >&2
        rm -rf /root/${CLONE_DIR}
        popd >/dev/null 2>&1
        return 1
    fi
else
    echo "ERROR: Failed to clone repository from ${REPO_URL}" >&2
    rm -rf /root/${CLONE_DIR}
    popd >/dev/null 2>&1
    return 1
fi
}

####################################### Logging system

LOG_FILE="/var/log/tlight.log"

init_log() {
    echo "=== tlight Installation Log ===" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

run_task_with_log() {
    local task_idx=$1
    local task_name=$2
    shift 2

    echo "[TASK $task_idx] Starting: $task_name" >> "$LOG_FILE"

    start_task $task_idx

    "$@" >> "$LOG_FILE" 2>&1
    local exit_code=$?

    complete_task $task_idx

    if [ $exit_code -eq 0 ]; then
        echo "[TASK $task_idx] ✓ SUCCESS: $task_name" >> "$LOG_FILE"
    else
        echo "[TASK $task_idx] ✗ FAILED: $task_name (exit code: $exit_code)" >> "$LOG_FILE"
    fi
    echo "" >> "$LOG_FILE"

    return $exit_code
}

####################################### Admin account creation

do_admin()
{
generate_random_password() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1
}

echo -e "\n${yellow}⚡ Create sudo admin accounts? [y/n]${NC}"
read -r create_accounts

if [[ ! "$create_accounts" =~ ^[yY]$ ]]; then
    tt "${green}⬢ Skipping admin account creation."
    return 0
fi

echo -e "\n${yellow}⬢ Enter usernames (space-separated, e.g: user1 user2 user3):${NC}"
read -r user_input

IFS=' ' read -ra users <<< "$user_input"

if [ ${#users[@]} -eq 0 ]; then
    tt "${red}⚠ No usernames provided. Skipping account creation."
    return 0
fi

declare -A user_passwords

echo -e "\n${green}=== ⚡ CREATING USER ENTITIES ===${NC}\n"

for user in "${users[@]}"; do
    if ! [[ "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        tt "${red}⚠ Invalid username: ${user}. Skipping."
        continue
    fi

    if id -u "${user}" >/dev/null 2>&1; then
        tt "${yellow}⬢ User ${user} already exists. Skipping."
    else
        password=$(generate_random_password)
        useradd -m -s /bin/zsh "${user}"
        echo "${user}:${password}" | chpasswd
        user_passwords["${user}"]=${password}

        tt "${green}✓ User ${user} deployed with zsh + Catppuccin Mocha prompt."
    fi
done

if [ ${#user_passwords[@]} -gt 0 ]; then
    echo -e "\n${green}=== ⚡ GRANTING ROOT PRIVILEGES ===${NC}\n"

    for user in "${!user_passwords[@]}"; do
        if grep -q -E "^${user}\s" /etc/sudoers; then
            tt "${yellow}⬢ User ${user} already has sudo privileges."
        else
            echo -e "${user} ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
            tt "${green}✓ User ${user} granted sudo access."
        fi
    done

    external_ip=$(curl -s https://ipinfo.io/ip)

    echo -e "\n${cyan}╔═══[${yellow}⚡ ACCESS CREDENTIALS GENERATED ⚡${cyan}]${NC}"
    echo -e "${cyan}║${NC}"
    echo -e "${cyan}║${NC} ${green}⬢${NC} Server IP:  ${cyan}${external_ip}${NC}"
    echo -e "${cyan}║${NC} ${green}⬢${NC} SSH Port:   ${cyan}${SSH_PORT}${NC}"
    echo -e "${cyan}║${NC}"

    for user in "${!user_passwords[@]}"; do
        echo -e "${cyan}║${NC} ${yellow}➜${NC} User:     ${yellow}${user}${NC}"
        echo -e "${cyan}║${NC} ${yellow}➜${NC} Password: ${cyan}${user_passwords["${user}"]}${NC}"
        echo -e "${cyan}║${NC}"
    done

    echo -e "${cyan}╚═══════════════════════════════════════════════════[${red}SAVE CREDENTIALS${cyan}]${NC}"
    echo -e "\n${red}⚠ CRITICAL: Save these credentials in secure storage!${NC}\n"

else
    tt "${yellow}⬢ No new users created."
fi
}



end_of_all() {
tt "${cyan}" "⚡ tlight has successfully configured your mainframe"
sleep 1.5
tt "${cyan}" "⬢ Execute system reboot and reconnect via new port"
sleep 1.5
tt "${metalic_gray}" "ℹ To install IRC bots later, run: get-egg / get-psotnic / get-znc"
sleep 1.5
}

banner

# Terminal reset after Matrix intro
printf '\033c'
printf '\033[?47l'
printf '\033[?1049l'
printf '\033[?25h'
tput rmcup 2>/dev/null
tput reset 2>/dev/null
tput init 2>/dev/null
tput sgr0
stty sane
stty echo
export TERM=xterm-256color
[ -n "$TMUX" ] && tmux set -g terminal-overrides ",xterm-256color:Tc" 2>/dev/null
[ -n "$TMUX" ] && tmux refresh-client -S 2>/dev/null
clear
sleep 0.15

init_log
init_tasks

clear

# Task 0: IPv6 network detection & GitHub proxy setup
run_task_with_log 0 "IPv6 setup" do_ipv6_setup

# Task 1: APT repository synchronization & package matrix
run_task_with_log 1 "APT packages" do_apt

# Task 2: Zsh + Catppuccin Mocha prompt + modern CLI tools
run_task_with_log 2 "Zsh configuration" do_zsh_setup

# Update existing users with new .zshrc
do_update_existing_users >/dev/null 2>&1

# Task 3: SSH hardening & Fail2Ban protection matrix
run_task_with_log 3 "SSH & Fail2Ban" do_sshd_f2b

# Task 4: Animated MOTD deployment
run_task_with_log 4 "MOTD setup" do_motd_animated

# Task 5: BIND9 DNS server configuration
run_task_with_log 5 "BIND9 DNS" do_bind

# Task 6: KNB bot initialization protocol
run_task_with_log 6 "KNB bot" do_knb

# Task 7: Binary update & system finalization
run_task_with_log 7 "Binary updates" do_update

# Final progress bar display (100%)
sleep 1
tput cnorm
clear

echo -e "${cyan}╔═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${cyan}║${NC}  ${green}✓ BREACH COMPLETE: Light mainframe deployment successful${NC}"
echo -e "${cyan}║${NC}  ${green}⧗ Full system log archived to: ${LOG_FILE}${NC}"
echo -e "${cyan}╚═══════════════════════════════════════════════════════════════════${NC}\n"

# Interactive creation of admin accounts (after installation)
do_admin

end_of_all
sleep 3
