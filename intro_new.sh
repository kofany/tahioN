#!/usr/bin/env bash
set -eu

# ============================================================================
# tahioN Intro - Matrix Rain (5s) + Fade In Logo + Matrix Messages
# Usage: intro_new.sh <SSH_PORT> <SERVER_NAME>
# ============================================================================

SSH_PORT="${1:-2222}"
SERVER_NAME="${2:-unknown}"

init_term() {
    printf '\e[?1049h\e[2J\e[?25l'
    IFS='[;' read -p $'\e[999;999H\e[6n' -rd R -s _ LINES COLUMNS
}

deinit_term() {
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
    color=${colors[RANDOM%${#colors[@]}]}

    for ((i=dropStart; i <= LINES+dropLen; i++)); do
        symbol=${1:RANDOM%${#1}:1}
        (( dropColDim )) || print_to "$symbol" $i $dropCol "$color" 1
        (( i > dropStart )) && print_to "$symbol" $((i-1)) $dropCol "$color"
        (( i > dropLen )) && printf '\e[%d;%dH\e[m ' $((i-dropLen)) $dropCol
        sleep 0.$dropSpeed
    done
}

# ASCII Art Logo
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

    # Znajdź najdłuższą linię
    for line in "${logo[@]}"; do
        (( ${#line} > max_col )) && max_col=${#line}
    done

    local start_col=$(( (COLUMNS - max_col) / 2 ))

    # Fade in przez 5 odcieni
    local fade_colors=(
        "40;40;40"      # Bardzo ciemny
        "80;80;80"      # Ciemny
        "120;120;120"   # Średni
        "180;180;180"   # Jasny
        "255;255;255"   # Biały
    )

    for color in "${fade_colors[@]}"; do
        local line_num=$start_line
        for line in "${logo[@]}"; do
            printf '\e[%d;%dH\e[38;2;%sm%s\e[m' "$line_num" "$start_col" "$color" "$line"
            ((line_num++))
        done
        sleep 0.2
    done

    # Kolorowa wersja finalna
    printf '\e[2J'
    line_num=$start_line
    for line in "${logo[@]}"; do
        # Gradient zielony-cyjan dla cyberpunk vibe
        local r=$((50 + RANDOM % 50))
        local g=$((200 + RANDOM % 55))
        local b=$((100 + RANDOM % 100))
        printf '\e[%d;%dH\e[38;2;%d;%d;%sm%s\e[m' "$line_num" "$start_col" "$r" "$g" "$b" "$line"
        ((line_num++))
    done

    sleep 2
}

# Main
trap 'kill 0 2>/dev/null; deinit_term; exit' INT TERM
trap init_term WINCH

export LC_ALL=en_US.UTF-8

# Katakana + inne znaki
symbols='カキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン0123456789'
colors=('102;255;102' '51;255;51' '0;255;0')

init_term
stty -echo

# Matrix rain przez 5 sekund
rain_pids=()
end_time=$((SECONDS + 5))

while ((SECONDS < end_time)); do
    rain "$symbols" &
    rain_pids+=($!)
    sleep 0.1
done

# Kill wszystkie rain processes i poczekaj chwilę
for pid in "${rain_pids[@]}"; do
    kill "$pid" 2>/dev/null || true
done
sleep 0.5

# Wyczyść ekran i pokaż fade in logo
printf '\e[2J'
fade_in_logo

# Matrix-style typewriter effect
typewriter() {
    local text="$1"
    local color="$2"
    local delay="${3:-0.03}"
    local newline="${4:-yes}"

    for ((i=0; i<${#text}; i++)); do
        printf "\e[38;2;%sm%s\e[m" "$color" "${text:$i:1}"
        sleep "$delay"
    done
    [[ "$newline" == "yes" ]] && echo
    # Force flush output buffer
    printf ""
}

# Matrix messages
printf '\e[2J'
start_line=$(( LINES / 2 - 8 ))

# Matrix colors
green="0;255;0"
cyan="0;255;255"
yellow="255;255;0"
red="255;0;0"
white="255;255;255"

printf '\e[%d;1H' "$start_line"
typewriter "Wake up, Neo..." "$green" 0.05
sleep 0.3
((start_line++))
printf '\e[%d;1H' "$start_line"
typewriter "The Matrix has you..." "$cyan" 0.04
sleep 0.3
((start_line++))
printf '\e[%d;1H' "$start_line"
typewriter "Follow the white rabbit 🐇" "$green" 0.03
sleep 0.5
((start_line++))
printf '\e[%d;1H' "$start_line"
typewriter "Knock, knock, Neo." "$green" 0.03
sleep 0.3
((start_line+=2))
printf '\e[%d;1H' "$start_line"
typewriter "Port ${SSH_PORT} at ${SERVER_NAME}" "$cyan" 0.03
sleep 0.5
((start_line+=2))
printf '\e[%d;1H' "$start_line"
typewriter "WARNING: This is your last chance." "$yellow" 0.03
sleep 0.3
((start_line++))
printf '\e[%d;1H' "$start_line"
typewriter "After this, there is no turning back." "$yellow" 0.03
sleep 0.5
((start_line+=2))
printf '\e[%d;1H' "$start_line"
typewriter "Blue pill - the story ends, you disconnect." "$cyan" 0.03
sleep 0.3
((start_line++))
printf '\e[%d;1H' "$start_line"
typewriter "Red pill - you stay and see how deep the rabbit hole goes." "$red" 0.03
sleep 0.5
((start_line+=2))
printf '\e[%d;1H' "$start_line"
typewriter "Make your choice [" "$green" 0.04 no
typewriter "red" "$red" 0.04 no
typewriter "/" "$green" 0.04 no
typewriter "blue" "$cyan" 0.04 no
typewriter "]: " "$green" 0.04 no
echo ""  # Force newline and flush

# Pozostaw ekran widoczny na 10 sekund zanim wróci do normalnego terminala
sleep 10
deinit_term
