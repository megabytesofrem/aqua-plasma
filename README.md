# Aqua Plasma
A work in progress total transformation pack to make KDE Plasma look and feel like Mac OS X Snow Leopard, inspired by the aerothemeplasma project.

## Install

Run from this directory in a Plasma 6.7+ environment with Qt Quick Controls,
Kirigami, and Plasma QML modules installed:

```sh
kpackagetool6 --type Plasma/Applet --install ./aqua-glass-dock/package
kpackagetool6 --type Plasma/Applet --install ./aqua-global-menu/package
```

Then add **Aqua Glass Dock** or **Aqua Global Menu** using Plasma's widget
explorer. Both use an inline representation suitable for a panel or desktop.

After making changes, replace `--install` with `--upgrade` and remove/re-add
the widget or restart the preview to reload its QML.

## Preview

For live development, register both source packages with safe symlinks first
(requires Bash, `jq`, and GNU coreutils):

```sh
bash ./symlink.sh
```

The script works from any working directory, reads plugin IDs from metadata,
and respects `XDG_DATA_HOME` (default: `~/.local/share`). Repeated runs leave
correct links alone.

With the Plasma SDK installed, preview the registered packages by ID:

```sh
plasmoidviewer -a com.megabytesofrem.aqua-glass-dock
plasmoidviewer -a com.megabytesofrem.aqua-global-menu
```


See the [KDE widget development documentation](https://develop.kde.org/docs/plasma/widget/) for the Plasma package and QML APIs.
