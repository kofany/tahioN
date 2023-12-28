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

####################################### Spinner
lines_limit=16
buffer=()

spinner()
{
    local delay=0.02
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local line
    local end_marker="END_SPIN"
    local spinner_topic="tahioN:"
    local previous_line_length=0

    tput civis  # Ukryj kursor
    while true; do
        for ((i=0; i<${#spinstr}; i++)); do
            local temp=${spinstr:$i:1}
            tput cup 0 0 # Przesuń kursor do górnej linii
            printf "${CYAN}[$YELLOW$temp$CYAN]  $YELLOW$line$RESET\r"
            sleep $delay
            if read -t 0.1 -r line; then
                if [[ $line == $end_marker ]]; then
                    break 2
                fi

                local padding_length=$((previous_line_length - ${#line} + 5))
                local padding=$(printf "%${padding_length}s" " ")

                # Dodaj odpowiednią ilość spacji do końca każdej linii
                line="${line}${padding}"
                buffer=("$line" "${buffer[@]}")
                previous_line_length=${#line}

                if [[ ${#buffer[@]} -gt $lines_limit ]]; then
                    buffer=("${buffer[@]:0:${lines_limit}}")
                fi

                # Wyczyść poprzednie linie
                for ((j=1; j<=$lines_limit; j++)); do
                    tput cup $j 0
                    tput el # Wyczyść linię
                done

                # Drukuj nowe linie
                local idx=1
                for entry in "${buffer[@]}"; do
                    tput cup $idx 0
                    echo "$entry"
                    ((idx++))
                done

                # Jeśli linia zawiera spinner_topic, wyświetl całą linię jako spinera
                if [[ $line == *$spinner_topic* ]]; then
                    line=$line
                else
                    line=""
                fi
            fi
        done
    done
    tput cup 0 0
    tput el
    tput cnorm  # Pokaż kursor
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
tt "tahioN:${cyan} Usuwam plik: ${cyan}${*}"
rm -rf ${*}
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

####################################### Wykonywanie instalacji pakietów przez APT

do_apt()
{
    tt "tahioN:${cyan} Aktualizuje APT\n"

    DEBIAN_FRONTEND=noninteractive apt-get -y update >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y upgrade >/dev/null 2>&1

    tt "tahioN:${cyan} Instaluje potrzebne pakiety\n"
    DEBIAN_FRONTEND=noninteractive apt-get -y install  sudo telnet wget >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install  irssi screen iptables>/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install  znc oidentd curl jq >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install  tcl tcl-dev openssl libssl-dev >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install  gcc make net-tools bind9 >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install  fail2ban dnsutils lsof >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install  dialog mc htop wget >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install  systemd figlet git >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y install  php-cli curl apache2 >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y remove nftables >/dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt-get -y remove resolvconf >/dev/null 2>&1    
    
}
####################################### motd i baner

do_motd()
{
    tt "tahioN:${cyan} Aktualizuję motd i baner"
    rm_file "/etc/motd"
    rm_file "/etc/banner"
    rm_file "/etc/profile.d/motd.sh"
    tt "tahioN:${cyan} Kopiuje nowy banner"

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

tt "tahioN:${cyan} Kopiuję nowe motd"


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

# Wypisanie informacji MOTD
echo -e "${IM_YELLOW}${UPPER_BORDER}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Witaj${IM_YELLOW} ${USER}${FAT_GREEN}, na serwerze${IM_YELLOW} ${hostname}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Dzisiaj jest: ${IM_YELLOW}${sformatowana_data}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Serwer pracuje: ${IM_YELLOW}${up}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Zalogowanych użytkowników: ${IM_YELLOW}${users}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Średnie obciążenie systemu: ${IM_YELLOW}${load_average}${NC}"
echo -e "${IM_YELLOW}${SIDE_BORDER}${NC} ${FAT_GREEN}Wpisz '${IM_YELLOW}pomoc${NC}'${FAT_GREEN} aby uzyskać listę dostępnych poleceń.${NC}"
echo -e "${IM_YELLOW}${LOWER_BORDER}${NC}"
#pomoc
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

    tt "tahioN:${cyan} Banner i motd gotowe"
    sleep 1
    tt "tahioN:${cyan} Ustawiam hostname i LC_TIME"
    sleep 1
    rm_file "/etc/hostname"
    echo -e "LC_TIME=\"C\"" >> /etc/default/locale
    echo -e "${SERVER_NAME}" >> /etc/hostname
    hostname ${SERVER_NAME} < /dev/null > /dev/null
    tt "tahioN:${cyan} Ustawiam promt"
    sleep 1
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
tt "tahioN:${cyan} Ustawiam fail2ban"
sleep 1.5
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

tt "tahioN:${cyan} Zaktualizowano jail.local, jail-debian.local i zrestartowano Fail2Ban."
sleep 1.5
# sshd_config 

tt "tahioN:${cyan} Podmieniam plik sshd_config i ssh.txt"
sleep 1.5
rm_file "/etc/ssh/sshd_config"
rm_file "/var/log/ssh.txt"
touch /var/log/ssh.txt
echo -e "${SSH_PORT}" >> /var/log/ssh.txt
echo -e "Port ${SSH_PORT}" >> /etc/ssh/sshd_config
cat <<'EOF' >> /etc/ssh/sshd_config
ListenAddress 0.0.0.0
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
tt "tahioN:${cyan} sshd_config gotowy"
sleep 1.5
rm_file "/etc/resolv.conf"
cat <<'EOF' >> /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 9.9.9.9
nameserver 2001:4860:4860::8888
nameserver 2606:4700:4700::1111
EOF
sleep 1.5
}

do_bind()
{
tt "tahioN:${cyan} Kopiuje przykładową konfigurację bind dla ipv6"
sleep 1.5
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
tt "tahioN:${cyan} Pobieram eggdrop 1.8.4"
sleep 1.5
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
    tt "tahioN:${cyan} Plik został pobrany prawidłowo."
else
    tt "tahioN:${cyan} Błąd: suma kontrolna SHA256 nie zgadza się."
    tt "tahioN:${cyan} Oczekiwana: ${correct_sha256}"
    tt "tahioN:${cyan} Otrzymana: ${downloaded_sha256}"
    rm_file ${file_name} >/dev/null 2>&1
    exit 1
fi

    pushd /root/ >/dev/null 2>&1
    tar -zxf /root/eggdrop-1.8.4.tar.gz >/dev/null 2>&1
    pushd /root/eggdrop-1.8.4 >/dev/null 2>&1
    tt "tahioN:${cyan} Instalacja eggdrop: ./configure "
    ./configure --enable-ipv6 >/dev/null 2>&1
    tt "tahioN:${cyan} Instalacja eggdrop: make config"
    make config >/dev/null 2>&1
    tt "tahioN:${cyan} Instalacja eggdrop: make"
    make >/dev/null 2>&1
    tt "tahioN:${cyan} Instalacja eggdrop: make install"
    make install >/dev/null 2>&1
    pushd /root/ >/dev/null 2>&1
    tt "tahioN:${cyan} Instalacja eggdrop: kopiuje przykładowy eggdrop.conf"
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
tt "tahioN:${cyan} Eggdrop gotowy" >/dev/null 2>&1
sleep 1.5
}

do_post()
{
tt "tahioN:${cyan} Pobieram paczkę psotnic" 
sleep 1.5
pushd /root/ >> /dev/null

git clone https://github.com/kofany/psotnic >/dev/null 2>&1
if [ -d "/root/psotnic" ]; then
    tt "tahioN:${cyan} Pobrano repo psotnic - rozpoczynam instalację"
    sleep 1.5
    pushd /root/psotnic/ >> /dev/null
    tt "tahioN:${cyan} Instalacja psotnic: ./configure"
    ./configure >/dev/null 2>&1
    pushd /root/psotnic/ >> /dev/null
    tt "tahioN:${cyan} Instalacja psotnic: make dynamic"
    make dynamic >/dev/null 2>&1
    tt "tahioN:${cyan} Instalacja zakończona, przenoszę pliki"
    sleep 0.5
    mv /root/psotnic/bin/psotnic /bin/psotnic >/dev/null 2>&1
    chmod +x /bin/psotnic >/dev/null 2>&1
    rm -rf /root/psotni* >/dev/null 2>&1
else
    tt "tahioN:${cyan} Problem z pobraniem repo psotnic"
fi
}

do_knb()
{
tt "tahioN:${cyan} Pobieram paczkę knb" 
sleep 1.5
pushd /root/ >> /dev/null
git clone https://github.com/kofany/knb >/dev/null 2>&1
if [ -d "/root/knb" ]; then
    tt "tahioN:${cyan} Pobrano z github knb"
    sleep 1.5
    pushd /root/knb/src/ >> /dev/null
    tt "tahioN:${cyan} Instalacja knb: ./configure"
    chmod +x configure
    ./configure --without-validator >/dev/null 2>&1
    tt "tahioN:${cyan} Instalacja knb: make dynamic"
    make dynamic >/dev/null 2>&1
    tt "tahioN:${cyan} Instalacja zakończona, przenoszę pliki"
    sleep 0.5
    mv /root/knb/knb-0.2.5-linux /bin/knb >/dev/null 2>&1
    chmod +x /bin/knb >/dev/null 2>&1
    rm -rf /root/knb* >/dev/null 2>&1
else
    tt "tahioN:${cyan} Problem z pobraniem psotnic.tar.gz"
fi
}

do_fw()
{
    
tt "tahioN:${cyan} Rozpoczynam tworzenie pliku firewall"
sleep 1.5

# Stwórz plik nftables.conf z konfiguracją
rm_file /etc/nftables.conf >/dev/null 2>&1

tt "tahioN:${cyan} Tworzę plik odpowiedzialny za limitowanie połączeń do irc per user."
rm_file "/etc/limit_irc.sh" >/dev/null 2>&1
rm_file "/etc/limit_irc.db" >/dev/null 2>&1
echo -e "#!/bin/bash" >> /etc/limit_irc.sh
echo -e "SSHPORT=\"${SSH_PORT}\"" >> /etc/limit_irc.sh

cat <<'EOF' >> /etc/limit_irc.sh

LIMIT_FILE="/etc/limit_irc.db"
LIMIT_FILE_COPY="/etc/limit_irc.db.copy"
IRC_PORTS="6660:7001" # Zaktualizowany zakres portów IRC do limitowania

# Tworzenie kopii pliku limit_irc.db, jeśli jeszcze nie istnieje
if [ ! -f "$LIMIT_FILE_COPY" ]; then
    cp "$LIMIT_FILE" "$LIMIT_FILE_COPY"
fi

# Firewall
firewall() {
BIN="/sbin/iptables"
BIN6="/sbin/ip6tables"

$BIN -F
$BIN -X
$BIN -F INPUT
$BIN -F OUTPUT
$BIN -F FORWARD
$BIN -t nat -F
$BIN -t nat -X

$BIN -P INPUT ACCEPT

$BIN6 -F
$BIN6 -X
$BIN6 -Z

$BIN6 -P INPUT       ACCEPT
$BIN6 -P OUTPUT      ACCEPT
$BIN6 -P FORWARD     ACCEPT
$BIN6 -F
$BIN6 -I INPUT -p icmpv6 -j ACCEPT

$BIN -P INPUT ACCEPT
$BIN6 -P INPUT ACCEPT

# ICMP PING OFF
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all

$BIN -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$BIN6 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
$BIN -A INPUT -p tcp -s 127.0.0.1 -j ACCEPT
$BIN -A INPUT -p udp -s 127.0.0.1 -j ACCEPT

$BIN -A INPUT -p tcp --dport $SSHPORT -m state --state NEW -j ACCEPT
$BIN6 -A INPUT -p tcp --dport $SSHPORT -m state --state NEW -j ACCEPT

$BIN -A INPUT -p tcp --dport 1000:5000 -m state --state NEW -j ACCEPT
$BIN6 -A INPUT -p tcp --dport 1000:5000 -m state --state NEW -j ACCEPT

$BIN -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
$BIN6 -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT

$BIN -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT
$BIN6 -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT

$BIN -I INPUT -p udp --dport 443 -j ACCEPT
$BIN6 -I INPUT -p udp --dport 443 -j ACCEPT

$BIN -A INPUT -p tcp --dport 113 -m state --state NEW -j ACCEPT
$BIN6 -A INPUT -p tcp --dport 113 -m state --state NEW -j ACCEPT

$BIN -I INPUT -p udp --dport 53 -j ACCEPT
$BIN6 -I INPUT -p udp --dport 53 -j ACCEPT

$BIN -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
$BIN -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

# Additional security enhancements
$BIN -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
$BIN6 -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT

$BIN -A INPUT -p tcp -j REJECT --reject-with tcp-reset
$BIN -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

$BIN6 -A INPUT -p tcp -j REJECT --reject-with tcp-reset
$BIN6 -A INPUT -p udp -j REJECT --reject-with icmp6-port-unreachable

$BIN -A INPUT -p tcp -j DROP
$BIN -A INPUT -p udp -j DROP

$BIN6 -A INPUT -p tcp -j DROP
$BIN6 -A INPUT -p udp -j DROP
}

# Funkcja aktualizująca reguły iptables
update_iptables_rules() {
    # Czyszczenie starych reguł

    while IFS=" " read -r user limit_ipv4 limit_ipv6; do
        if [ -n "$user" ]; then
            uid=$(id -u "$user")

            # Dodawanie reguł dla IPv4
            iptables -A OUTPUT -p tcp -m owner --uid-owner $uid -m connlimit --connlimit-above $limit_ipv4 -m multiport --dport $IRC_PORTS -m conntrack --ctstate NEW -j REJECT
            ip6tables -A OUTPUT -p tcp -m owner --uid-owner $uid -m connlimit --connlimit-above $limit_ipv6 -m multiport --dport $IRC_PORTS -m conntrack --ctstate NEW -j REJECT
        fi
    done < $LIMIT_FILE
}

firewall
update_iptables_rules

while true; do
    # Porównywanie oryginalnego pliku z kopią
    if ! cmp -s "$LIMIT_FILE" "$LIMIT_FILE_COPY"; then
        firewall
        update_iptables_rules
        cp "$LIMIT_FILE" "$LIMIT_FILE_COPY"
    fi
    sleep 60
done

EOF
chmod +x /etc/limit_irc.sh >/dev/null 2>&1
tt "tahioN:${cyan} Tworzę plik zawierający limity irc per user (/etc/limit_irc.db)"
if [ ! -f /etc/limit_irc.db ]; then
touch /etc/limit_irc.db >/dev/null 2>&1
if [ ! -s /etc/limit_irc.db ]; then
  echo -e "root 99 99" >> /etc/limit_irc.db
fi
fi
tt "Tworzę usługę systemową dla limitowania połączeń"

SERVICE_NAME="irc_limit"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
SCRIPT_PATH="/etc/limit_irc.sh"

# Tworzenie pliku usługi systemd
cat > "${SERVICE_FILE}" << EOF
[Unit]
Description=IRC Connection Limit Daemon
After=network.target

[Service]
Type=simple
User=root
ExecStart=${SCRIPT_PATH}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Nadawanie uprawnień wykonywania dla skryptu limitującego
chmod +x ${SCRIPT_PATH} 

# Przeładowanie konfiguracji systemd
systemctl daemon-reload

# Włączanie usługi, aby uruchamiała się podczas startu systemu
systemctl enable ${SERVICE_NAME}

# Uruchamianie usługi
systemctl start ${SERVICE_NAME}

tt "Usługa ${SERVICE_NAME} została utworzona, włączona i uruchomiona."

}

do_update()
{
#!/bin/bash

tt "tahioN:${cyan} Pobieram plik aktualizujący pliki binarne"
pushd /root/ >> /dev/null
# Stałe
URL="https://github.com/kofany/tahioN/raw/main/update.tar.gz" # Zmień na prawidłowy URL
DOWNLOAD_FILE="update.tar.gz"
UPDATE_DIR="update"

tt "tahioN:${cyan} Pobieram plik z binarkami do aktualizacji"
wget -q "${URL}" -O "${DOWNLOAD_FILE}" >/dev/null 2>&1

if [ $? -eq 0 ]; then
    tt "tahioN:${cyan} Pobrano plik"
else
    tt "tahioN:${cyan} Błąd pobierania pliku"
    exit 1
fi

sleep 1.5

tt "tahioN:${cyan} Rozpakowuję pobrany plik"
tar -xzf "${DOWNLOAD_FILE}" >/dev/null 2>&1

if [ $? -eq 0 ]; then
    tt "tahioN:${cyan} Rozpakowano plik"
else
    tt "tahioN:${cyan} Błąd rozpakowywania pliku"
    exit 1
fi

# Wejście do folderu update
pushd /root/${UPDATE_DIR} >/dev/null 2>&1
# Pobranie listy plików
FILES_LIST=$(ls)

# Przenoszenie plików
tt "tahioN:${cyan} Instalowanie plików binarnych"
for FILE in ${FILES_LIST}; do
    if [ -f "/bin/${FILE}" ]; then
        rm -rf "/bin/${FILE}" >/dev/null 2>&1
        tt "Usuwam stary plik ${cyan}/bin/${FILE}"
        sleep 0.5
    fi
    tt "Kopiuję nowy plik ${cyan}${FILE}"
    cp "${FILE}" "/bin/${FILE}" >/dev/null 2>&1
    chmod +x "/bin/${FILE}" >/dev/null 2>&1
    sleep 0.5
done

rm -rf /root/upda* >/dev/null 2>&1
tt "tahioN:${cyan} Pliki binarne zainstalowane"
sleep 1.5

}


end_of_all() {
tt "${cyan}" "tahioN zakończył konfigurowanie Twojego nowego boxa"
sleep 1.5
tt "${cyan}" "zrób reboot i zaloguj się teraz na nowy port"
sleep 1.5
}

banner
pipe_name="mypipe"

if [[ -e $pipe_name ]]; then
    rm $pipe_name
fi
mkfifo $pipe_name
{
clear
echo -e ""
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
tt "tahioN:${cyan} Tworzę spinner ...."
sleep 0.5
sleep 1
tt "tahioN:${cyan} Aktualizację apt i instaluję potrzebne pakiety (w tle, czekaj cierpliwe)"
do_apt 
tt "tahioN:${cyan} motd i promt"
do_motd 
tt "tahioN:${cyan} sshd_config i fail2ban"
do_sshd_f2b 
tt "tahioN:${cyan} bind9"
do_bind 
tt "tahioN:${cyan} Instalacja eggdrop"
do_egg 
tt "tahioN:${cyan} Instalacja psotnic"
do_post
tt "tahioN:${cyan} Instalacja knb"
do_knb
tt "tahioN:${cyan} Instalacja firewall"
do_fw 
tt "tahioN:${cyan} plików binarnych (w tle, czekaj cierpliwie)"
do_update 
tt "tahioN:${cyan} zadania zakończone, za 5 sekund zamykam spinner"
sleep 5
echo ""
echo "END_SPIN"
} > $pipe_name &
spinner < $pipe_name
rm $pipe_name
clear
end_of_all
rm_file "/etc/nftables.conf"
sleep 5
