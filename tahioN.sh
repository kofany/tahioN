#!/bin/bash
###############################################
##  tahio.syndykat server scripts            ##
##  (c) kofany - made with <3 using ChatGPT  ##
###############################################

# Kolory
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
NC='\033[0m' # Brak koloru


####################################### Pisanie tekstu
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

# Globalne zmienne dla progress bar
declare -a TASKS_NAMES
declare -a TASKS_STATUS  # 0=pending, 1=in_progress, 2=completed
CURRENT_TASK_IDX=0
START_TIME=0
SPINNER_PID=0
SPINNER_CHARS='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

# Inicjalizacja tasków - Cyberpunk edition
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

    # Inicjalizacja wszystkich jako pending (0)
    for i in "${!TASKS_NAMES[@]}"; do
        TASKS_STATUS[$i]=0
    done

    START_TIME=$(date +%s)
}

# Funkcja rysująca progress bar - Cyberpunk edition (open-ended frame)
draw_progress() {
    local total_tasks=${#TASKS_NAMES[@]}
    local completed_tasks=0

    # Policz zakończone taski
    for status in "${TASKS_STATUS[@]}"; do
        if [ "$status" -eq 2 ]; then
            ((completed_tasks++))
        fi
    done

    # Oblicz procent
    local percent=$((completed_tasks * 100 / total_tasks))

    # Oblicz elapsed time
    local current_time=$(date +%s)
    local elapsed=$((current_time - START_TIME))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))

    # Wyczyść ekran i ukryj kursor
    clear
    tput civis

    # Cyberpunk header z open-ended frame (no right border)
    echo -e "${cyan}╔═══[${yellow}⚡ tahioN v1.0 ⚡${cyan}]═══[${green}DEPLOYING IRC MAINFRAME${cyan}]${NC}"
    echo -e "${cyan}║${NC}"

    # Pasek postępu
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

    # Lista tasków
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

# Spinner w tle
spinner_animation() {
    local idx=0
    while true; do
        SPINNER_CURRENT_CHAR="${SPINNER_CHARS:$idx:1}"
        draw_progress
        sleep 0.1
        idx=$(( (idx + 1) % ${#SPINNER_CHARS} ))
    done
}

# Start task
start_task() {
    local task_idx=$1
    CURRENT_TASK_IDX=$task_idx
    TASKS_STATUS[$task_idx]=1
    SPINNER_CURRENT_CHAR="${SPINNER_CHARS:0:1}"

    # Uruchom spinner w tle
    spinner_animation &
    SPINNER_PID=$!

    # Daj chwilę na wyświetlenie
    sleep 0.2
}

# Complete task
complete_task() {
    local task_idx=$1

    # Zatrzymaj spinner
    if [ $SPINNER_PID -ne 0 ]; then
        kill $SPINNER_PID 2>/dev/null
        wait $SPINNER_PID 2>/dev/null
        SPINNER_PID=0
    fi

    TASKS_STATUS[$task_idx]=2
    draw_progress
    sleep 0.3
}


####################################### Sprawdzanie root

if [ "$(id -u)" -ne 0 ]; then
    tt "Ten skrypt wymaga uprawnień superużytkownika (root). Uruchom skrypt ponownie jako root."
    exit 1
fi

# Zmienne przechowujące port SSH i nazwę serwera
SSH_PORT="${1:-}"
SERVER_NAME="${2:-}"
# Sprawdzanie parametrów
if [ -z "${SSH_PORT}" ] || [ -z "${SERVER_NAME}" ]; then
    tt "Użyj składni: bash $0 ${red}PORTSSH ${yellow}NAZWA_SERWERA\n"
    tt "Musisz podać poprawny port dla SSH i nazwę serwera.\n"
    exit 1
fi
# Sprawdzenie, czy podane wartości portu SSH są poprawne.
if ! [[ "${SSH_PORT}" =~ ^[1-9][0-9]{0,4}$ ]] || [ "${SSH_PORT}" -gt 65535 ]; then
    tt "Nieprawidłowy numer portu SSH: ${SSH_PORT}. Numer portu powinien być liczbą całkowitą z zakresu 1-65535.\n"
    exit 1
fi

####################################### Funkcje pomocnicze

####################################### Usuwanie pliku jeśli istnieje
rm_file()
{
if [ -f "${*}" ]; then
rm -rf ${*} >/dev/null 2>&1
fi
}

# Wyjscie

do_abort()
{
    tt "${red}" "Anulowanie, kończę działanie.\n"
    exit 1
}

# Tak czy nie

yes_or_no() {
    while true; do
        echo -e "${metalic_gray}$* [t/n]? \c"
        read -n 1 REPLY
        echo -e "\n"
        case "$REPLY" in
            T|t) return 0 ;;
            N|n) do_abort ;;
        esac
    done
}

####################################### Baner
banner()
{

ascii_art="

         tttt                           hhhhhhh               iiii                   NNNNNNNN        NNNNNNNN
      ttt:::t                           h:::::h              i::::i                  N:::::::N       N::::::N
      t:::::t                           h:::::h               iiii                   N::::::::N      N::::::N
      t:::::t                           h:::::h                                      N:::::::::N     N::::::N
ttttttt:::::ttttttt      aaaaaaaaaaaaa   h::::h hhhhh       iiiiiii    ooooooooooo   N::::::::::N    N::::::N
t:::::::::::::::::t      a::::::::::::a  h::::hh:::::hhh    i:::::i  oo:::::::::::oo N:::::::::::N   N::::::N
t:::::::::::::::::t      aaaaaaaaa:::::a h::::::::::::::hh   i::::i o:::::::::::::::oN:::::::N::::N  N::::::N
tttttt:::::::tttttt               a::::a h:::::::hhh::::::h  i::::i o:::::ooooo:::::oN::::::N N::::N N::::::N
      t:::::t              aaaaaaa:::::a h::::::h   h::::::h i::::i o::::o     o::::oN::::::N  N::::N:::::::N
      t:::::t            aa::::::::::::a h:::::h     h:::::h i::::i o::::o     o::::oN::::::N   N:::::::::::N
      t:::::t           a::::aaaa::::::a h:::::h     h:::::h i::::i o::::o     o::::oN::::::N    N::::::::::N
      t:::::t    tttttta::::a    a:::::a h:::::h     h:::::h i::::i o::::o     o::::oN::::::N     N:::::::::N
      t::::::tttt:::::ta::::a    a:::::a h:::::h     h:::::hi::::::io:::::ooooo:::::oN::::::N      N::::::::N
      tt::::::::::::::ta:::::aaaa::::::a h:::::h     h:::::hi::::::io:::::::::::::::oN::::::N       N:::::::N
        tt:::::::::::tt a::::::::::aa:::ah:::::h     h:::::hi::::::i oo:::::::::::oo N::::::N        N::::::N
          ttttttttttt    aaaaaaaaaa  aaaahhhhhhh     hhhhhhhiiiiiiii   ooooooooooo   NNNNNNNN         NNNNNNN
                                                                            tahioN 1.0 - tahioSyndykat script
"

delay=0.1

clear

while IFS= read -r line; do
    # Print the line
    echo "$line"
    
    sleep $delay
done <<< "$ascii_art"

tt "Witaj! Przeprowadzę automatyczną instalację na tej maszynie..."
tt "Twój port SSH zostanie ustawiony na ${cyan}${SSH_PORT}"
tt "Nazwa Twojego serwera zostanie ustawiona na ${yellow}${SERVER_NAME}"
tt "Ten skrypt jest przeznaczony wyłącznie dla tahioSyndykat"
tt "Jeśli nie jesteś jednym z Nas, nie korzystaj z niego, bo zepsujesz swoje pudło! (dupsko również) :P"

yes_or_no "Rozpoczynamy konfigurację boxa?"

}

####################################### IPv6 GitHub Support

do_ipv6_setup()
{
    # Wykryj typ sieci (IPv4 vs IPv6-only)
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        # IPv4 działa - używaj normalnych GitHub URL
        GITHUB_URL="https://github.com"
        IPV6_ONLY=false
    else
        # IPv4 nie działa, sprawdź IPv6
        if ping -c 1 -W 2 2001:4860:4860::8888 >/dev/null 2>&1; then
            # IPv6-only network - używaj danwin proxy
            GITHUB_URL="https://danwin1210.de:1443"
            IPV6_ONLY=true
        else
            # Brak sieci w ogóle
            echo "ERROR: No network connectivity detected!"
            exit 1
        fi
    fi

    # Eksportuj zmienne dla innych funkcji
    export GITHUB_URL
    export IPV6_ONLY
}

####################################### Konfiguracja Zsh z nowoczesnymi narzędziami CLI

do_zsh_setup()
{
# Install zinit globally (używając wykrytego GitHub URL dla wsparcia IPv6)
if [ ! -d "/usr/local/share/zinit" ]; then
    mkdir -p /usr/local/share/zinit
    git clone ${GITHUB_URL}/zdharma-continuum/zinit.git /usr/local/share/zinit/zinit.git >/dev/null 2>&1
fi

# Utwórz globalny .zshrc dla wszystkich użytkowników (bez Powerlevel10k)
cat <<'ZSHRC' > /etc/skel/.zshrc
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
ZSHRC

# Upewnij się że /etc/skel/.zshrc ma odpowiednie uprawnienia
chmod 644 /etc/skel/.zshrc
}

####################################### MOTD Cyberpunk - modułowy system /etc/update-motd.d/

do_motd_cyberpunk()
{
# Utwórz katalog /etc/tahion/ dla konfiguracji
mkdir -p /etc/tahion

# Utwórz plik z reklamami/linkami (jeden link na linię)
cat > /etc/tahion/ads.txt <<'ADS'
⚡ erssi.org - Modern IRC Client
⬢ sshm.io - SSH Management Tool
∞ tb.tahio.eu - TahioN Toolbox
ADS

# Wyłącz stare metody MOTD
# PrintMotd jest już ustawione na 'no' w sshd_config
rm -f /etc/motd
rm -f /etc/profile.d/motd.sh

# Wyczyść stare skrypty update-motd.d
rm -f /etc/update-motd.d/*

# Utwórz /etc/update-motd.d/00-header z cyberpunk stylem + rotating ads
cat > /etc/update-motd.d/00-header <<'HEADER'
#!/bin/bash

# Losuj reklamę z pliku ads.txt
if [ -f /etc/tahion/ads.txt ]; then
    AD_LINE=$(shuf -n 1 /etc/tahion/ads.txt)
else
    AD_LINE="⚡ tahioN IRC Shell Installer"
fi

# Cyberpunk header z open-ended frame
cat <<EOF
╔═══════════════════════════════════════════════════════════════════
║
║  ▀█▀ ▄▀█ █░█ █ █▀█ █▄░█
║  ░█░ █▀█ █▀█ █ █▄█ █░▀█
║
║  ${AD_LINE}
║
╠═══════════════════════════════════════════════════════════════════
EOF
HEADER
chmod +x /etc/update-motd.d/00-header

# Utwórz /etc/update-motd.d/10-sysinfo
cat > /etc/update-motd.d/10-sysinfo <<'SYSINFO'
#!/bin/bash

# Pobierz informacje systemowe
HOSTNAME=$(hostname -f)
KERNEL=$(uname -r)
UPTIME=$(uptime -p | sed 's/up //')
LOAD=$(cat /proc/loadavg | awk '{print $1", "$2", "$3}')
MEMORY=$(free -h | awk '/^Mem:/ {print $3"/"$2}')
SWAP=$(free -h | awk '/^Swap:/ {print $3"/"$2}')

# IPv4 i IPv6
IPV4=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
IPV6=$(ip -6 addr show | grep -oP '(?<=inet6\s)[\da-f:]+' | grep -v '^::1' | grep -v '^fe80' | head -1)

[ -z "$IPV4" ] && IPV4="N/A"
[ -z "$IPV6" ] && IPV6="N/A"

cat <<EOF
║
║  ⬢ SYSTEM STATUS
║
║    ➜ Hostname:      ${HOSTNAME}
║    ➜ Kernel:        ${KERNEL}
║    ➜ Uptime:        ${UPTIME}
║    ➜ Load Average:  ${LOAD}
║    ➜ Memory:        ${MEMORY}
║    ➜ Swap:          ${SWAP}
║    ➜ IPv4:          ${IPV4}
║    ➜ IPv6:          ${IPV6}
║
╠═══════════════════════════════════════════════════════════════════
EOF
SYSINFO
chmod +x /etc/update-motd.d/10-sysinfo

# Utwórz /etc/update-motd.d/50-diskspace
cat > /etc/update-motd.d/50-diskspace <<'DISK'
#!/bin/bash

cat <<EOF
║
║  ⚙ DISK USAGE
║
EOF

# Pokaż wykorzystanie dysków (bez tmpfs, devtmpfs)
df -h | grep -vE '^(tmpfs|devtmpfs|udev)' | awk 'NR==1 {next} {printf "║    %-20s %5s / %-5s (%s)\n", $6, $3, $2, $5}'

cat <<EOF
║
╚═══════════════════════════════════════════════════════════════════
EOF
DISK
chmod +x /etc/update-motd.d/50-diskspace

# Wyłącz domyślne ubuntu/debian MOTD skrypty jeśli istnieją
chmod -x /etc/update-motd.d/10-help-text 2>/dev/null || true
chmod -x /etc/update-motd.d/50-landscape-sysinfo 2>/dev/null || true
chmod -x /etc/update-motd.d/50-motd-news 2>/dev/null || true
chmod -x /etc/update-motd.d/80-esm 2>/dev/null || true
chmod -x /etc/update-motd.d/80-livepatch 2>/dev/null || true
chmod -x /etc/update-motd.d/90-updates-available 2>/dev/null || true
chmod -x /etc/update-motd.d/91-release-upgrade 2>/dev/null || true
chmod -x /etc/update-motd.d/95-hwe-eol 2>/dev/null || true

}

####################################### Wykonywanie instalacji pakietów przez APT

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
####################################### motd i baner

do_motd()
{
    rm_file "/etc/motd"
    rm_file "/etc/banner"
    rm_file "/etc/profile.d/motd.sh"

cat <<'EOF' >> /etc/banner

             ___     -._
            `-. """--._ `-.
               `.      "-. `.
 _____           `.       `. \                        
`-.   """---.._    \        `.\
   `-.         "-.  \         `\
      `.          `-.\          \_.-""""""""--._
        `.           `                          "-.         tahioSyndykat
          `.                                       `.    __....-------...
--..._      \                                       `--"""""""""""---..._
__...._"_-.. \                       _,                             _..-""
`-.      """--`           /       ,-'/|     ,                   _.-"
   `-.                 , /|     ,'  / |   ,'|    ,|        _..-"
      `.              /|| |    /   / |  ,'  |  ,' /        ----"""""""""_`-
        `.            ( \  \      |  | /   | ,'  //                 _.-"
          `.        .'-\/'""\ |  '  | /  .-/'"`\' //            _.-"
    /'`.____`-.  ,'"\  ''''?-.V`.   |/ .'..-P''''  /"`.     _.-"
   '(   `.-._""  ||(?|    /'   >.\  ' /.<   `\    |P)||_..-"___.....---
     `.   `. "-._ \ ('   |     `8      8'     |   `) /"""""    _".""
       `.   `.   `.`.b|   `.__            __.'   |d.'  __...--""
         `.   `.   ".`-  .---      ,-.     ---.  -'.-""
           `.   `.   ""|      -._      _.-      |""
             `.  .-"`.  `.       `""""'       ,'
               `/     `.. ""--..__    __..--""
                `.      /7.--|    """"    |--.__
                  ..--"| (  /'            `\  ` ""--..
               .-"      \\  |""--.    .--""|          "-.
              <.         \\  `.    -.    ,'       ,'     >
             (P'`.        `%,  `.      ,'        /,' .-"'?)
             P    `. \      `%,  `.  ,'         /' .'     \
            | --"  _\||       `%,  `'          /.-'   .    )
            |       `-.""--..   `%..--"""\\"--.'       "-  |
            \          `.  .--"""  "\.\.\ \\.'       )     |
                                            We are the horde

EOF

cat <<'EOF' >> /etc/profile.d/motd.sh
#!/bin/bash
###############################################
##  Tahio Syndykat Server Scripts            ##
##  (c) Kofany - Made with ❤ using ChatGPT   ##
###############################################

# Ustawienie lokalizacji i formatu daty
export LC_ALL=C
export LC_TIME=C

# Pobieranie aktualnej daty
current_date=$(date)

# Definicje dni tygodnia i miesięcy w językach polskim i angielskim
dni=("Niedziela" "Poniedziałek" "Wtorek" "Środa" "Czwartek" "Piątek" "Sobota")
miesiace=("Styczeń" "Luty" "Marzec" "Kwiecień" "Maj" "Czerwiec" "Lipiec" "Sierpień" "Wrzesień" "Październik" "Listopad" "Grudzień")

# Formatowanie daty
dzien_tygodnia_pl=${dni[$(date +"%w")]}
numer_miesiaca_pl=${miesiace[$((10#$(date +"%m") - 1))]}
sformatowana_data="$dzien_tygodnia_pl, $(date +"%d") $numer_miesiaca_pl $(date +"%Y")"

# Kolory i dekoracje
FAT_GREEN='\033[1;32m'
IM_YELLOW='\033[0;33m'
NC='\033[0m' # Brak koloru
UPPER_BORDER="╔═════════════════════════════════[tahio team@IRCnet /join #pato]"
LOWER_BORDER="╚═════════════════════════════════[made with <3 by kofany & yooz]"
SIDE_BORDER="║"

# Informacje o systemie
up=$(uptime -p)
hostname=$(hostname)
users=$(who | wc -l)
load_average=$(cat /proc/loadavg | awk '{print $1" "$2" "$3}')
HEADER_FORMAT="${IM_YELLOW}${SIDE_BORDER}${NC} %-15s %-9s %-6s %-10s %-4s %-20s\n"
HEADER=("System plików" "Rozmiar" "Użyte" "  Dostępne" "  Uż%" " Punkt montowania")

# Polecenie df do wyświetlenia informacji o użyciu dysków
# Wypisanie informacji MOTD
echo -e "${IM_YELLOW}${UPPER_BORDER}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Witaj${IM_YELLOW} ${USER}${FAT_GREEN}, na serwerze${IM_YELLOW} ${hostname}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Dzisiaj jest: ${IM_YELLOW}${sformatowana_data}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Serwer pracuje: ${IM_YELLOW}${up}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Zalogowanych użytkowników: ${IM_YELLOW}${users}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Średnie obciążenie systemu: ${IM_YELLOW}${load_average}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Wpisz '${IM_YELLOW}pomoc${NC}'${FAT_GREEN} aby uzyskać listę dostępnych poleceń.${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Aktualne użycie dysków:${NC}"
printf "$HEADER_FORMAT" "${HEADER[@]}"
df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk -v border="" -v color="$FAT_GREEN" -v fmt="$HEADER_FORMAT" 'NR>1 {printf border fmt, $1, $2, $3, $4, $5, $6}'
echo -e "${IM_YELLOW}${LOWER_BORDER}${NC}"
#pomoc
#dyski

EOF
cat <<'EOF' >> /bin/v6it
#!/bin/bash
###############################################
##  Tahio Syndykat Server Scripts            ##
##  (c) Kofany - Made with ❤ using ChatGPT   ##
###############################################

# Kolory i dekoracje
FAT_GREEN='\033[1;32m'
IM_YELLOW='\033[1;33m'
NC='\033[0m' # Brak koloru
UPPER_BORDER="╔═════════════════════════════════[tahio team@IRCnet /join #pato]"
LOWER_BORDER="╚═════════════════════════════════[made with <3 by kofany & yooz]"
SIDE_BORDER="║"


# Polecenie do wydobycia adresów IPv6
cmd_output=$(ip -6 addr show | grep 'inet6 ' | awk '{print $2}' | cut -d/ -f1 | grep -vE '^::1|^fe80.*|^fd.*|^fc.*')

# Wydobycie dwóch pierwszych adresów z każdej klasy /48
echo -e "${IM_YELLOW}${UPPER_BORDER}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Adresy do użycia z irc6.tophost.it:${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC}"
echo "$cmd_output" | awk -F ':' '{print $1":"$2":"$3}' | sort | uniq -c | \
while read count prefix; do
    if [[ $count -ge 2 ]]; then
        echo "$cmd_output" | grep "^$prefix" | head -n 2 | awk -v prefix="$prefix" -v border="${IM_YELLOW}${SIDE_BORDER}${NC} " -v color="${FAT_GREEN}" '{print border " " color $0 " " }'
    fi
done
echo -e "${IM_YELLOW}${LOWER_BORDER}${NC}"
EOF
chmod +x /bin/v6it
cat <<'EOF' >> /bin/pomoc
#!/bin/bash
###############################################
##  Tahio.syndykat User Management Script    ##
##  (c) kofany - enhanced with ChatGPT       ##
###############################################

# Kolory i dekoracje
FAT_GREEN='\033[1;32m'
IM_YELLOW='\033[1;33m'
NC='\033[0m' # Brak koloru
UPPER_BORDER="╔═════════════════════════════════[tahio team@IRcnet /join #pato]"
LOWER_BORDER="╚═════════════════════════════════[made with <3 by kofany & yooz]"
SIDE_BORDER="║"

PRM="${IM_YELLOW}➜${NC} "

# Funkcja wyświetlająca komendy dla roota
display_root_commands() {
    echo -e "${IM_YELLOW}${UPPER_BORDER}${NC}"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Lista dostępnych komend dla administratora:${NC}"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}add${NC} - Dodaje użytkownika (zamiast adduser)"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}addconn${NC} - Zmienia limit połączeń do IRC dla użytkownika"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}addlimit${NC} - Zmienia limit połączeń do IRC dla użytkownika"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}block${NC} - Blokuje konto użytkownika"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}blocked${NC} - Wyświetla zablokowanych użytkowników"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}blocklist${NC} - Wyświetla zablokowanych użytkowników"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}ddos${NC} - Wyświetla, czy aktualnie ktoś atakuje serwer"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}del${NC} - Usuwa konto użytkownika"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}fw${NC} - Otwiera plik firewall (nie ruszać lepiej)"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}fwfree${NC} - Usuwa firewall (nie ruszać lepiej)"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}get-egg${NC} - Eggdrop"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}get-psotnic${NC} - Psotnic"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}get-znc${NC} - ZNC"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}ile${NC} - Wyświetla wszystkie aktywne połączenia do IRC na serwerze"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}rebind${NC} - Restartuje BIND (dla was nie ważne)"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}udel${NC} - To samo co 'del'"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}unban${NC} - Odbanowuje użytkownika zbanowanego przez Fail2Ban"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}unblock${NC} - Zdejmuje blokadę konta użytkownika"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}vhosts${NC} - Pokazuje VHosty"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}knb${NC} - KNB"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}v6it${NC} - Wyświetla po 2 IP z każdej klasy /48 (dla irc6.tophost.it)"
    echo -e "${IM_YELLOW}${LOWER_BORDER}${NC}"
}

# Funkcja wyświetlająca komendy dla zwykłego użytkownika
display_commands() {
    echo -e "${IM_YELLOW}${UPPER_BORDER}${NC}"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Lista dostępnych komend dla użytkownika:${NC}"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}get-egg${NC} - Eggdrop"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}get-psotnic${NC} - Psotnic"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}get-znc${NC} - ZNC"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}vhosts${NC} - Pokazuje VHosty"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}knb${NC} - KNB"
    echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}v6it${NC} - Wyświetla po 2 IP z każdej klasy /48 (dla irc6.tophost.it)"
    echo -e "${IM_YELLOW}${LOWER_BORDER}${NC}"
}

# Wywołanie funkcji w zależności od uprawnień użytkownika
if [ "$(id -u)" -ne 0 ]; then
  display_commands
else
  display_root_commands
fi
EOF
chmod +x /bin/pomoc

    rm_file "/etc/hostname"
    echo -e "LC_TIME=\"C\"" >> /etc/default/locale
    echo -e "${SERVER_NAME}" >> /etc/hostname
    hostname ${SERVER_NAME} < /dev/null > /dev/null
    rm_file "/etc/profile"
    rm_file "/etc/bash.bashrc"

cat <<'EOF' >> /etc/profile
#/etc/profile: system-wide .profile file for the Bourne shell (sh(1))
# and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

if [ "`id -u`" -eq 0 ]; then
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
else
  PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games"
fi
export PATH


if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/motd.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

if [ "${PS1-}" ]; then
  if [ "${BASH-}" ] && [ "$BASH" != "/bin/sh" ]; then
    # The file bash.bashrc already sets the default PS1.
    # PS1='\h:\w\$ '
    if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc
    fi
    # Dodajemy nowoczesny i kolorystyczny prompt dla systemu Debian

    RESET="\[\033[0m\]"
    RED="\[\033[0;31m\]"
    GREEN="\[\033[0;32m\]"
    YELLOW="\[\033[0;33m\]"
    BLUE="\[\033[0;34m\]"
    MAGENTA="\[\033[0;35m\]"
    CYAN="\[\033[0;36m\]"
    DARK_GRAY="\[\033[0;37m\]"
    LIGHT_BLUE="\[\033[1;34m\]"
    LIGHT_GREEN="\[\033[1;32m\]"
    LIGHT_CYAN="\[\033[1;36m\]"
    LIGHT_RED="\[\033[1;31m\]"
    WHITE="\[\033[0;37m\]"

    # Informacje o systemie
    debian_chroot() {
      if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
        debian_chroot=$(cat /etc/debian_chroot)
      fi
      if [ -n "$debian_chroot" ]; then
        printf "(%s)" "$debian_chroot"
      fi
    }

    # Prompt
PS1="${DARK_GRAY}\t ${LIGHT_CYAN}➜ ${RED}\u${WHITE}@${YELLOW}\h${RESET}${LIGHT_CYAN} ➜ ${LIGHT_BLUE}Ścieżka: ${MAGENTA}\w\$(debian_chroot)${RESET}\n${LIGHT_CYAN}➜${WHITE} "
  else
    if [ "`id -u`" -eq 0 ]; then
      PS1='# '
    else
      PS1='$ '
    fi
  fi
fi
EOF
cat <<'EOF' >> /etc/bash.bashrc
# /etc/bash.bashrc: system-wide .bashrc file for interactive bash(1) shells.
[ -z "$PS1" ] && return
shopt -s checkwinsize
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then

    RESET="\[\033[0m\]"
    RED="\[\033[0;31m\]"
    GREEN="\[\033[0;32m\]"
    YELLOW="\[\033[0;33m\]"
    BLUE="\[\033[0;34m\]"
    MAGENTA="\[\033[0;35m\]"
    CYAN="\[\033[0;36m\]"
    DARK_GRAY="\[\033[0;37m\]"
    LIGHT_BLUE="\[\033[1;34m\]"
    LIGHT_GREEN="\[\033[1;32m\]"
    LIGHT_CYAN="\[\033[1;36m\]"
    LIGHT_RED="\[\033[1;31m\]"
    WHITE="\[\033[0;37m\]"

        debian_chroot() {
            if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
                debian_chroot=$(cat /etc/debian_chroot)
            fi
            if [ -n "$debian_chroot" ]; then
                printf "(%s)" "$debian_chroot"
            fi
        }

PS1="${DARK_GRAY}\t ${LIGHT_CYAN}➜ ${RED}\u${WHITE}@${YELLOW}\h${RESET}${LIGHT_CYAN} ➜ ${LIGHT_BLUE}Ścieżka: ${MAGENTA}\w\$(debian_chroot)${RESET}\n${LIGHT_CYAN}➜${WHITE} "

    else
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    fi
fi
unset color_prompt force_color_prompt

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'


if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export LC_ALL=
export LC_TIME=C
EOF
cp /etc/bash.bashrc /etc/skel/.bashrc
touch /etc/skel/.hushlogin
}

do_sshd_f2b()
{
# Fail2ban
# Zdefiniuj swoje zaufane adresy IP oddzielone spacjami
trusted_ips="127.0.0.1/8"

# Zdefiniuj port SSH
ssh_port="$SSH_PORT"

# Zdefiniuj maksymalną ilość prób łączenia
max_attempts="4"

# Skopiuj jail.conf do jail.local, jeśli jail.local nie istnieje
rm_file "/etc/fail2ban/jail.local"
if [ ! -f /etc/fail2ban/jail.local ]; then
     cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
fi

# Dodaj sekcję DEFAULT z określonymi ignoreip na początek pliku jail.local
echo -e "[DEFAULT]\nignoreip = $trusted_ips\n$(cat /etc/fail2ban/jail.local)" > /etc/fail2ban/jail.local
rm_file "/etc/fail2ban/jail.d/jail-debian.local"
# Utwórz plik jail-debian.local, jeśli nie istnieje
if [ ! -f /etc/fail2ban/jail.d/jail-debian.local ]; then
     touch /etc/fail2ban/jail.d/jail-debian.local
fi

# Dodaj sekcję [sshd] z ustawieniami maxretry i port do pliku jail-debian.local
echo -e "[sshd]\nmaxretry = $max_attempts\nport = $ssh_port" > /etc/fail2ban/jail.d/jail-debian.local

# Zrestartuj Fail2Ban, aby zastosować nowe ustawienia
sudo systemctl restart fail2ban

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
    # Dual-stack - słuchaj na obu
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
EOF
rm_file "/etc/resolv.conf"
cat <<'EOF' >> /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 9.9.9.9
nameserver 2001:4860:4860::8888
nameserver 2606:4700:4700::1111
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
# Ustawienie adresu URL i nazwy pliku
url="http://ftp.eggheads.org/pub/eggdrop/source/1.8/eggdrop-1.8.4.tar.gz"
file_name="eggdrop-1.8.4.tar.gz"
correct_sha256="79644eb27a5568934422fa194ce3ec21cfb9a71f02069d39813e85d99cdebf9e"

# Pobieranie pliku
wget -q ${url} -O ${file_name} >/dev/null 2>&1

# Sprawdzanie poprawności pobranego pliku
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

git clone ${GITHUB_URL}/kofany/psotnic >/dev/null 2>&1
if [ -d "/root/psotnic" ]; then
    pushd /root/psotnic/ >> /dev/null
    ./configure >/dev/null 2>&1
    pushd /root/psotnic/ >> /dev/null
    make dynamic >/dev/null 2>&1
    mv /root/psotnic/bin/psotnic /bin/psotnic >/dev/null 2>&1
    chmod +x /bin/psotnic >/dev/null 2>&1
    rm -rf /root/psotni* >/dev/null 2>&1
fi
}


do_knb()
{
pushd /root/ >> /dev/null
git clone ${GITHUB_URL}/kofany/knb >/dev/null 2>&1
if [ -d "/root/knb" ]; then
    pushd /root/knb/src/ >> /dev/null
    chmod +x configure
    ./configure --without-validator >/dev/null 2>&1
    make dynamic >/dev/null 2>&1
    mv /root/knb/knb-0.2.5-linux /bin/knb >/dev/null 2>&1
    chmod +x /bin/knb >/dev/null 2>&1
    rm -rf /root/knb* >/dev/null 2>&1
fi
}


do_update()
{
pushd /root/ >> /dev/null
# Stałe
URL="${GITHUB_URL}/kofany/tahioN/raw/main/update.tar.gz"
DOWNLOAD_FILE="update.tar.gz"
UPDATE_DIR="update"

wget -q "${URL}" -O "${DOWNLOAD_FILE}" >/dev/null 2>&1

if [ $? -eq 0 ]; then
    tar -xzf "${DOWNLOAD_FILE}" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        # Wejście do folderu update
        pushd /root/${UPDATE_DIR} >/dev/null 2>&1
        # Pobranie listy plików
        FILES_LIST=$(ls)

        # Przenoszenie plików
        for FILE in ${FILES_LIST}; do
            if [ -f "/bin/${FILE}" ]; then
                rm -rf "/bin/${FILE}" >/dev/null 2>&1
            fi
            cp "${FILE}" "/bin/${FILE}" >/dev/null 2>&1
            chmod +x "/bin/${FILE}" >/dev/null 2>&1
        done

        rm -rf /root/upda* >/dev/null 2>&1
    fi
fi

}

do_admin()
{
# Funkcja generująca losowe hasło
generate_random_password() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1
}

# Pytanie użytkownika czy chce utworzyć konta
echo -e "\n${yellow}Czy chcesz utworzyć konta użytkowników z uprawnieniami sudo? [t/n]${NC}"
read -r create_accounts

if [[ ! "$create_accounts" =~ ^[tT]$ ]]; then
    tt "${green}Pomijam tworzenie kont administratorów."
    return 0
fi

# Pytanie o nazwy użytkowników
echo -e "\n${yellow}Podaj nazwy użytkowników (oddzielone spacją, np: user1 user2 user3):${NC}"
read -r user_input

# Zamiana inputu na tablicę
IFS=' ' read -ra users <<< "$user_input"

if [ ${#users[@]} -eq 0 ]; then
    tt "${red}Nie podano żadnych nazw użytkowników. Pomijam tworzenie kont."
    return 0
fi

# Deklaracja tablicy asocjacyjnej dla haseł
declare -A user_passwords

# Tworzenie użytkowników
echo -e "\n${green}=== Tworzenie użytkowników ===${NC}\n"

for user in "${users[@]}"; do
    # Walidacja nazwy użytkownika (tylko alfanumeryczne i podkreślnik)
    if ! [[ "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        tt "${red}Nieprawidłowa nazwa użytkownika: ${user}. Pomijam."
        continue
    fi

    if id -u "${user}" >/dev/null 2>&1; then
        tt "${yellow}Użytkownik ${user} już istnieje. Pomijam."
    else
        password=$(generate_random_password)
        # Twórz użytkownika z zsh jako domyślnym shellem
        useradd -m -s /bin/zsh "${user}"
        echo "${user}:${password}" | chpasswd
        user_passwords["${user}"]=${password}

        # Power user setup - Powerlevel10k dla sudo users
        if [ -f /home/${user}/.zshrc ]; then
            # Backup original
            cp /home/${user}/.zshrc /home/${user}/.zshrc.backup

            # Create new .zshrc with p10k instant prompt at the top
            {
                echo '# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.'
                echo 'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then'
                echo '  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"'
                echo 'fi'
                echo ''
                cat /home/${user}/.zshrc.backup
            } > /home/${user}/.zshrc

            # Add p10k to zinit (after zinit source line)
            sed -i '/source.*zinit.zsh/a \\n# Add in Powerlevel10k\nzinit ice depth=1; zinit light romkatv\/powerlevel10k' /home/${user}/.zshrc

            # Add p10k config source at the end
            echo -e "\n# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh.\n[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> /home/${user}/.zshrc

            chown ${user}:${user} /home/${user}/.zshrc
            rm /home/${user}/.zshrc.backup
        fi

        # Copy p10k config
        if [ -f /root/.p10k.zsh ]; then
            cp /root/.p10k.zsh /home/${user}/.p10k.zsh
            chown ${user}:${user} /home/${user}/.p10k.zsh
        fi

        tt "${green}Użytkownik ${user} został utworzony z zsh + Powerlevel10k."
    fi
done

# Dodanie uprawnień sudo
if [ ${#user_passwords[@]} -gt 0 ]; then
    echo -e "\n${green}=== Dodawanie uprawnień sudo ===${NC}\n"

    for user in "${!user_passwords[@]}"; do
        if grep -q -E "^${user}\s" /etc/sudoers; then
            tt "${yellow}Użytkownik ${user} ma już uprawnienia sudo."
        else
            echo -e "${user} ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
            tt "${green}Użytkownik ${user} otrzymał uprawnienia sudo."
        fi
    done

    # Wyświetlenie danych logowania
    external_ip=$(curl -s https://ipinfo.io/ip)

    echo -e "\n${green}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${green}║          DANE LOGOWANIA DO UTWORZONYCH KONT               ║${NC}"
    echo -e "${green}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${green}║${NC} Adres IP serwera: ${cyan}${external_ip}${NC}"
    echo -e "${green}║${NC} Port SSH:         ${cyan}${SSH_PORT}${NC}"
    echo -e "${green}╠════════════════════════════════════════════════════════════╣${NC}"

    for user in "${!user_passwords[@]}"; do
        echo -e "${green}║${NC} Użytkownik: ${yellow}${user}${NC}"
        echo -e "${green}║${NC} Hasło:      ${cyan}${user_passwords["${user}"]}${NC}"
        echo -e "${green}╠════════════════════════════════════════════════════════════╣${NC}"
    done

    echo -e "${green}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "\n${red}WAŻNE: Zapisz te dane w bezpiecznym miejscu!${NC}\n"

else
    tt "${yellow}Nie utworzono żadnych nowych użytkowników."
fi

}



end_of_all() {
tt "${cyan}" "tahioN zakończył konfigurowanie Twojego nowego boxa"
sleep 1.5
tt "${cyan}" "zrób reboot i zaloguj się teraz na nowy port"
sleep 1.5
}

banner

# Inicjalizacja systemu progress bar
init_tasks

# Uruchom instalację z progress barem
clear

# Task 0: IPv6 network detection & GitHub proxy setup
start_task 0
do_ipv6_setup >/dev/null 2>&1
complete_task 0

# Task 1: APT repository synchronization & package matrix
start_task 1
do_apt >/dev/null 2>&1
complete_task 1

# Task 2: Zsh + modern CLI tools deployment
start_task 2
do_zsh_setup >/dev/null 2>&1
complete_task 2

# Task 3: SSH hardening & Fail2Ban protection matrix
start_task 3
do_sshd_f2b >/dev/null 2>&1
complete_task 3

# Task 4: MOTD cyberpunk matrix deployment
start_task 4
do_motd_cyberpunk >/dev/null 2>&1
complete_task 4

# Task 5: BIND9 DNS server configuration
start_task 5
do_bind >/dev/null 2>&1
complete_task 5

# Task 6: Eggdrop bot assembly v1.8.4
start_task 6
do_egg >/dev/null 2>&1
complete_task 6

# Task 7: Psotnic bot deployment sequence
start_task 7
do_post >/dev/null 2>&1
complete_task 7

# Task 8: KNB bot initialization protocol
start_task 8
do_knb >/dev/null 2>&1
complete_task 8

# Task 9: Binary update & system finalization
start_task 9
do_update >/dev/null 2>&1
complete_task 9

# Finalne wyświetlenie progress bara (100%)
sleep 1
tput cnorm
clear

# Interaktywne tworzenie kont administratorów (po zakończeniu instalacji)
do_admin

end_of_all
sleep 3
