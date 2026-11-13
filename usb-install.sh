#!/bin/sh
# Installs Stagehand and the show apps from a USB stick, without internet.
#
# Put this file on the stick next to the downloaded Linux files
# (*-linux-x86_64.tar.gz and/or showmaster-*.pkg.tar.zst), then run:
#
#   sh /run/media/$USER/<stick>/usb-install.sh
#
# Everything lands where Stagehand itself installs apps
# (~/.local/share/stagehand/apps), so Stagehand sees them as installed and
# can update or remove them later.
set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
APPS="$HOME/.local/share/stagehand/apps"
BIN="$HOME/.local/bin"
MENU="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$APPS" "$BIN" "$MENU"
found=0

# Show Master as an Arch package, if there is one.
for pkg in "$HERE"/showmaster-*.pkg.tar.zst; do
  [ -f "$pkg" ] || continue
  found=1
  echo "==> Show Master (Arch-Paket) – sudo fragt nach deinem Passwort"
  sudo pacman -U --noconfirm "$pkg"
done

for tar in "$HERE"/*-linux-x86_64.tar.gz; do
  [ -f "$tar" ] || continue
  base=$(basename "$tar" -linux-x86_64.tar.gz)   # e.g. lantern-0.1.0
  id=${base%%-*}                                   # lantern
  version=${base#*-}                               # 0.1.0
  # The Arch package already installed Show Master.
  if [ "$id" = showmaster ] && command -v pacman >/dev/null && pacman -Q showmaster >/dev/null 2>&1; then
    echo "==> showmaster: per pacman installiert, Archiv übersprungen"
    continue
  fi
  found=1
  echo "==> $id $version"
  tmp="$APPS/.$id.new"
  rm -rf "$tmp" && mkdir -p "$tmp"
  tar -xzf "$tar" -C "$tmp"
  inner=$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n1)
  [ -n "$inner" ] && [ -x "$inner/$id" ] || { echo "    $id fehlt im Archiv, übersprungen"; rm -rf "$tmp"; continue; }
  echo "$version" > "$inner/VERSION"
  rm -rf "${APPS:?}/$id"
  mv "$inner" "$APPS/$id"
  rm -rf "$tmp"
  ln -sf "$APPS/$id/$id" "$BIN/$id"
  name=$(sed -n 's/^Name=//p' "$APPS/$id/$id.desktop" 2>/dev/null | head -n1)
  icon=""
  [ -f "$APPS/$id/icon.png" ] && icon="Icon=$APPS/$id/icon.png
"
  printf '[Desktop Entry]\nType=Application\nName=%s\nExec="%s" %%F\n%sTerminal=false\nCategories=AudioVideo;\nX-Stagehand=1\n' \
    "${name:-$id}" "$APPS/$id/$id" "$icon" > "$MENU/$id.desktop"
done

[ "$found" = 1 ] || { echo "Keine Pakete neben $0 gefunden."; exit 1; }

# ~/.local/bin on the PATH, so "stagehand" works in the terminal.
case ":$PATH:" in
  *":$BIN:"*) ;;
  *)
    if command -v fish >/dev/null; then fish -c "fish_add_path $BIN" || true; fi
    grep -qs '.local/bin' "$HOME/.bashrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    ;;
esac

echo
echo "Fertig. Stagehand findest du jetzt im Startmenü."
