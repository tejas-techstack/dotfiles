#!/usr/bin/env bash
# Symlinks everything under home/ into $HOME, preserving the relative path.
# Existing real files/dirs are backed up (not deleted) before being replaced.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="$DOTFILES_DIR/home"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

link_one() {
  local src="$1"
  local rel="${src#"$SRC_ROOT"/}"
  local target="$HOME/$rel"

  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ]; then
    if [ "$(readlink "$target")" = "$src" ]; then
      return 0
    fi
    rm "$target"
  elif [ -e "$target" ]; then
    mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
    mv "$target" "$BACKUP_DIR/$rel"
    echo "backed up existing $rel -> ${BACKUP_DIR#"$HOME"/}/$rel"
  fi

  ln -s "$src" "$target"
  echo "linked $rel"
}

while IFS= read -r -d '' file; do
  link_one "$file"
done < <(find "$SRC_ROOT" -type f -print0)

echo
echo "Done. Some configs need a one-time manual step:"
echo "  - nvim: clone the NvChad base first, then this repo's custom/ layer applies on top:"
echo "      git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1"
echo "      (install.sh will then symlink lua/custom/* into it)"
echo "  - oh-my-zsh: install oh-my-zsh itself first (https://ohmyz.sh), then re-run this script"
echo "      so .oh-my-zsh/custom/example.zsh gets linked."
