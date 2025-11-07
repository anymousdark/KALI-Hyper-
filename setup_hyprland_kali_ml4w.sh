#!/usr/bin/env bash
echo # ======================================================
echo# Hyprland Installer for Kali Linux + ML4W Dotfiles
# Installs Hyprland, addons, Wayland utilities and applies
echo # the dotfiles from https://github.com/mylinuxforwork/dotfiles
# ======================================================

set -euo pipefail
LOG="[hypr-ml4w-installer]"
echo "$LOG Starting Hyprland installation with ML4W dotfiles..."

if [ "$(id -u)" -ne 0 ]; then
  echo "$LOG Please run as root."
  exit 1
fi

USER_NAME="${SUDO_USER:-$(logname 2>/dev/null || echo root)}"
USER_HOME="$(eval echo "~$USER_NAME")"
echo "$LOG User detected: $USER_NAME, home: $USER_HOME"

# 1) Add bookworm-backports repo if missing
BACKPORTS_LIST="/etc/apt/sources.list.d/bookworm-backports.list"
if ! grep -q "bookworm-backports" "$BACKPORTS_LIST" 2>/dev/null; then
    echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free non-free-firmware" > "$BACKPORTS_LIST"
fi

# 2) Update and install dependencies
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt install -y -t bookworm-backports \
    wayland-protocols wlroots libwlroots-dev \
    libseat-dev libxkbcommon-dev libinput-dev \
    libdisplay-info-dev libdrm-dev libgbm-dev \
    libpixman-1-dev libvulkan-dev libudev-dev \
    cmake meson ninja-build pkg-config build-essential git curl wget

# 3) Runtime utilities
apt install -y \
    waybar wofi kitty foot rofi-wayland mako-notifier \
    grim slurp wl-clipboard swaybg swaylock wlogout \
    network-manager-gnome blueman pavucontrol thunar \
    papirus-icon-theme papirus-folders \
    fonts-noto fonts-noto-cjk fonts-noto-color-emoji \
    lxappearance adwaita-icon-theme breeze-gtk

# 4) Install Meslo Nerd Font
NERD_FONT_DIR="${USER_HOME}/.local/share/fonts"
mkdir -p "$NERD_FONT_DIR"
if ! fc-list | grep -i "Meslo" >/dev/null 2>&1; then
    echo "$LOG Installing Meslo NF"
    cd /tmp
    curl -fLo "$NERD_FONT_DIR/MesloLGSNF-Regular.ttf" "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/L/Regular/complete/Meslo%20L%20GS%20NF%20Regular.ttf" || true
    fc-cache -f "$NERD_FONT_DIR" || true
fi

# 5) Clone, build, install Hyprland
cd /tmp
rm -rf Hyprland || true
git clone --recursive https://github.com/hyprwm/Hyprland.git
cd Hyprland
make all && make install || true

# 6) Install Hyprland addons
for repo in hyprpaper hypridle hyprlock; do
    cd /tmp
    rm -rf "$repo" || true
    git clone https://github.com/hyprwm/$repo.git
    cd "$repo"
    make all && make install || true
done

# 7) Create Wayland session
SESSION_FILE="/usr/share/wayland-sessions/hyprland.desktop"
cat > "$SESSION_FILE" <<'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

# 8) Backup existing configs
DOTDIR_BACKUP="${USER_HOME}/.config/hypr_backup_$(date +%Y%m%d%H%M%S)"
mkdir -p "$DOTDIR_BACKUP"
echo "$LOG Backing up existing configs to $DOTDIR_BACKUP"
if [ -d "${USER_HOME}/.config/hypr" ]; then mv "${USER_HOME}/.config/hypr" "$DOTDIR_BACKUP"; fi
if [ -d "${USER_HOME}/.config/waybar" ]; then mv "${USER_HOME}/.config/waybar" "$DOTDIR_BACKUP"; fi

# 9) Clone ML4W dotfiles
cd /tmp
rm -rf dotfiles || true
git clone https://github.com/mylinuxforwork/dotfiles.git
cd dotfiles

# Copy Hyprland and Waybar configs from dotfiles to user config
echo "$LOG Copying Hyprland and Waybar configs from ML4W dotfiles"
mkdir -p "${USER_HOME}/.config/hypr"
mkdir -p "${USER_HOME}/.config/waybar"
cp -r hypr/* "${USER_HOME}/.config/hypr/" 2>/dev/null || true
cp -r waybar/* "${USER_HOME}/.config/waybar/" 2>/dev/null || true

# Set correct ownership
chown -R "$USER_NAME":"$USER_NAME" "${USER_HOME}/.config/hypr" "${USER_HOME}/.config/waybar"

# 10) Enable NetworkManager
systemctl enable NetworkManager --now || true

echo ""
echo "$LOG Installation complete!"
echo "Reboot and select 'Hyprland' session at login."
echo "ML4W dotfiles applied, original configs backed up at $DOTDIR_BACKUP"
