# KALI-Hyper-
 Hyprland Installer for Kali Linux + ML4W Dotfiles

Automated installer script to set up **Hyprland** on **Kali Linux**, including essential Wayland utilities, themes, and configurations from [ML4W Dotfiles](https://github.com/mylinuxforwork/dotfiles).

This project allows Kali users to quickly set up a polished Hyprland Wayland session while preserving fallback options and backing up existing user configs.

---

## Features

- Installs **Hyprland** and its core addons:
  - `hyprpaper`, `hypridle`, `hyprlock`
- Installs runtime utilities:
  - Waybar, Wofi, Kitty, Foot, Rofi, Mako, Swaybg, Swaylock
- Installs **Papirus icons**, **Noto fonts** and a NerdFont (Meslo)
- Applies **ML4W dotfiles configuration** (copies `hypr/` and `waybar/`)
- Creates a **Wayland session** for SDDM/GDM
- Backs up existing configs before overwriting

---

## Requirements

- **Kali Linux** (Debian-based)
- `sudo` privileges
- Internet connection
- Recommended: Backup important files before running the installer

---

## Usage

Download the installer script and run it as root:

```bash
# Download the script (replace URL if hosted elsewhere)
wget https://github.com/yourusername/hyprland-kali-ml4w/raw/main/setup_hyprland_kali_ml4w.sh

# Make it executable
chmod +x setup_hyprland_kali_ml4w.sh

# Run as root
sudo ./setup_hyprland_kali_ml4w.sh
```

After installation, **reboot** and select **Hyprland (Wayland)** in your login manager (SDDM/GDM).

---

## Backup

Original Hyprland/Waybar configs will be saved under:

```
~/.config/hypr_backup_YYYYMMDDHHMMSS
```

---

## Contributing

Contributions are welcome. Open issues or pull requests for:
- Adding support for other Debian-based distributions
- Refining package lists and dotfiles integration
- Improving install safety and rollback

---

## Security & Disclaimer

This script installs packages and compiles software on your system. Review the script before running it. Use at your own risk. The author is not responsible for system breakage.

---

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.

---

## Author

aycher kery
