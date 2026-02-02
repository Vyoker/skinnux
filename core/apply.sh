#!/data/data/com.termux/files/usr/bin/bash

SKINNUX_DIR="$HOME/.skinnux"

apply_skin() {
  local SKIN="$1"

  mkdir -p "$HOME/.termux"

  # Remove old SKINNUX block only
  sed -i '/# SKINNUX START/,/# SKINNUX END/d' "$HOME/.bashrc" 2>/dev/null

  cat << EOF >> "$HOME/.bashrc"

# SKINNUX START
source "$SKINNUX_DIR/prompt.sh"
# SKINNUX END
EOF

  termux-reload-settings
}
