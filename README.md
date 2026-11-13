# Stagehand downloads

Installers of [Stagehand](https://github.com/Cheter0410/stagehand) are under **Releases**
(macOS `.dmg`, Windows `Stagehand-Setup-….exe`, Linux `…-linux-x86_64.tar.gz`).

`apps.json` is the live catalog: Stagehand reads it on start, so an app added here appears in every
installed Stagehand without a new version. Format: see the Stagehand README ("Adding an app").

## Ohne Internet (USB-Stick, Linux)

Lade die Linux-Dateien der Apps (`*-linux-x86_64.tar.gz`, für Show Master auch
das Arch-Paket `*.pkg.tar.zst`) und [`usb-install.sh`](usb-install.sh) auf den
Stick. Auf dem Rechner dann:

    sh /run/media/$USER/<Stick>/usb-install.sh
