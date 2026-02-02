# ==============================
# SKINNUX :: NULLROOT PROMPT
# ==============================

# Reset jika non-interactive
[[ $- != *i* ]] && return

# Colors
C_RESET="\[\e[0m\]"
C_LINE="\[\e[38;5;45m\]"
C_USER="\[\e[38;5;51m\]"
C_PATH="\[\e[38;5;39m\]"
C_PROMPT="\[\e[38;5;51m\]"

# Prompt layout
PS1="\n\
${C_LINE}┌─[${C_USER}\u@\h${C_LINE}]─[${C_PATH}\w${C_LINE}]${C_RESET}\n\
${C_LINE}└─${C_PROMPT}❯ ${C_RESET}"
