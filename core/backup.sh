#!/data/data/com.termux/files/usr/bin/bash

SKINNUX_DIR="$HOME/.skinnux"
BACKUP_DIR="$SKINNUX_DIR/backup"

backup_once() {
  mkdir -p "$BACKUP_DIR"

  if [[ ! -f "$BACKUP_DIR/.bashrc.bak" && -f "$HOME/.bashrc" ]]; then
    cp "$HOME/.bashrc" "$BACKUP_DIR/.bashrc.bak"
  fi

  if [[ ! -d "$BACKUP_DIR/.termux.bak" && -d "$HOME/.termux" ]]; then
    cp -r "$HOME/.termux" "$BACKUP_DIR/.termux.bak"
  fi
}
