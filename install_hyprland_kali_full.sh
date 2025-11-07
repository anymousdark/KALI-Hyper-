#!/usr/bin/env bash
# ======================================================
# Full Hyprland Installer for Kali KDE (Automatic)
# Includes: Hyprland, Hyprpaper, Hyprlock, Hypridle
# Waybar + themed config, icons, fonts, wallpapers
# Adds Debian bookworm-backports and installs required packages
#
# Usage:
#   sudo bash install_hyprland_kali_full.sh
#
# WARNING:
#   - Tested conceptually for Kali based on Debian Bookworm.
#   - Run at your own risk. Review the script before running.
# ======================================================

set -euo pipefail
LOGPREFIX="[hypr-installer]"
echo "$LOGPREFIX Starting Hyprland full installer..."

if [ "$(id -u)" -ne 0 ]; then
  echo "$LOGPREFIX Please run this script as root (sudo). Exiting."
  exit 1
fi

# Detect normal user (the user who invoked sudo)
SUDO_USER_NAME="${SUDO_USER:-$(logname 2>/dev/null || echo root)}"
USER_HOME="$(eval echo "~$SUDO_USER_NAME")"
echo "$LOGPREFIX Detected user: $SUDO_USER_NAME (home: $USER_HOME)"

# 1) Add bookworm-backports repository if not present
BACKPORTS_LIST="/etc/apt/sources.list.d/bookworm-backports.list"
if ! grep -q "bookworm-backports" "$BACKPORTS_LIST" 2>/dev/null; then
  echo "$LOGPREFIX Adding bookworm-backports to $BACKPORTS_LIST"
  echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" > "$BACKPORTS_LIST"
else
  echo "$LOGPREFIX bookworm-backports already configured."
fi

# 2) Update apt and install core dependencies (prefer backports for core libs)
export DEBIAN_FRONTEND=noninteractive
apt update -y

echo "$LOGPREFIX Installing core build and Wayland dependencies from bookworm-backports..."
apt install -y -t bookworm-backports \
    wayland-protocols wlroots libwlroots-dev \
    libseat-dev libxkbcommon-dev libinput-dev \
    libdisplay-info-dev libdrm-dev libgbm-dev \
    libpixman-1-dev libvulkan-dev libudev-dev \
    cmake meson ninja-build pkg-config build-essential git curl wget

echo "$LOGPREFIX Installing runtime utilities (Waybar, foot, rofi, etc)..."
apt install -y \
    waybar foot rofi-wayland mako-notifier \
    grim slurp wl-clipboard swaybg swaylock wlogout \
    network-manager-gnome blueman pavucontrol thunar \
    papirus-icon-theme papirus-folders \
    fonts-noto fonts-noto-cjk fonts-noto-color-emoji \
    lxappearance adwaita-icon-theme

# 3) Optional: install Nerd Fonts (Meslo patched) - fallback download
NERD_FONT_DIR="${USER_HOME}/.local/share/fonts"
mkdir -p "$NERD_FONT_DIR"

if ! fc-list | grep -i "Meslo" >/dev/null 2>&1; then
  echo "$LOGPREFIX Installing Meslo NF (patched) locally..."
  cd /tmp
  MF="MesloLGSNF-Regular.ttf"
  # try download from a reliable GitHub mirror (no network guarantees)
  curl -fLo "$NERD_FONT_DIR/$MF" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/L/Regular/complete/Meslo%20L%20GS%20NF%20Regular.ttf" || true
  fc-cache -f "$NERD_FONT_DIR" || true
else
  echo "$LOGPREFIX Nerd font (Meslo) already installed system-wide."
fi

# 4) Clone, build and install Hyprland
echo "$LOGPREFIX Cloning and building Hyprland..."
cd /tmp
rm -rf Hyprland || true
git clone --recursive https://github.com/hyprwm/Hyprland.git
cd Hyprland
# prefer make if available, else use meson
if command -v make >/dev/null 2>&1 && [ -f Makefile ]; then
  make all
  make install
else
  meson setup build
  meson compile -C build
  meson install -C build
fi

# 5) Install official addons: hyprpaper, hypridle, hyprlock
for repo in hyprpaper hypridle hyprlock; do
  echo "$LOGPREFIX Installing $repo..."
  cd /tmp
  rm -rf "$repo" || true
  git clone "https://github.com/hyprwm/$repo.git" || { echo "$LOGPREFIX failed to clone $repo"; continue; }
  cd "$repo"
  if [ -f Makefile ]; then
    make all || true
    make install || true
  else
    meson setup build || true
    meson compile -C build || true
    meson install -C build || true
  fi
done

# 6) Create Wayland session file for SDDM/GDM if not exists
SESSION_FILE="/usr/share/wayland-sessions/hyprland.desktop"
if [ ! -f "$SESSION_FILE" ]; then
  cat > "$SESSION_FILE" <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF
  echo "$LOGPREFIX Created $SESSION_FILE"
else
  echo "$LOGPREFIX Session file already exists: $SESSION_FILE"
fi

# 7) Create user configuration for Hyprland, Waybar, and theme files
HYPR_CONF_DIR="${USER_HOME}/.config/hypr"
WAYBAR_CONF_DIR="${USER_HOME}/.config/waybar"
WALLPAPER_DIR="/usr/share/backgrounds/hypr-kali"
mkdir -p "$HYPR_CONF_DIR" "$WAYBAR_CONF_DIR" "$WALLPAPER_DIR"

# sample wallpaper (try to fetch Kali dark wallpaper, fallback to placeholder)
if ! [ -f "$WALLPAPER_DIR/kali-dark.png" ]; then
  echo "$LOGPREFIX Attempting to download a wallpaper..."
  curl -fLo "$WALLPAPER_DIR/kali-dark.png" "https://www.kali.org/images/kali-logo.svg" || true
fi

# hyprland.conf (basic, safe)
cat > "${HYPR_CONF_DIR}/hyprland.conf" <<'EOF'
# Hyprland minimal config created by installer
monitor=,preferred,auto,1

# Autostart applications
exec-once = waybar &
exec-once = nm-applet --indicator &
exec-once = blueman-applet &
exec-once = mako &
exec-once = hyprpaper &
exec-once = thunar &

# Background via swaybg (fallback)
exec-once = swaybg -i /usr/share/backgrounds/hypr-kali/kali-dark.png -m fill

# Keybinds
bind = SUPER, Return, exec, foot
bind = SUPER, D, exec, rofi -show drun
bind = SUPER, Q, killactive,
bind = SUPER, E, exec, thunar
bind = SUPER, L, exec, hyprlock
bind = SUPER, M, exit,
EOF

# Waybar config: simple top bar with modules
cat > "${WAYBAR_CONF_DIR}/config" <<'EOF'
{
  "layer": "top",
  "position": "top",
  "modules-left": ["sway/workspaces", "sway/mode"],
  "modules-center": ["custom/time"],
  "modules-right": ["network", "pulseaudio", "battery", "temperature", "custom/launcher"]
}
EOF

cat > "${WAYBAR_CONF_DIR}/style.css" <<'EOF'
* {
  font-family: "Meslo L GS NF", "Noto Sans", sans-serif;
  font-size: 12px;
}
#waybar {
  background: rgba(0,0,0,0.5);
  padding: 6px;
}
EOF

# small custom script for waybar time module
mkdir -p "${WAYBAR_CONF_DIR}/scripts"
cat > "${WAYBAR_CONF_DIR}/scripts/time.sh" <<'EOF'
#!/usr/bin/env bash
date "+%a %d %b %H:%M"
EOF
chmod +x "${WAYBAR_CONF_DIR}/scripts/time.sh"

cat > "${WAYBAR_CONF_DIR}/modules/custom/time" <<'EOF'
{
  "format": "{output}",
  "exec": "~/.config/waybar/scripts/time.sh",
  "interval": 60
}
EOF

# Set correct ownership for user's config
chown -R "$SUDO_USER_NAME":"$SUDO_USER_NAME" "$HYPR_CONF_DIR" "$WAYBAR_CONF_DIR"
echo "$LOGPREFIX User config written to $HYPR_CONF_DIR and $WAYBAR_CONF_DIR"

# 8) Install Papirus icon theme fallback via git if apt did not provide it
if ! command -v papirus-folders >/dev/null 2>&1; then
  echo "$LOGPREFIX papirus not found via apt, installing from source..."
  cd /tmp
  rm -rf papirus-icon-theme || true
  git clone https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git || true
  if [ -d "papirus-icon-theme" ]; then
    cd papirus-icon-theme
    ./install-papirus-icon-theme -a || true
  fi
fi

# 9) Optional: install a GTK theme (Breeze Dark) for consistency
echo "$LOGPREFIX Installing breeze-gtk theme..."
apt install -y breeze-gtk || true

# 10) Enable/restart NetworkManager (so nm-applet shows)
systemctl enable NetworkManager --now || true

# 11) Final notes and user instructions
echo ""
echo "======================================================"
echo "Hyprland + Waybar + theme installation finished."
echo ""
echo "Next steps for user ($SUDO_USER_NAME):"
echo "  1) Reboot the system: sudo reboot"
echo "  2) At login (SDDM), select session: 'Hyprland' (Wayland)"
echo "  3) Customize ~/.config/hypr/hyprland.conf and"
echo "     ~/.config/waybar/* as you like (Waybar modules, styles)."
echo ""
echo "Helpful commands:"
echo "  - hyprctl reload          # reload config in-session"
echo "  - hyprctl activeworkspace # show active workspace info"
echo ""
echo "If anything breaks, you can log into KDE (fallback) from SDDM and remove or tweak"
echo "~/.config/hypr/hyprland.conf to restore behavior."
echo "======================================================"
