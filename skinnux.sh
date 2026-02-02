#!/data/data/com.termux/files/usr/bin/bash
# ==================================================
# SKINNUX v0.0.1
# Linux-style UI Skin Distribution for Termux
# Author : SKINNUX
# ==================================================

SKINNUX_DIR="$HOME/.skinnux"
REPO_RAW="https://raw.githubusercontent.com/USERNAME/skinnux/main"

# ---------- UTILS ----------
pause() {
  read -rp "Press Enter to continue..."
}

header() {
  clear
  echo -e "\e[38;5;45m"
  cat << "EOF"
   ███████╗██╗  ██╗██╗███╗   ██╗███╗   ██╗██╗   ██╗██╗  ██╗
   ██╔════╝██║ ██╔╝██║████╗  ██║████╗  ██║██║   ██║╚██╗██╔╝
   ███████╗█████╔╝ ██║██╔██╗ ██║██╔██╗ ██║██║   ██║ ╚███╔╝ 
   ╚════██║██╔═██╗ ██║██║╚██╗██║██║╚██╗██║██║   ██║ ██╔██╗ 
   ███████║██║  ██╗██║██║ ╚████║██║ ╚████║╚██████╔╝██╔╝ ██╗
   ╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝
EOF
  echo -e "\e[0mLinux-style UI Skin Distribution for Termux\n"
}

backup_configs() {
  mkdir -p "$SKINNUX_DIR/backup"
  cp -f "$HOME/.bashrc" "$SKINNUX_DIR/backup/.bashrc.bak" 2>/dev/null
  cp -rf "$HOME/.termux" "$SKINNUX_DIR/backup/.termux.bak" 2>/dev/null
}

restore_configs() {
  cp -f "$SKINNUX_DIR/backup/.bashrc.bak" "$HOME/.bashrc" 2>/dev/null
  rm -rf "$HOME/.termux"
  cp -rf "$SKINNUX_DIR/backup/.termux.bak" "$HOME/.termux" 2>/dev/null
  termux-reload-settings
}

apply_skin() {
  SKIN="$1"
  echo "▶ Applying skin: $SKIN"

  mkdir -p "$HOME/.termux"

  # fetch prompt
  curl -fsSL "$REPO_RAW/skins/$SKIN/prompt.sh" -o "$SKINNUX_DIR/prompt.sh"
  curl -fsSL "$REPO_RAW/skins/$SKIN/colors.properties" -o "$HOME/.termux/colors.properties"

  # inject prompt
  sed -i '/# SKINNUX START/,/# SKINNUX END/d' "$HOME/.bashrc" 2>/dev/null
  cat << EOF >> "$HOME/.bashrc"

# SKINNUX START
source "$SKINNUX_DIR/prompt.sh"
# SKINNUX END
EOF

  termux-reload-settings
  echo "✔ Skin applied. Restart Termux."
}

# ---------- MENU ----------
menu() {
  header
  echo "[1] NULLROOT   – Hacker / Elite"
  echo "[2] NEONBYTE   – Cyberpunk Glow"
  echo "[3] Restore Default"
  echo "[0] Exit"
  echo
  read -rp "Select skin ➜ " opt

  case "$opt" in
    1)
      backup_configs
      apply_skin "nullroot"
      pause
      ;;
    2)
      backup_configs
      apply_skin "neonbyte"
      pause
      ;;
    3)
      restore_configs
      echo "✔ Default restored."
      pause
      ;;
    0)
      exit 0
      ;;
    *)
      echo "Invalid option."
      pause
      ;;
  esac
}

# ---------- ENTRY ----------
mkdir -p "$SKINNUX_DIR"
menu
