# ==============================
# SKINNUX :: NULLROOT (fish)
# ==============================

function fish_prompt
    set_color cyan
    echo -n "┌─["
    set_color brcyan
    echo -n (whoami)"@"(hostname)
    set_color cyan
    echo -n "]─["
    set_color brblue
    echo -n (prompt_pwd)
    set_color cyan
    echo "]"

    set_color cyan
    echo -n "└─❯ "
    set_color normal
end
