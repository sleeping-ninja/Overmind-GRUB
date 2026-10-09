# Overmind KDE Desktop

Companion desktop configuration for the **Overmind GRUB** theme.

Designed and tested on:

- Kubuntu / KDE Plasma 6
- UEFI GRUB
- 3840×2160 desktop
- GRUB graphical mode: 1280×720

The desktop theme extends the Overmind visual identity through:

- GRUB
- SDDM login
- KDE virtual desktops
- Firefox
- Plasma panel
- KDE active-window decorations

> **PLEASE REMAIN SUGGESTIBLE.**

---

## Included Assets

### Desktop Wallpapers

- `overmind-desktop-1-3840x2160.png`
- `overmind-desktop-2-3840x2160.png`

The two desktop images use opposing perspectives so switching left/right between KDE virtual desktops creates a subtle viewpoint shift.

### Login Wallpaper

- `overmind-login-3840x2160.png`

A closer, more imposing variation intended for SDDM.

### Firefox Wallpaper

- `overmind-firefox-1920x1080.png`

A simplified version centred around the Overmind pyramid / eye.

### Scripts and Configuration

- `grub-default.reference`
- `06_overmind_background`
- `overmind-vdesktop-wallpaper.sh`
- `overmind-vdesktop-wallpaper.desktop`
- `sddm-theme.conf.reference`

---

# 1. GRUB Background

The full GRUB theme is deliberately **not enabled** in this configuration.

The graphical GRUB theme's terminal box appears during boot handoff and obscures the artwork.

Instead, standard GRUB is retained and the Overmind artwork is used directly as the graphical background.

## Install the Background

From the `kde-desktop-setup` directory:

```bash
sudo cp ../overmind-grub-1280x720.png \
  /boot/grub/overmind-background.png
```

If the repository is installed elsewhere, adjust the source path accordingly.

## Configure `/etc/default/grub`

Do **not** blindly overwrite an existing `/etc/default/grub`.

Merge these settings into it:

```ini
GRUB_GFXMODE=1280x720
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_BACKGROUND="/boot/grub/overmind-background.png"

# Keep the full theme disabled:
#GRUB_THEME="/boot/grub/themes/overmind/theme.txt"
```

Normal boot can retain:

```ini
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
```

The complete working machine configuration is included as:

```text
grub-default.reference
```

for comparison.

---

# 2. Overmind GRUB Background Reinforcement

Install the late background script:

```bash
sudo cp 06_overmind_background \
  /etc/grub.d/06_overmind_background

sudo chmod +x \
  /etc/grub.d/06_overmind_background
```

The script reapplies the wallpaper after Kubuntu's `05_debian_theme` stage:

```grub
insmod png
background_image -m stretch /boot/grub/overmind-background.png
```

## Important: Check `40_custom`

An old transparency experiment can erase the wallpaper if this line exists:

```grub
background_color 0,0,0,0
```

Check:

```bash
sudo cat /etc/grub.d/40_custom
```

Remove any such `background_color` line.

Then regenerate GRUB:

```bash
sudo update-grub
```

Expected output should include:

```text
Found background: /boot/grub/overmind-background.png
Found background image: /boot/grub/overmind-background.png
```

Verify the generated configuration:

```bash
sudo grep -nE \
'background_(image|color)|set theme=|theme=' \
/boot/grub/grub.cfg
```

The Overmind background should be present and there should be no late:

```text
background_color 0,0,0,0
```

entry remaining.

---

# 3. KDE Virtual Desktop Wallpapers

KDE Plasma does not natively support separate wallpapers per virtual desktop.

The included watcher listens for KWin virtual-desktop changes over D-Bus and changes the wallpaper automatically.

Desktop mapping:

```text
Desktop 1 -> overmind-desktop-1-3840x2160.png
Desktop 2 -> overmind-desktop-2-3840x2160.png
```

### Set the Initial Plasma Wallpaper

Before enabling the virtual-desktop watcher, set Plasma's normal desktop wallpaper to:

```text
~/Sauce/Overmind-GRUB/kde-desktop-setup/overmind-desktop-1-3840x2160.png
```

This ensures the Overmind artwork is already visible immediately after login, before the autostart watcher begins. The watcher will then take over normally and switch between the Desktop 1 and Desktop 2 perspectives.

You can set it through:

```text
Right-click Desktop
-> Desktop and Wallpaper
-> Wallpaper
-> Add Image
-> overmind-desktop-1-3840x2160.png
```

## Install

Create the script directory:

```bash
mkdir -p ~/bin
```

Copy the watcher:

```bash
cp overmind-vdesktop-wallpaper.sh \
  ~/bin/overmind-vdesktop-wallpaper.sh

chmod +x \
  ~/bin/overmind-vdesktop-wallpaper.sh
```

The script currently expects the wallpaper assets at:

```text
~/Sauce/Overmind-GRUB/kde-desktop-setup/
```

If the repository is installed somewhere else, edit the two wallpaper paths in:

```text
~/bin/overmind-vdesktop-wallpaper.sh
```

## Test

Run:

```bash
~/bin/overmind-vdesktop-wallpaper.sh
```

Switch between KDE virtual desktops 1 and 2.

Stop the manual test with:

```text
Ctrl+C
```

---

# 4. Autostart the Virtual-Desktop Watcher

Create the Plasma autostart directory:

```bash
mkdir -p ~/.config/autostart
```

Copy the desktop entry:

```bash
cp overmind-vdesktop-wallpaper.desktop \
  ~/.config/autostart/overmind-vdesktop-wallpaper.desktop
```

The supplied reference entry was created on a system whose home directory is:

```text
/home/kill
```

If deploying for another user, edit the `Exec=` line accordingly.

For example:

```ini
Exec=/home/USERNAME/bin/overmind-vdesktop-wallpaper.sh
```

Make it executable:

```bash
chmod +x \
  ~/.config/autostart/overmind-vdesktop-wallpaper.desktop
```

The entry should now appear under:

```text
System Settings
-> Autostart
```

---

# 5. SDDM Login Wallpaper

The tested Kubuntu SDDM theme is:

```text
/usr/share/sddm/themes/kubuntu
```

Its default wallpaper is:

```text
/usr/share/sddm/themes/kubuntu/kubuntu_2604-gear-dark-horiz.png
```

Back up the original:

```bash
sudo cp \
  /usr/share/sddm/themes/kubuntu/kubuntu_2604-gear-dark-horiz.png \
  /usr/share/sddm/themes/kubuntu/kubuntu_2604-gear-dark-horiz.png.bak
```

Install the Overmind login image:

```bash
sudo cp \
  overmind-login-3840x2160.png \
  /usr/share/sddm/themes/kubuntu/kubuntu_2604-gear-dark-horiz.png
```

Verify the Kubuntu SDDM configuration:

```bash
grep -n 'background=' \
  /usr/share/sddm/themes/kubuntu/theme.conf
```

A reference copy of the working theme configuration is included as:

```text
sddm-theme.conf.reference
```

A future Kubuntu or SDDM package update may restore the stock image.

---

# 6. Firefox

Use:

```text
overmind-firefox-1920x1080.png
```

as the Firefox home / new-tab background.

This version deliberately uses a simpler composition so browser UI remains readable.

---

# 7. Plasma Panel

Install the KDE Plasma widget:

```text
Panel Colorizer
```

via:

```text
Right-click panel
-> Add or Manage Widgets
-> Get New Widgets
-> Search "Panel Colorizer"
```

A good starting colour matching the Overmind browser chrome is:

```text
#18243A
```

Recommended:

```text
Background: #18243A
Opacity:    100%
Border:     Off
```

---

# 8. KDE Window Decorations

The active KDE titlebar can also be matched to the panel.

Navigate to:

```text
System Settings
-> Colours & Themes
-> Colours
-> Edit current colour scheme
```

Set the active title/header background approximately to:

```text
#18243A
```

Use light title text.

Leaving the inactive titlebar darker provides a useful visual indication of the currently focused window.

---

# 9. Testing Boot Changes

When testing GRUB or firmware changes, prefer a full shutdown and cold start:

```bash
sudo shutdown -h now
```

This is especially useful on hardware where warm restarts produce inconsistent UEFI/GOP display behaviour.

---

# Result

The finished configuration provides:

```text
UEFI
  |
  v
GRUB + Overmind background
  |
  v
SDDM + Overmind login artwork
  |
  v
KDE Plasma
  |-- Desktop 1 perspective
  |-- Desktop 2 perspective
  |-- Overmind panel colouring
  `-- Matching active window decoration

Firefox
  `-- Simplified Overmind pyramid artwork
```

The design intentionally keeps native KDE and GRUB interfaces functional and readable while using the artwork as the common visual identity.

**OVERMIND ONLINE.**

**PLEASE REMAIN SUGGESTIBLE.**
