#!/data/data/com.termux/files/usr/bin/bash

SKINNUX_DIR="$HOME/.skinnux"
BACKUP_DIR="$SKINNUX_DIR/backup"

restore_all() {
  if [[ -f "$BACKUP_DIR/.bashrc.bak" ]]; then
    cp "$BACKUP_DIR/.bashrc.bak" "$HOME/.bashrc"
  fi

  if [[ -d "$BACKUP_DIR/.termux.bak" ]]; then
    rm -rf "$HOME/.termux"
    cp -r "$BACKUP_DIR/.termux.bak" "$HOME/.termux"
  fi

  termux-reload-settings
}
