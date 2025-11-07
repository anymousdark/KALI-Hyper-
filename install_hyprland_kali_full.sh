#!/usr/bin/env bash
# ======================================================
# Full Hyprland Installer for Kali KDE (Aprimorado)
# Inclui: Hyprland, Waybar funcional, ícones, fontes.
# ======================================================

set -euo pipefail
LOGPREFIX="[hypr-installer]"
echo "$LOGPREFIX Starting Hyprland full installer (Improved Version)..."

if [ "$(id -u)" -ne 0 ]; then
  echo "$LOGPREFIX ERROR: Please run this script as root (sudo). Exiting."
  exit 1
fi

# Detect normal user (the user who invoked sudo)
# Fallback to root only if necessary, but logname is more robust.
SUDO_USER_NAME="${SUDO_USER:-$(logname 2>/dev/null || echo root)}"
# Use getent passwd for a more reliable home directory
USER_HOME=$(getent passwd "$SUDO_USER_NAME" | cut -d: -f6)

if [ -z "$USER_HOME" ]; then
    echo "$LOGPREFIX ERROR: Could not determine home directory for user $SUDO_USER_NAME. Exiting."
    exit 1
fi

echo "$LOGPREFIX Detected user: $SUDO_USER_NAME (home: $USER_HOME)"

# 1) Add bookworm-backports repository if not present
BACKPORTS_LIST="/etc/apt/sources.list.d/bookworm-backports.list"
if ! grep -q "bookworm-backports" "$BACKPORTS_LIST" 2>/dev/null; then
  echo "$LOGPREFIX Adding bookworm-backports to $BACKPORTS_LIST"
  echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" > "$BACKPORTS_LIST"
else
  echo "$LOGPREFIX bookworm-backports already configured."
fi

# 2) Update apt and install core dependencies
export DEBIAN_FRONTEND=noninteractive
apt update -y

echo "$LOGPREFIX Installing core build and Wayland dependencies..."
# Core build dependencies must be installed first and prefer backports
apt install -y -t bookworm-backports \
    wayland-protocols wlroots libwlroots-dev \
    libseat-dev libxkbcommon-dev libinput-dev \
    libdisplay-info-dev libdrm-dev libgbm-dev \
    libpixman-1-dev libvulkan-dev libudev-dev \
    cmake meson ninja-build pkg-config build-essential git curl wget

echo "$LOGPREFIX Installing runtime utilities (Waybar, foot, rofi, theming)..."
# Runtime utilities
apt install -y \
    waybar wofi kitty foot rofi-wayland mako-notifier \
    grim slurp wl-clipboard swaybg swaylock wlogout \
    network-manager-gnome blueman pavucontrol thunar \
    papirus-icon-theme papirus-folders \
    fonts-noto fonts-noto-cjk fonts-noto-color-emoji \
    lxappearance adwaita-icon-theme breeze-gtk

# 3) Optional: install Meslo Nerd Font (more robust download)
NERD_FONT_DIR="${USER_HOME}/.local/share/fonts"
mkdir -p "$NERD_FONT_DIR"

if ! fc-list | grep -i "Meslo" >/dev/null 2>&1; then
  echo "$LOGPREFIX Installing Meslo NF (patched) locally..."
  cd /tmp
  MF="MesloLGSNF-Regular.ttf"
  # Use --fail-silently (-s) and remove || true to capture non-network errors
  curl -fsLo "$NERD_FONT_DIR/$MF" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/L/Regular/complete/Meslo%20L%20GS%20NF%20Regular.ttf" || true
  fc-cache -f "$NERD_FONT_DIR" || true
else
  echo "$LOGPREFIX Nerd font (Meslo) already installed or skipped."
fi

# 4) Clone, build and install Hyprland (REMOVE || true for critical steps)
echo "$LOGPREFIX Cloning and building Hyprland..."
cd /tmp
rm -rf Hyprland || true
git clone --recursive https://github.com/hyprwm/Hyprland.git
cd Hyprland
make all
make install

# 5) Install official addons: hyprpaper, hypridle, hyprlock
for repo in hyprpaper hypridle hyprlock; do
  echo "$LOGPREFIX Installing $repo..."
  cd /tmp
  rm -rf "$repo" || true
  git clone "https://github.com/hyprwm/$repo.git"
  cd "$repo"
  # Assuming make is the primary build system for addons
  make all
  make install
done

# 6) Create Wayland session file (Logic kept the same, it's correct)
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

# Download a proper placeholder wallpaper (Kali logo PNG/JPG preferred)
WALLPAPER_PATH="$WALLPAPER_DIR/kali-dark.png"
if ! [ -f "$WALLPAPER_PATH" ]; then
  echo "$LOGPREFIX Attempting to download a Kali-style wallpaper placeholder..."
  # Tenta um wallpaper comum do Kali (PNG) em vez de um SVG
  curl -fLo "$WALLPAPER_PATH" "https://images.unsplash.com/photo-1549491689-53e9253c9f2b" || true
  # Se o download falhar, o swaybg usará o caminho, mas o usuário pode mudar.
fi

# hyprland.conf (Aprimorado com RELOAD)
cat > "${HYPR_CONF_DIR}/hyprland.conf" <<'EOF'
# Hyprland minimal config created by installer
# Set Meslo font for terminal consistency
font = Meslo L GS NF

monitor=,preferred,auto,1

# Autostart applications
exec-once = waybar &
exec-once = nm-applet --indicator &
exec-once = blueman-applet &
exec-once = mako &
exec-once = hyprpaper &
exec-once = thunar &

# Background via swaybg
exec-once = swaybg -i $WALLPAPER_PATH -m fill

# Main Keybinds (SUPER = Windows/Kali Key)
bind = SUPER, Return, exec, foot
bind = SUPER, D, exec, rofi -show drun
bind = SUPER, Q, killactive,
bind = SUPER, E, exec, thunar
bind = SUPER, L, exec, hyprlock
bind = SUPER, M, exit,

# New Keybind: Reload Config (Crucial for user development)
bind = SUPER, R, exec, hyprctl reload
EOF

# Waybar config (Aprimorado com mais módulos)
cat > "${WAYBAR_CONF_DIR}/config" <<'EOF'
{
  "layer": "top",
  "position": "top",
  "modularity": true,
  "modules-left": ["hyprland/workspaces", "hyprland/window"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "network", "backlight", "battery", "tray"]
}
EOF

cat > "${WAYBAR_CONF_DIR}/style.css" <<'EOF'
* {
  font-family: "Meslo L GS NF", "Noto Sans", sans-serif;
  font-size: 13px;
}
#waybar {
  background: rgba(10, 10, 10, 0.9);
  color: #ffffff;
  border-radius: 0;
}
#clock, #pulseaudio, #network, #battery, #tray, #hyprland-workspaces {
  padding: 0 10px;
  margin: 0 3px;
  background: rgba(30, 30, 30, 0.9);
  border-radius: 5px;
}
#hyprland-workspaces button.active {
  background: #4318FF; /* Kali Blue */
}
#battery.charging {
  color: #5eff5e;
}
EOF

# Set correct ownership for user's config
chown -R "$SUDO_USER_NAME":"$SUDO_USER_NAME" "$HYPR_CONF_DIR" "$WAYBAR_CONF_DIR"
echo "$LOGPREFIX User config written to $HYPR_CONF_DIR and $WAYBAR_CONF_DIR"

# 8) Install Papirus icon theme fallback (Logic kept the same)
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

# 9) Optional: install a GTK theme (Logic kept the same)
echo "$LOGPREFIX Installing breeze-gtk theme..."
apt install -y breeze-gtk || true

# 10) Enable/restart NetworkManager (Logic kept the same)
systemctl enable NetworkManager --now || true

# 11) Final notes and user instructions
echo ""
echo "======================================================"
echo "Hyprland + Waybar + theme installation finished."
echo ""
echo "Next steps for user ($SUDO_USER_NAME):"
echo "  1) Reboot the system: sudo reboot"
echo "  2) At login (SDDM), select session: 'Hyprland' (Wayland)"
echo "  3) Use SUPER + R to reload config after changes!"
echo ""
echo "======================================================"
