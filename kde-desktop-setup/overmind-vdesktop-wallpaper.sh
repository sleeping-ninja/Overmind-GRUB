#!/bin/bash

DESKTOP1="$HOME/Sauce/Overmind-GRUB/kde-desktop-setup/overmind-desktop-1-3840x2160.png"
DESKTOP2="$HOME/Sauce/Overmind-GRUB/kde-desktop-setup/overmind-desktop-2-3840x2160.png"

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/overmind-vdesktop-wallpaper.lock"
flock -n 9 || exit 0

apply_current() {
    current="$(qdbus6 org.kde.KWin /KWin currentDesktop 2>/dev/null)"

    case "$current" in
        1) image="$DESKTOP1" ;;
        2) image="$DESKTOP2" ;;
        *) image="$DESKTOP1" ;;
    esac

    plasma-apply-wallpaperimage "$image" >/dev/null 2>&1
}

# Set the correct wallpaper immediately on startup.
apply_current

# React only when KWin reports a virtual-desktop change.
dbus-monitor \
    "sender='org.kde.KWin',path='/VirtualDesktopManager',interface='org.kde.KWin.VirtualDesktopManager',member='currentChanged'" |
while IFS= read -r line; do
    if [[ "$line" == *"signal"* ]]; then
        apply_current
    fi
done
