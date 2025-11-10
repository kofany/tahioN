#!/bin/bash
###############################################
##  tahio.syndykat server scripts            ##
##  (c) kofany - made with <3 using ChatGPT  ##
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

# Initialize tasks - Cyberpunk edition
init_tasks() {
    TASKS_NAMES=(
        "⚡ IPv6 network detection & GitHub proxy setup"
        "⬢ APT repository synchronization & package matrix"
        "∞ Zsh + modern CLI tools deployment (eza/zoxide/fzf)"
        "◆ SSH hardening & Fail2Ban protection matrix"
        "⧗ MOTD cyberpunk matrix deployment"
        "⚙ BIND9 DNS server configuration"
        "➜ Eggdrop bot assembly v1.8.4"
        "➜ Psotnic bot deployment sequence"
        "➜ KNB bot initialization protocol"
        "⚡ Binary update & system finalization"
    )

    # Initialize all as pending (0)
    for i in "${!TASKS_NAMES[@]}"; do
        TASKS_STATUS[$i]=0
    done

    START_TIME=$(date +%s)
}

# Function drawing progress bar - Cyberpunk edition (open-ended frame)
draw_progress() {
    # ZAPEWNIAMY, że kolory działają nawet jak coś się zepsuło
    printf '\033[0m' 2>/dev/null       # reset ANSI
    tput sgr0 2>/dev/null
    tput colors >/dev/null 2>&1 || return  # jeśli nie ma 256 kolorów → nie rysuj

    local total_tasks=${#TASKS_NAMES[@]}
    local completed_tasks=0

    # Count completed tasks
    for status in "${TASKS_STATUS[@]}"; do
        if [ "$status" -eq 2 ]; then
            ((completed_tasks++))
        fi
    done

    # Calculate percentage
    local percent=$((completed_tasks * 100 / total_tasks))

    # Calculate elapsed time
    local current_time=$(date +%s)
    local elapsed=$((current_time - START_TIME))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))

    # Move cursor to start and clear screen (without flickering)
    tput cup 0 0 2>/dev/null
    tput ed 2>/dev/null
    sleep 0.01  # Micro-pause for terminal stability
    tput civis 2>/dev/null

    # Cyberpunk header with open-ended frame (no right border)
    echo -e "${cyan}╔═══[${yellow}⚡ tahioN v1.1 ⚡${cyan}]═══[${green}DEPLOYING IRC MAINFRAME${cyan}]${NC}"
    echo -e "${cyan}║${NC}"

    # Progress bar
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

    # Task list
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
        sleep 0.25  # Slower refresh prevents race conditions
        idx=$(( (idx + 1) % ${#SPINNER_CHARS} ))
    done
}

# Start task
start_task() {
    local task_idx=$1
    CURRENT_TASK_IDX=$task_idx
    TASKS_STATUS[$task_idx]=1
    SPINNER_CURRENT_CHAR="${SPINNER_CHARS:0:1}"

    # Start spinner in the background
    spinner_animation &
    SPINNER_PID=$!

    # Give a moment to display
    sleep 0.2
}

# Complete task
complete_task() {
    local task_idx=$1

    # Stop spinner
    if [ $SPINNER_PID -ne 0 ]; then
        kill $SPINNER_PID 2>/dev/null
        wait $SPINNER_PID 2>/dev/null
        SPINNER_PID=0
        sleep 0.15  # Wait until the terminal finishes the last refresh
    fi

    TASKS_STATUS[$task_idx]=2

    # Reset przed finalnym rysowaniem
    printf '\033[0m'                   # reset ANSI
    tput sgr0 2>/dev/null

    # Clear screen before drawing final state
    tput cup 0 0 2>/dev/null
    tput ed 2>/dev/null
    sleep 0.02

    draw_progress
    sleep 0.4  # Longer pause for stability between tasks
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
    # Secure temporary file with PID (unique per process)
    local INTRO_SCRIPT="/tmp/.tahion_intro_$$"
    
    # Trap to ensure cleanup even on Ctrl+C
    trap "rm -f '$INTRO_SCRIPT' 2>/dev/null" EXIT INT TERM
    
    # Create Matrix intro script  
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

# Simple reset - just enough to clean up
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
    
    yes_or_no "Ready to enter the Matrix"
}


####################################### IPv6 GitHub Support

do_ipv6_setup()
{
    # Detect network type (IPv4 vs IPv6-only)
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        # IPv4 works - use normal GitHub URL
        GITHUB_URL="https://github.com"
        IPV6_ONLY=false
    else
        # IPv4 doesn't work, check IPv6
        if ping -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
            # IPv6-only network - use danwin proxy
            GITHUB_URL="https://danwin1210.de:1443"
            IPV6_ONLY=true
        else
            # No network at all
            echo "ERROR: No network connectivity detected!"
            exit 1
        fi
    fi

    # Export variables for other functions
    export GITHUB_URL
    export IPV6_ONLY
}

####################################### Zsh Configuration with Modern CLI Tools

do_zsh_setup()
{
# Install zinit globally (using detected GitHub URL for IPv6 support)
if [ ! -d "/usr/local/share/zinit/zinit.git" ]; then
    mkdir -p /usr/local/share/zinit
    git clone ${GITHUB_URL}/zdharma-continuum/zinit.git /usr/local/share/zinit/zinit.git

    # Verify zinit installation
    if [ ! -f "/usr/local/share/zinit/zinit.git/zinit.zsh" ]; then
        echo "ERROR: Failed to install zinit from ${GITHUB_URL}/zdharma-continuum/zinit.git" >&2
        exit 1
    fi
fi

# Create global .zshrc for all users (without Powerlevel10k)
cat <<'ZSHRC' > /etc/skel/.zshrc
# Load welcome screen (fade-in logo + minimal MOTD)
if [ -f /etc/profile.d/tahion_welcome.sh ]; then
    source /etc/profile.d/tahion_welcome.sh
fi

# Use globally installed zinit
ZINIT_HOME="/usr/local/share/zinit/zinit.git"

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Load completions
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

# Aliases - Modern CLI Tools
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

# Basic aliases
alias c='clear'
alias cls='clear'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git aliases
alias glog='git log --oneline --graph --decorate --all'
alias gundo='git reset --soft HEAD~1'
alias gwip='git add -A && git commit -m "WIP"'

# System
alias myip='curl ifconfig.me'
alias ports='lsof -PiTCP -sTCP:LISTEN'

# Functions
mkcd() {
  mkdir -p "$1" && cd "$1"
}

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

gcommit() {
  git add -A && git commit -m "$*"
}

killport() {
  lsof -ti:$1 | xargs kill -9
}

# Shell integrations
# fzf shell integration (modern method for fzf 0.48.0+)
source <(fzf --zsh)

# zoxide integration
eval "$(zoxide init --cmd cd zsh)"

# Add cargo bin to PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.dotnet:$PATH"

# Starship prompt with catppuccin-powerline preset
eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship.toml
ZSHRC

# Ensure /etc/skel/.zshrc has proper permissions
chmod 644 /etc/skel/.zshrc

# Apply catppuccin-powerline preset for /etc/skel/
mkdir -p /etc/skel/.config
starship preset catppuccin-powerline -o /etc/skel/.config/starship.toml >/dev/null 2>&1

# Copy to root home directory (will include welcome screen sourcing)
cp /etc/skel/.zshrc /root/.zshrc
mkdir -p /root/.config
starship preset catppuccin-powerline -o /root/.config/starship.toml >/dev/null 2>&1
}

####################################### Update .zshrc for existing users

do_update_existing_users()
{
# Update .zshrc and starship.toml for all existing users in /home/
for user_home in /home/*; do
    if [ -d "${user_home}" ]; then
        username=$(basename "${user_home}")

        # Skip if user doesn't exist in system
        if ! id "${username}" &>/dev/null; then
            continue
        fi

        # Backup old .zshrc if exists
        if [ -f "${user_home}/.zshrc" ]; then
            cp "${user_home}/.zshrc" "${user_home}/.zshrc.backup-$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
        fi

        # Remove old p10k config if exists
        rm -f "${user_home}/.p10k.zsh" 2>/dev/null || true
        rm -rf "${user_home}/.cache/p10k-instant-prompt-${username}.zsh" 2>/dev/null || true

        # Copy new .zshrc
        cp /etc/skel/.zshrc "${user_home}/.zshrc"
        chown "${username}:${username}" "${user_home}/.zshrc" 2>/dev/null || true

        # Create .config directory if doesn't exist
        mkdir -p "${user_home}/.config"
        chown "${username}:${username}" "${user_home}/.config" 2>/dev/null || true

        # Apply starship preset
        starship preset catppuccin-powerline -o "${user_home}/.config/starship.toml" >/dev/null 2>&1
        chown "${username}:${username}" "${user_home}/.config/starship.toml" 2>/dev/null || true
    fi
done
}

####################################### MOTD Cyberpunk - modular system /etc/update-motd.d/

do_motd_cyberpunk()
{
# Create /etc/tahion/ directory for configuration
mkdir -p /etc/tahion

# Create welcome script with fade-in logo (shown at every login)
cat > /etc/profile.d/tahion_welcome.sh <<'WELCOME'
#!/bin/bash

# Skip if not interactive shell
[[ $- != *i* ]] && return

# Skip if already shown in this session
[ -n "$TAHION_WELCOME_SHOWN" ] && return
export TAHION_WELCOME_SHOWN=1

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
        sleep 0.25
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
    sleep 1.5
}

fade_in_logo
clear

# Show minimal MOTD
run-parts --lsbsysinit /etc/update-motd.d 2>/dev/null
WELCOME

chmod +x /etc/profile.d/tahion_welcome.sh

# Create file with ads/links (one link per line)
cat > /etc/tahion/ads.txt <<'ADS'
∞ tb.tahio.eu - Free ipv6 tunnelbroker
⚡ erssi.org - Modern IRC Client
⬢ sshm.io - SSH Management Tool
∞ tb.tahio.eu - Free ipv6 tunnelbroker
⚡ erssi.org - Modern IRC Client
∞ tb.tahio.eu - Free ipv6 tunnelbroker
ADS

# Disable old MOTD methods
# PrintMotd is already set to 'no' in sshd_config
rm -f /etc/motd
rm -f /etc/profile.d/motd.sh

# Clear old update-motd.d scripts
rm -f /etc/update-motd.d/*

# Create minimal MOTD with logo + info line only
cat > /etc/update-motd.d/00-minimal <<'MINIMAL'
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

# Fade-in logo with colors (right aligned)
for line in "${logo[@]}"; do
    r=$((50 + RANDOM % 50))
    g=$((200 + RANDOM % 55))
    b=$((100 + RANDOM % 100))
    printf "\e[38;2;%d;%d;%dm%s\e[0m\n" "$r" "$g" "$b" "$line"
    sleep 0.05
done

echo ""
echo -e "${cyan}${NC} ${magenta}ℹ${NC} Commands: ${neon_blue}motd ${magenta}❯${NC} tahio ${magenta}❯${NC} tahio pl ${magenta}❯${NC} pomoc ${NC}"
echo ""
MINIMAL
chmod +x /etc/update-motd.d/00-minimal

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

    # Build tools and compilers
    DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential gcc make >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install automake autoconf libtool pkg-config >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install cmake meson ninja-build >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install python3 python3-pip >/dev/null 2>&1

    # Development libraries - crypto and security
    DEBIAN_FRONTEND=noninteractive apt-get -y install openssl libssl-dev >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install libgcrypt20-dev libotr5-dev >/dev/null 2>&1

    # Development libraries - core libraries
    DEBIAN_FRONTEND=noninteractive apt-get -y install libglib2.0-dev >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install libutf8proc-dev >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install libncurses-dev >/dev/null 2>&1

    # TCL/TK for Eggdrop
    DEBIAN_FRONTEND=noninteractive apt-get -y install tcl tcl-dev >/dev/null 2>&1

    # Server software
    DEBIAN_FRONTEND=noninteractive apt-get -y install bind9 fail2ban systemd >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install caddy php-cli php-fpm >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install net-tools >/dev/null 2>&1

    # Zsh and modern CLI tools
    DEBIAN_FRONTEND=noninteractive apt-get -y install zsh fzf eza zoxide >/dev/null 2>&1

    # Install starship from official installer
    curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1

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
####################################### motd and banner



do_sshd_f2b()
{
# Fail2ban
# Define your trusted IP addresses separated by spaces
trusted_ips="127.0.0.1/8"

# Define SSH port
ssh_port="$SSH_PORT"

# Define maximum number of connection attempts
max_attempts="4"

# Copy jail.conf to jail.local if jail.local does not exist
rm_file "/etc/fail2ban/jail.local"
if [ ! -f /etc/fail2ban/jail.local ]; then
     cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
fi

# Add DEFAULT section with specified ignoreip at the beginning of jail.local
echo -e "[DEFAULT]\nignoreip = $trusted_ips\n$(cat /etc/fail2ban/jail.local)" > /etc/fail2ban/jail.local
rm_file "/etc/fail2ban/jail.d/jail-debian.local"
# Create jail-debian.local if it does not exist
if [ ! -f /etc/fail2ban/jail.d/jail-debian.local ]; then
     touch /etc/fail2ban/jail.d/jail-debian.local
fi

# Add [sshd] section with maxretry and port settings to jail-debian.local
echo -e "[sshd]\nmaxretry = $max_attempts\nport = $ssh_port" > /etc/fail2ban/jail.d/jail-debian.local

# Restart Fail2Ban to apply new settings
systemctl restart fail2ban --quiet --no-pager >/dev/null 2>&1

# sshd_config
rm_file "/etc/ssh/sshd_config"
rm_file "/var/log/ssh.txt"
touch /var/log/ssh.txt
echo -e "${SSH_PORT}" >> /var/log/ssh.txt
echo -e "Port ${SSH_PORT}" >> /etc/ssh/sshd_config

# Conditional IPv6/IPv4 listen
if [ "$IPV6_ONLY" = true ]; then
    echo "ListenAddress ::" >> /etc/ssh/sshd_config
else
    # Dual-stack - listen on both
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

do_egg()
{
pushd /root/ >> /dev/null
# Set URL and filename
url="http://ftp.eggheads.org/pub/eggdrop/source/1.8/eggdrop-1.8.4.tar.gz"
file_name="eggdrop-1.8.4.tar.gz"
correct_sha256="79644eb27a5568934422fa194ce3ec21cfb9a71f02069d39813e85d99cdebf9e"

# Download file
wget -q ${url} -O ${file_name} >/dev/null 2>&1

# Verify the downloaded file
downloaded_sha256=$(sha256sum ${file_name} | awk '{print $1}')

if [ "${correct_sha256}" == "${downloaded_sha256}" ]; then
    :  # SHA256 OK
else
    rm_file ${file_name} >/dev/null 2>&1
    exit 1
fi

    pushd /root/ >/dev/null 2>&1
    tar -zxf /root/eggdrop-1.8.4.tar.gz >/dev/null 2>&1
    pushd /root/eggdrop-1.8.4 >/dev/null 2>&1
    ./configure --enable-ipv6 >/dev/null 2>&1
    make config >/dev/null 2>&1
    make >/dev/null 2>&1
    make install >/dev/null 2>&1
    pushd /root/ >/dev/null 2>&1
    rm -rf  /root/eggdrop/eggdrop.conf >/dev/null 2>&1
cat <<'EOF' >> /root/eggdrop/eggdrop.conf
#! /bin/eggdrop
# ^- This should contain a fully qualified path to your Eggdrop executable.

loadmodule blowfish  ; # Userfile encryption
loadmodule dns       ; # Asynchronous DNS support
loadmodule channels  ; # Channel support
loadmodule server    ; # Core server support
loadmodule ctcp      ; # CTCP functionality
loadmodule irc       ; # Basic IRC functionality
loadmodule transfer ; # DCC SEND/GET and Userfile transfer
loadmodule share    ; # Userfile sharing
loadmodule compress ; # Compress userfiles for transfer
loadmodule filesys  ; # File server support
loadmodule notes     ; # Note storing for users
loadmodule console   ; # Console setting storage
loadmodule seen     ; # Basic seen functionality
loadmodule assoc    ; # Party line channel naming
loadmodule uptime    ; # Centralized uptime stat collection (http://uptime.eggheads.org)

set nick "Lamestbot"
set altnick "Llamab?t"
set realname "/msg LamestBot hello"
set username "lamest"
set admin "Lamer <email: lamer@lamest.lame.org>"
set network "I.didn't.edit.my.config.file.net"

#set owner "MrLame, MrsLame"

set servers {
  you.need.to.change.this:6667
  another.example.com:7000:password
  [2001:db8:618:5c0:263::]:6669:password
  ssl.example.net:+6697
}

set vhost4 "virtual.host.com"
#set vhost4 "99.99.0.0"

set vhost6 "my.ipv6.host.com"
#set vhost6 "2001:db8::c001:b07"


set listen-addr "99.99.0.0"
#set listen-addr "2001:db8:618:5c0:263::"
#set listen-addr "virtual.host.com"


#set nat-ip "127.0.0.1"

#set reserved-portrange 2010:2020

set prefer-ipv6 0

#addlang "english"

logfile mco * "logs/eggdrop.log"

set log-forever 0

if {${log-forever}} {
    set switch-logfiles-at 2500
    set keep-all-logs 0
}

set quiet-save 0

set userfile "LamestBot.user"

set help-path "help/"

#set botnet-nick "LlamaBot"

   listen 3333 bots
   listen 4444 users
##   listen 3333 all
##   listen +5555 all
#listen 3333 all

#set ssl-privatekey "eggdrop.key"
#set ssl-certificate "eggdrop.crt"
set ssl-capath "/etc/ssl/"
#set ssl-cert-auth 0
#set ssl-verify-server 0
#set ssl-verify-dcc 0
#set ssl-verify-bots 0
#set ssl-verify-clients 0
set mod-path "/bin/modules/"
#set dns-servers "8.8.8.8 8.8.4.4"
set chanfile "LamestBot.chan"
set net-type 0
bind evnt - init-server evnt:init_server
proc evnt:init_server {type} {
  global botnick
  putquick "MODE $botnick +i-ws"
}
set default-port 6667
set ctcp-mode 0
unbind msg - ident *msg:ident
unbind msg - addhost *msg:addhost

source scripts/alltools.tcl
source scripts/action.fix.tcl
source scripts/dccwhois.tcl
source scripts/userinfo.tcl
loadhelp userinfo.help

#source scripts/compat.tcl

if {[file exists aclocal.m4]} { die {You are attempting to run Eggdrop from the source directory. Please finish installing Eggdrop by running "make install" and run it from the install location.} }
if {[info exists net-type]} {
  switch -- ${net-type} {
    "0" {
      # EFnet
      source scripts/quotepong.tcl
    }
    "2" {
      # Undernet
      source scripts/quotepass.tcl
    }
  }
}

EOF

mkdir /bin/modules >/dev/null 2>&1
mv /root/eggdrop/modules/* /bin/modules >/dev/null 2>&1
chmod 755 /bin/modules/* >/dev/null 2>&1
pushd /root/ >> /dev/null >/dev/null 2>&1
cp /root/eggdrop/eggdrop-1.8.4 /bin/eggdrop >/dev/null 2>&1
mv /root/eggdrop/eggdrop-1.8.4 /bin/eggdrop-1.8.4 >/dev/null 2>&1
chmod +x /bin/eggdrop >/dev/null 2>&1
chmod +x /bin/eggdrop-1.8.4 >/dev/null 2>&1
tar -czvf egg.tar.gz eggdrop/ >/dev/null 2>&1
mkdir /bin/tools/ >/dev/null 2>&1
mv /root/egg.tar.gz /bin/tools/egg.tar.gz >/dev/null 2>&1
chmod 755 /bin/tools/egg.tar.gz >/dev/null 2>&1
rm -r /root/eggdro* >/dev/null 2>&1
}

do_post()
{
pushd /root/ >> /dev/null

git clone ${GITHUB_URL}/kofany/psotnic
if [ -d "/root/psotnic" ]; then
    cd /root/psotnic/

    # Check if configure exists
    if [ -f "./configure" ]; then
        chmod +x ./configure
        ./configure

        if [ $? -eq 0 ]; then
            make dynamic

            if [ $? -ne 0 ]; then
                echo "ERROR: psotnic make dynamic failed" >&2
                cd /root
                rm -rf /root/psotni*
                popd >/dev/null 2>&1
                return 1
            fi

            if [ -f "/root/psotnic/bin/psotnic" ]; then
                mv /root/psotnic/bin/psotnic /bin/psotnic
                chmod +x /bin/psotnic
                cd /root
                rm -rf /root/psotni*
                popd >/dev/null 2>&1
                return 0
            else
                echo "ERROR: psotnic binary not found after compilation" >&2
                cd /root
                rm -rf /root/psotni*
                popd >/dev/null 2>&1
                return 1
            fi
        else
            echo "ERROR: psotnic ./configure failed" >&2
            cd /root
            rm -rf /root/psotni*
            popd >/dev/null 2>&1
            return 1
        fi
    else
        echo "ERROR: psotnic configure script not found" >&2
        cd /root
        rm -rf /root/psotni*
        popd >/dev/null 2>&1
        return 1
    fi
else
    echo "ERROR: Failed to clone psotnic from ${GITHUB_URL}/kofany/psotnic" >&2
    popd >/dev/null 2>&1
    return 1
fi
}


do_knb()
{
pushd /root/ >> /dev/null
git clone ${GITHUB_URL}/kofany/knb
if [ -d "/root/knb" ]; then
    cd /root/knb/src/

    # Check if configure exists
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

            # Search for knb binary (name may vary)
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

# Constants
REPO_URL="${GITHUB_URL}/kofany/tahioN.git"
CLONE_DIR="tahioN"
UPDATE_DIR="${CLONE_DIR}/update"

# Remove old folder if exists
rm -rf "/root/${CLONE_DIR}"

# Clone repo (uses GITHUB_URL which is IPv6-aware)
if git clone --depth 1 "${REPO_URL}" "${CLONE_DIR}" >/dev/null 2>&1; then

    # Check if update folder exists
    if [ -d "/root/${UPDATE_DIR}" ]; then
        # Enter update folder
        pushd /root/${UPDATE_DIR} >/dev/null 2>&1

        # Get file list
        FILES_LIST=$(ls)

        # Move files to /bin/
        for FILE in ${FILES_LIST}; do
            if [ -f "${FILE}" ]; then
                # Remove old file if exists
                [ -f "/bin/${FILE}" ] && rm -f "/bin/${FILE}"

                # Copy new file
                cp "${FILE}" "/bin/${FILE}"
                chmod +x "/bin/${FILE}"
            fi
        done

        popd >/dev/null 2>&1

        # Verify that key binaries were installed
        if [ ! -f "/bin/tahion" ]; then
            echo "ERROR: tahion binary not installed to /bin/" >&2
            rm -rf /root/${CLONE_DIR}
            popd >/dev/null 2>&1
            return 1
        fi

        # Cleanup - remove cloned repo
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

LOG_FILE="/var/log/tahion.log"

init_log() {
    echo "=== tahioN Installation Log ===" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

run_task_with_log() {
    local task_idx=$1
    local task_name=$2
    shift 2

    echo "[TASK $task_idx] Starting: $task_name" >> "$LOG_FILE"

    # Start task w UI
    start_task $task_idx

    # Execute function and log output
    "$@" >> "$LOG_FILE" 2>&1
    local exit_code=$?

    # Complete task in UI
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
# Function generating random password
generate_random_password() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1
}

# Ask user if they want to create accounts
echo -e "\n${yellow}⚡ Create sudo admin accounts? [y/n]${NC}"
read -r create_accounts

if [[ ! "$create_accounts" =~ ^[yY]$ ]]; then
    tt "${green}⬢ Skipping admin account creation."
    return 0
fi

# Ask for usernames
echo -e "\n${yellow}⬢ Enter usernames (space-separated, e.g: user1 user2 user3):${NC}"
read -r user_input

# Convert input to array
IFS=' ' read -ra users <<< "$user_input"

if [ ${#users[@]} -eq 0 ]; then
    tt "${red}⚠ No usernames provided. Skipping account creation."
    return 0
fi

# Declare associative array for passwords
declare -A user_passwords

# Create users
echo -e "\n${green}=== ⚡ CREATING USER ENTITIES ===${NC}\n"

for user in "${users[@]}"; do
    # Validate username (only alphanumeric and underscore)
    if ! [[ "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        tt "${red}⚠ Invalid username: ${user}. Skipping."
        continue
    fi

    if id -u "${user}" >/dev/null 2>&1; then
        tt "${yellow}⬢ User ${user} already exists. Skipping."
    else
        password=$(generate_random_password)
        # Create user with zsh as default shell
        useradd -m -s /bin/zsh "${user}"
        echo "${user}:${password}" | chpasswd
        user_passwords["${user}"]=${password}

        tt "${green}✓ User ${user} deployed with zsh + starship protocol."
    fi
done

# Add sudo privileges
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

    # Display login credentials
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
tt "${cyan}" "⚡ tahioN has successfully configured your mainframe"
sleep 1.5
tt "${cyan}" "⬢ Execute system reboot and reconnect via new port"
sleep 1.5
}

banner

# ███ TOTALNY RESET TERMINALA PO MATRIXIE - MUSI BYĆ PRZED init_tasks ███
printf '\033c'                     # full reset ESC c
printf '\033[?47l'                 # wychodzi z alternate screen buffer
printf '\033[?1049l'               # wychodzi z alternate screen (na wszelki wypadek)
printf '\033[?25h'                 # pokaż kursor
tput rmcup 2>/dev/null             # na pewno wróć do normalnego bufora
tput reset 2>/dev/null             # twardy reset terminfo
tput init 2>/dev/null              # przeładuj bazę terminfo
tput sgr0                          # wyzeruj wszystkie atrybuty
stty sane
stty echo
export TERM=xterm-256color
[ -n "$TMUX" ] && tmux set -g terminal-overrides ",xterm-256color:Tc" 2>/dev/null
[ -n "$TMUX" ] && tmux refresh-client -S 2>/dev/null
clear
sleep 0.15                         # daj terminalowi czas na przebudzenie

# Teraz dopiero możemy bezpiecznie rysować progress bar
init_log
init_tasks

# Run installation with progress bar
clear

# Task 0: IPv6 network detection & GitHub proxy setup
run_task_with_log 0 "IPv6 setup" do_ipv6_setup

# Task 1: APT repository synchronization & package matrix
run_task_with_log 1 "APT packages" do_apt

# Task 2: Zsh + modern CLI tools deployment
run_task_with_log 2 "Zsh configuration" do_zsh_setup

# Update existing users with new .zshrc and starship config
do_update_existing_users >/dev/null 2>&1

# Task 3: SSH hardening & Fail2Ban protection matrix
run_task_with_log 3 "SSH & Fail2Ban" do_sshd_f2b

# Task 4: MOTD cyberpunk matrix deployment
run_task_with_log 4 "MOTD setup" do_motd_cyberpunk

# Task 5: BIND9 DNS server configuration
run_task_with_log 5 "BIND9 DNS" do_bind

# Task 6: Eggdrop bot assembly v1.8.4
run_task_with_log 6 "Eggdrop bot" do_egg

# Task 7: Psotnic bot deployment sequence
run_task_with_log 7 "Psotnic bot" do_post

# Task 8: KNB bot initialization protocol
run_task_with_log 8 "KNB bot" do_knb

# Task 9: Binary update & system finalization
run_task_with_log 9 "Binary updates" do_update

# Final progress bar display (100%)
sleep 1
tput cnorm
clear

# Installation log info
echo -e "${cyan}╔═══════════════════════════════════════════════════════════════════${NC}"
echo -e "${cyan}║${NC}  ${green}✓ BREACH COMPLETE: Mainframe deployment successful${NC}"
echo -e "${cyan}║${NC}  ${green}⧗ Full system log archived to: ${LOG_FILE}${NC}"
echo -e "${cyan}╚═══════════════════════════════════════════════════════════════════${NC}\n"

# Interactive creation of admin accounts (after installation)
do_admin

end_of_all
sleep 3
