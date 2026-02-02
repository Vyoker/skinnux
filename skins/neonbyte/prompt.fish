# ==============================
# SKINNUX :: NEONBYTE (fish)
# ==============================

function fish_prompt
    set_color brcyan
    echo -n "╭─⚡ "
    set_color brwhite
    echo -n (whoami)"@"(hostname)
    set_color brmagenta
    echo -n " "(prompt_pwd)
    set_color brcyan
    echo ""

    set_color brcyan
    echo -n "╰─⚡ "
    set_color normal
end
