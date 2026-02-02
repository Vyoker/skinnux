#!/data/data/com.termux/files/usr/bin/bash
# =========================================
# SKINNUX v0.0.1
# Linux-style UI Skin Distribution for Termux
# Shell support: bash, zsh, fish (safe)
# =========================================

SKINNUX_DIR="$HOME/.skinnux"
BACKUP_DIR="$SKINNUX_DIR/backup"
REPO_RAW="https://raw.githubusercontent.com/USERNAME/skinnux/main"

# ---------- UTILS ----------
pause() {
  printf "\nPress Enter to continue..."
  read _
}

header() {
  clear
  printf "\033[38;5;45m"
  printf "███████╗██╗  ██╗██╗███╗   ██╗███╗   ██╗██╗   ██╗██╗  ██╗\n"
  printf "██╔════╝██║ ██╔╝██║████╗  ██║████╗  ██║██║   ██║╚██╗██╔╝\n"
  printf "███████╗█████╔╝ ██║██╔██╗ ██║██╔██╗ ██║██║   ██║ ╚███╔╝ \n"
  printf "╚════██║██╔═██╗ ██║██║╚██╗██║██║╚██╗██║██║   ██║ ██╔██╗ \n"
  printf "███████║██║  ██╗██║██║ ╚████║██║ ╚████║╚██████╔╝██╔╝ ██╗\n"
  printf "╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝\n"
  printf "\033[0mLinux-style UI Skin Distribution for Termux\n\n"
}

ensure_dirs() {
  mkdir -p "$SKINNUX_DIR" "$BACKUP_DIR" "$HOME/.termux"
}

# ---------- BACKUP (ONCE) ----------
backup_once() {
  if [ -f "$HOME/.bashrc" ] && [ ! -f "$BACKUP_DIR/.bashrc.bak" ]; then
    cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc.bak"
  fi

  if [ -f "$HOME/.zshrc" ] && [ ! -f "$BACKUP_DIR/.zshrc.bak" ]; then
    cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.bak"
  fi

  if [ -d "$HOME/.termux" ] && [ ! -d "$BACKUP_DIR/.termux.bak" ]; then
    cp -r "$HOME/.termux" "$BACKUP_DIR/.termux.bak"
  fi
}

# ---------- RESTORE ----------
restore_default() {
  printf "▶ Restoring original configuration...\n"

  [ -f "$BACKUP_DIR/.bashrc.bak" ] && cp "$BACKUP_DIR/.bashrc.bak" "$HOME/.bashrc"
  [ -f "$BACKUP_DIR/.zshrc.bak" ] && cp "$BACKUP_DIR/.zshrc.bak" "$HOME/.zshrc"

  if [ -d "$BACKUP_DIR/.termux.bak" ]; then
    rm -rf "$HOME/.termux"
    cp -r "$BACKUP_DIR/.termux.bak" "$HOME/.termux"
  fi

  termux-reload-settings
  printf "✔ Restored successfully.\n"
}

# ---------- INJECT PROMPT ----------
inject_prompt() {
  FILE="$1"

  [ ! -f "$FILE" ] && return

  sed -i '/# SKINNUX START/,/# SKINNUX END/d' "$FILE"

  printf "\n# SKINNUX START\n" >> "$FILE"
  printf "[ -f \"$SKINNUX_DIR/prompt.sh\" ] && source \"$SKINNUX_DIR/prompt.sh\"\n" >> "$FILE"
  printf "# SKINNUX END\n" >> "$FILE"
}

# ---------- APPLY SKIN ----------
apply_skin() {
  SKIN="$1"
  printf "▶ Applying skin: %s\n" "$SKIN"

  curl -fsSL "$REPO_RAW/skins/$SKIN/prompt.sh" \
    -o "$SKINNUX_DIR/prompt.sh" || return 1

  curl -fsSL "$REPO_RAW/skins/$SKIN/colors.properties" \
    -o "$HOME/.termux/colors.properties" || return 1

  inject_prompt "$HOME/.bashrc"
  inject_prompt "$HOME/.zshrc"

  termux-reload-settings
  printf "✔ Skin applied. Restart Termux.\n"
}

# ---------- MENU ----------
menu() {
  while true; do
    header
    printf "[1] NULLROOT   – Hacker / Elite\n"
    printf "[2] NEONBYTE   – Cyberpunk Glow\n"
    printf "-------------------------------\n"
    printf "[3] Restore Default\n"
    printf "[0] Exit\n\n"

    printf "Select option ➜ "
    read opt

    case "$opt" in
      1) backup_once; apply_skin "nullroot"; pause ;;
      2) backup_once; apply_skin "neonbyte"; pause ;;
      3) restore_default; pause ;;
      0) exit 0 ;;
      *) printf "Invalid option.\n"; pause ;;
    esac
  done
}

# ---------- ENTRY ----------
ensure_dirs
menu  cp -f "$SKINNUX_DIR/backup/.bashrc.bak" "$HOME/.bashrc" 2>/dev/null
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
