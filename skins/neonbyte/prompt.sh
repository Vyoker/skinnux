# ==============================
# SKINNUX :: NEONBYTE PROMPT
# ==============================

[[ $- != *i* ]] && return

# Colors
C_RESET="\[\e[0m\]"
BG_USER="\[\e[48;5;25m\e[38;5;15m\]"
BG_PATH="\[\e[48;5;33m\e[38;5;15m\]"
C_SEP="\[\e[38;5;51m\]"
C_PROMPT="\[\e[38;5;51m\]"

# Prompt layout
PS1="\n\
${C_SEP}╭─${BG_USER} \u@\h ${C_RESET}${C_SEP}${BG_PATH} \w ${C_RESET}${C_SEP}\n\
${C_SEP}╰─${C_PROMPT}⚡ ${C_RESET}"
