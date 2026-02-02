#!/data/data/com.termux/files/usr/bin/bash
# ==================================================
# SKINNUX v0.0.6
# Linux-style UI Skin Distribution for Termux
# Shell: bash | zsh | fish
# ==================================================

# ---------------- CONFIG ----------------
SKINNUX_DIR="$HOME/.skinnux"
BACKUP_DIR="$SKINNUX_DIR/backup"
REPO_RAW="https://raw.githubusercontent.com/USERNAME/skinnux/main"

# ---------------- UTILS ----------------
pause() {
  echo
  read -rp "Press Enter to continue..."
}

header() {
  clear
  echo -e "\033[38;5;45m"
  echo "███████╗██╗  ██╗██╗███╗   ██╗███╗   ██╗██╗   ██╗██╗  ██╗"
  echo "██╔════╝██║ ██╔╝██║████╗  ██║████╗  ██║██║   ██║╚██╗██╔╝"
  echo "███████╗█████╔╝ ██║██╔██╗ ██║██╔██╗ ██║██║   ██║ ╚███╔╝ "
  echo "╚════██║██╔═██╗ ██║██║╚██╗██║██║╚██╗██║██║   ██║ ██╔██╗ "
  echo "███████║██║  ██╗██║██║ ╚████║██║ ╚████║╚██████╔╝██╔╝ ██╗"
  echo "╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝"
  echo -e "\033[0mLinux-style UI Skin Distribution for Termux\n"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# ---------------- DEPENDENCY ----------------
install_dependencies() {
  echo "▶ Checking dependencies..."
  NEED=""

  has_cmd bash || NEED="$NEED bash"
  has_cmd sed || NEED="$NEED sed"
  has_cmd curl || NEED="$NEED curl"
  has_cmd cp || NEED="$NEED coreutils"
  has_cmd termux-reload-settings || NEED="$NEED termux-tools"

  if [ -n "$NEED" ]; then
    echo "▶ Installing:$NEED"
    pkg install -y $NEED
  fi
}

font_hint() {
  echo
  echo "ℹ Tip: Nerd Font / Powerline font recommended"
  echo "  for best visual experience."
}

# ---------------- ENV ----------------
ensure_dirs() {
  mkdir -p "$SKINNUX_DIR" "$BACKUP_DIR" "$HOME/.termux"
}

detect_shell() {
  case "$SHELL" in
    *fish*) echo "fish" ;;
    *zsh*)  echo "zsh" ;;
    *)      echo "bash" ;;
  esac
}

# ---------------- BACKUP ----------------
backup_exists() {
  [ -f "$BACKUP_DIR/.backup_done" ]
}

confirm_backup() {
  echo
  echo "⚠️  SKINNUX Backup Notice"
  echo "Your current Termux configuration will be backed up."
  echo "This includes any custom prompt or colors you already use."
  echo
  read -rp "Continue? [Y/n]: " ans
  case "$ans" in
    n|N) return 1 ;;
    *) return 0 ;;
  esac
}

backup_once_safe() {
  mkdir -p "$BACKUP_DIR"

  [ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc.bak"
  [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.bak"

  if [ -f "$HOME/.config/fish/config.fish" ]; then
    cp "$HOME/.config/fish/config.fish" "$BACKUP_DIR/config.fish.bak"
  fi

  [ -d "$HOME/.termux" ] && cp -r "$HOME/.termux" "$BACKUP_DIR/.termux.bak"

  touch "$BACKUP_DIR/.backup_done"
  echo "✔ Backup created."
}

# ---------------- RESTORE ----------------
restore_default() {
  echo "▶ Restoring previous configuration..."

  [ -f "$BACKUP_DIR/.bashrc.bak" ] && cp "$BACKUP_DIR/.bashrc.bak" "$HOME/.bashrc"
  [ -f "$BACKUP_DIR/.zshrc.bak" ] && cp "$BACKUP_DIR/.zshrc.bak" "$HOME/.zshrc"

  if [ -f "$BACKUP_DIR/config.fish.bak" ]; then
    mkdir -p "$HOME/.config/fish"
    cp "$BACKUP_DIR/config.fish.bak" "$HOME/.config/fish/config.fish"
  fi

  if [ -d "$BACKUP_DIR/.termux.bak" ]; then
    rm -rf "$HOME/.termux"
    cp -r "$BACKUP_DIR/.termux.bak" "$HOME/.termux"
  fi

  termux-reload-settings
  echo "✔ Restore completed."
}

# ---------------- PROMPT INJECT ----------------
inject_bash_zsh() {
  FILE="$1"
  [ ! -f "$FILE" ] && return

  sed -i '/# SKINNUX START/,/# SKINNUX END/d' "$FILE"
  echo >> "$FILE"
  echo "# SKINNUX START" >> "$FILE"
  echo "[ -f \"$SKINNUX_DIR/prompt.sh\" ] && source \"$SKINNUX_DIR/prompt.sh\"" >> "$FILE"
  echo "# SKINNUX END" >> "$FILE"
}

inject_fish() {
  CONF="$HOME/.config/fish/config.fish"
  mkdir -p "$(dirname "$CONF")"

  sed -i '/# SKINNUX START/,/# SKINNUX END/d' "$CONF"
  echo >> "$CONF"
  echo "# SKINNUX START" >> "$CONF"
  echo "source $SKINNUX_DIR/prompt.fish" >> "$CONF"
  echo "# SKINNUX END" >> "$CONF"
}

# ---------------- APPLY SKIN ----------------
apply_skin() {
  SKIN="$1"
  SHELL_TYPE="$(detect_shell)"

  if ! backup_exists; then
    confirm_backup || return
    backup_once_safe
  fi

  echo "▶ Applying skin: $SKIN ($SHELL_TYPE)"

  curl -fsSL "$REPO_RAW/skins/$SKIN/prompt.sh" -o "$SKINNUX_DIR/prompt.sh" 2>/dev/null
  curl -fsSL "$REPO_RAW/skins/$SKIN/prompt.fish" -o "$SKINNUX_DIR/prompt.fish" 2>/dev/null
  curl -fsSL "$REPO_RAW/skins/$SKIN/colors.properties" -o "$HOME/.termux/colors.properties" || return

  case "$SHELL_TYPE" in
    fish) inject_fish ;;
    zsh)  inject_bash_zsh "$HOME/.zshrc" ;;
    bash) inject_bash_zsh "$HOME/.bashrc" ;;
  esac

  termux-reload-settings
  echo "✔ Skin applied. Restart Termux."
}

# ---------------- MENU ----------------
menu() {
  while true; do
    header
    echo "[1] NULLROOT   - Hacker / Elite"
    echo "[2] NEONBYTE   - Cyberpunk Glow"
    echo "-------------------------------"
    echo "[3] Restore Default"
    echo "[0] Exit"
    echo
    read -rp "Select option ➜ " opt

    case "$opt" in
      1) apply_skin "nullroot"; pause ;;
      2) apply_skin "neonbyte"; pause ;;
      3) restore_default; pause ;;
      0) exit 0 ;;
      *) echo "Invalid option."; pause ;;
    esac
  done
}

# ---------------- ENTRY ----------------
ensure_dirs
install_dependencies
font_hint
menu  REQUIRED="bash coreutils sed curl termux-reload-settings"
  MISSING=""

  for cmd in $REQUIRED; do
    if ! has_cmd "$cmd"; then
      case "$cmd" in
        termux-reload-settings) MISSING="$MISSING termux-tools" ;;
        *) MISSING="$MISSING $cmd" ;;
      esac
    fi
  done

  if [ -n "$MISSING" ]; then
    printf "▶ Installing required dependencies:%s\n" "$MISSING"
    pkg install -y $MISSING
  fi
}

font_hint() {
  printf "\nℹ Tip: Nerd Font / Powerline font recommended for best visuals.\n"
}

# ---------------- ENV ----------------
ensure_dirs() {
  mkdir -p "$SKINNUX_DIR" "$BACKUP_DIR" "$HOME/.termux"
}

detect_shell() {
  if echo "$SHELL" | grep -q "fish"; then
    echo "fish"
  elif echo "$SHELL" | grep -q "zsh"; then
    echo "zsh"
  else
    echo "bash"
  fi
}

# ---------------- BACKUP LOGIC ----------------
backup_exists() {
  [ -f "$BACKUP_DIR/.backup_done" ]
}

confirm_backup() {
  printf "\n⚠️  SKINNUX Backup Notice\n"
  printf "Your current Termux configuration will be backed up.\n"
  printf "This includes any custom prompt or colors you already use.\n"
  printf "Backup is done ONCE and used for restore.\n\n"
  printf "Continue? [Y/n]: "
  read ans

  case "$ans" in
    n|N) return 1 ;;
    *) return 0 ;;
  esac
}

backup_once_safe() {
  mkdir -p "$BACKUP_DIR"

  [ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc.bak"
  [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.bak"

  if [ -f "$HOME/.config/fish/config.fish" ]; then
    cp "$HOME/.config/fish/config.fish" "$BACKUP_DIR/config.fish.bak"
  fi

  [ -d "$HOME/.termux" ] && cp -r "$HOME/.termux" "$BACKUP_DIR/.termux.bak"

  touch "$BACKUP_DIR/.backup_done"
  printf "✔ Backup created successfully.\n"
}

# ---------------- RESTORE ----------------
restore_default() {
  printf "▶ Restoring previous configuration...\n"

  [ -f "$BACKUP_DIR/.bashrc.bak" ] && cp "$BACKUP_DIR/.bashrc.bak" "$HOME/.bashrc"
  [ -f "$BACKUP_DIR/.zshrc.bak" ] && cp "$BACKUP_DIR/.zshrc.bak" "$HOME/.zshrc"

  if [ -f "$BACKUP_DIR/config.fish.bak" ]; then
    mkdir -p "$HOME/.config/fish"
    cp "$BACKUP_DIR/config.fish.bak" "$HOME/.config/fish/config.fish"
  fi

  if [ -d "$BACKUP_DIR/.termux.bak" ]; then
    rm -rf "$HOME/.termux"
    cp -r "$BACKUP_DIR/.termux.bak" "$HOME/.termux"
  fi

  termux-reload-settings
  printf "✔ Restore completed.\n"
}

# ---------------- PROMPT INJECT ----------------
inject_bash_zsh() {
  FILE="$1"
  [ ! -f "$FILE" ] && return

  sed -i '/# SKINNUX START/,/# SKINNUX END/d' "$FILE"
  printf "\n# SKINNUX START\n" >> "$FILE"
  printf "[ -f \"$SKINNUX_DIR/prompt.sh\" ] && source \"$SKINNUX_DIR/prompt.sh\"\n" >> "$FILE"
  printf "# SKINNUX END\n" >> "$FILE"
}

inject_fish() {
  FISH_CONF="$HOME/.config/fish/config.fish"
  mkdir -p "$(dirname "$FISH_CONF")"

  sed -i '/# SKINNUX START/,/# SKINNUX END/d' "$FISH_CONF"
  printf "\n# SKINNUX START\n" >> "$FISH_CONF"
  printf "source %s/prompt.fish\n" "$SKINNUX_DIR" >> "$FISH_CONF"
  printf "# SKINNUX END\n" >> "$FISH_CONF"
}

# ---------------- APPLY SKIN ----------------
apply_skin() {
  SKIN="$1"
  SHELL_TYPE="$(detect_shell)"

  if ! backup_exists; then
    confirm_backup || return
    backup_once_safe
  fi

  printf "▶ Applying skin: %s (%s)\n" "$SKIN" "$SHELL_TYPE"

  curl -fsSL "$REPO_RAW/skins/$SKIN/prompt.sh" \
    -o "$SKINNUX_DIR/prompt.sh" 2>/dev/null

  curl -fsSL "$REPO_RAW/skins/$SKIN/prompt.fish" \
    -o "$SKINNUX_DIR/prompt.fish" 2>/dev/null

  curl -fsSL "$REPO_RAW/skins/$SKIN/colors.properties" \
    -o "$HOME/.termux/colors.properties" || return 1

  case "$SHELL_TYPE" in
    fish) inject_fish ;;
    zsh)  inject_bash_zsh "$HOME/.zshrc" ;;
    bash) inject_bash_zsh "$HOME/.bashrc" ;;
  esac

  termux-reload-settings
  printf "✔ Skin applied. Restart shell for full effect.\n"
}

# ---------------- MENU ----------------
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
      1) apply_skin "nullroot"; pause ;;
      2) apply_skin "neonbyte"; pause ;;
      3) restore_default; pause ;;
      0) exit 0 ;;
      *) printf "Invalid option.\n"; pause ;;
    esac
  done
}

# ---------------- ENTRY ----------------
ensure_dirs
install_dependencies
font_hint
menu  REQUIRED="bash coreutils sed curl termux-reload-settings"
  MISSING=""

  for cmd in $REQUIRED; do
    if ! has_cmd "$cmd"; then
      case "$cmd" in
        termux-reload-settings) MISSING="$MISSING termux-tools" ;;
        *) MISSING="$MISSING $cmd" ;;
      esac
    fi
  done

  if [ -n "$MISSING" ]; then
    printf "▶ Installing required dependencies:%s\n" "$MISSING"
    pkg install -y $MISSING
  fi
}

font_hint() {
  printf "\nℹ Tip: For best visuals, use Nerd Font / Powerline font.\n"
  printf "  Some symbols may look broken without it.\n"
}

# ------------- ENV SETUP -------------
ensure_dirs() {
  mkdir -p "$SKINNUX_DIR" "$BACKUP_DIR" "$HOME/.termux"
}

detect_shell() {
  if echo "$SHELL" | grep -q "fish"; then
    echo "fish"
  elif echo "$SHELL" | grep -q "zsh"; then
    echo "zsh"
  else
    echo "bash"
  fi
}

# ------------- BACKUP (ONCE) -------------
backup_once() {
  [ -f "$HOME/.bashrc" ] && [ ! -f "$BACKUP_DIR/.bashrc.bak" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc.bak"
  [ -f "$HOME/.zshrc" ] && [ ! -f "$BACKUP_DIR/.zshrc.bak" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.bak"

  if [ -d "$HOME/.termux" ] && [ ! -d "$BACKUP_DIR/.termux.bak" ]; then
    cp -r "$HOME/.termux" "$BACKUP_DIR/.termux.bak"
  fi
}

# ------------- RESTORE -------------
restore_default() {
  printf "▶ Restoring original configuration...\n"

  [ -f "$BACKUP_DIR/.bashrc.bak" ] && cp "$BACKUP_DIR/.bashrc.bak" "$HOME/.bashrc"
  [ -f "$BACKUP_DIR/.zshrc.bak" ] && cp "$BACKUP_DIR/.zshrc.bak" "$HOME/.zshrc"

  if [ -d "$BACKUP_DIR/.termux.bak" ]; then
    rm -rf "$HOME/.termux"
    cp -r "$BACKUP_DIR/.termux.bak" "$HOME/.termux"
  fi

  termux-reload-settings
  printf "✔ Restore completed.\n"
}

# ------------- INJECT PROMPT -------------
inject_bash_zsh() {
  FILE="$1"
  [ ! -f "$FILE" ] && return

  sed -i '/# SKINNUX START/,/# SKINNUX END/d' "$FILE"
  printf "\n# SKINNUX START\n" >> "$FILE"
  printf "[ -f \"$SKINNUX_DIR/prompt.sh\" ] && source \"$SKINNUX_DIR/prompt.sh\"\n" >> "$FILE"
  printf "# SKINNUX END\n" >> "$FILE"
}

inject_fish() {
  FISH_CONF="$HOME/.config/fish/config.fish"
  mkdir -p "$(dirname "$FISH_CONF")"

  sed -i '/# SKINNUX START/,/# SKINNUX END/d' "$FISH_CONF"
  printf "\n# SKINNUX START\n" >> "$FISH_CONF"
  printf "source %s/prompt.fish\n" "$SKINNUX_DIR" >> "$FISH_CONF"
  printf "# SKINNUX END\n" >> "$FISH_CONF"
}

# ------------- APPLY SKIN -------------
apply_skin() {
  SKIN="$1"
  SHELL_TYPE="$(detect_shell)"

  printf "▶ Applying skin: %s (%s)\n" "$SKIN" "$SHELL_TYPE"

  curl -fsSL "$REPO_RAW/skins/$SKIN/prompt.sh" \
    -o "$SKINNUX_DIR/prompt.sh" 2>/dev/null

  curl -fsSL "$REPO_RAW/skins/$SKIN/prompt.fish" \
    -o "$SKINNUX_DIR/prompt.fish" 2>/dev/null

  curl -fsSL "$REPO_RAW/skins/$SKIN/colors.properties" \
    -o "$HOME/.termux/colors.properties" || return 1

  case "$SHELL_TYPE" in
    fish) inject_fish ;;
    zsh)  inject_bash_zsh "$HOME/.zshrc" ;;
    bash) inject_bash_zsh "$HOME/.bashrc" ;;
  esac

  termux-reload-settings
  printf "✔ Skin applied. Restart shell for full effect.\n"
}

# ------------- MENU -------------
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

# ------------- ENTRY POINT -------------
ensure_dirs
install_dependencies
font_hint
menu  if echo "$SHELL" | grep -q "fish"; then
    echo "fish"
  elif echo "$SHELL" | grep -q "zsh"; then
    echo "zsh"
  else
    echo "bash"
  fi
}

# ------------- BACKUP (ONCE) -------------
backup_once() {
  [ -f "$HOME/.bashrc" ] && [ ! -f "$BACKUP_DIR/.bashrc.bak" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc.bak"
  [ -f "$HOME/.zshrc" ] && [ ! -f "$BACKUP_DIR/.zshrc.bak" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.bak"

  if [ -d "$HOME/.termux" ] && [ ! -d "$BACKUP_DIR/.termux.bak" ]; then
    cp -r "$HOME/.termux" "$BACKUP_DIR/.termux.bak"
  fi
}

# ------------- RESTORE -------------
restore_default() {
  printf "▶ Restoring original configuration...\n"

  [ -f "$BACKUP_DIR/.bashrc.bak" ] && cp "$BACKUP_DIR/.bashrc.bak" "$HOME/.bashrc"
  [ -f "$BACKUP_DIR/.zshrc.bak" ] && cp "$BACKUP_DIR/.zshrc.bak" "$HOME/.zshrc"

  if [ -d "$BACKUP_DIR/.termux.bak" ]; then
    rm -rf "$HOME/.termux"
    cp -r "$BACKUP_DIR/.termux.bak" "$HOME/.termux"
  fi

  termux-reload-settings
  printf "✔ Restore completed.\n"
}

# ------------- INJECT PROMPT -------------
inject_bash_zsh() {
  FILE="$1"
  [ ! -f "$FILE" ] && return

  sed -i '/# SKINNUX START/,/# SKINNUX END/d' "$FILE"
  printf "\n# SKINNUX START\n" >> "$FILE"
  printf "[ -f \"$SKINNUX_DIR/prompt.sh\" ] && source \"$SKINNUX_DIR/prompt.sh\"\n" >> "$FILE"
  printf "# SKINNUX END\n" >> "$FILE"
}

inject_fish() {
  FISH_CONF="$HOME/.config/fish/config.fish"
  mkdir -p "$(dirname "$FISH_CONF")"

  sed -i '/# SKINNUX START/,/# SKINNUX END/d' "$FISH_CONF"
  printf "\n# SKINNUX START\n" >> "$FISH_CONF"
  printf "source %s/prompt.fish\n" "$SKINNUX_DIR" >> "$FISH_CONF"
  printf "# SKINNUX END\n" >> "$FISH_CONF"
}

# ------------- APPLY SKIN -------------
apply_skin() {
  SKIN="$1"
  SHELL_TYPE="$(detect_shell)"

  printf "▶ Applying skin: %s (%s)\n" "$SKIN" "$SHELL_TYPE"

  curl -fsSL "$REPO_RAW/skins/$SKIN/prompt.sh" \
    -o "$SKINNUX_DIR/prompt.sh" 2>/dev/null

  curl -fsSL "$REPO_RAW/skins/$SKIN/prompt.fish" \
    -o "$SKINNUX_DIR/prompt.fish" 2>/dev/null

  curl -fsSL "$REPO_RAW/skins/$SKIN/colors.properties" \
    -o "$HOME/.termux/colors.properties" || return 1

  case "$SHELL_TYPE" in
    fish) inject_fish ;;
    zsh)  inject_bash_zsh "$HOME/.zshrc" ;;
    bash) inject_bash_zsh "$HOME/.bashrc" ;;
  esac

  termux-reload-settings
  printf "✔ Skin applied. Restart shell for full effect.\n"
}

# ------------- MENU -------------
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

# ------------- ENTRY POINT -------------
ensure_dirs
menu      0) exit 0 ;;
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
