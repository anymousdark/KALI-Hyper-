<div align="center">

# 💌 KALI-Hyper: Script de Instalação Hyprland 💌

#### Compatível com Debian 13 (Trixie) e superiores (testing, SID)

<p align="center">
  <img src="https://raw.githubusercontent.com/JaKooLit/Hyprland-Dots/main/assets/latte.png" width="400" />
</p>

![GitHub Repo stars](https://img.shields.io/github/stars/anymousdark/KALI-Hyper-?style=for-the-badge&color=cba6f7) 
![GitHub last commit](https://img.shields.io/github/last-commit/anymousdark/KALI-Hyper-?style=for-the-badge&color=b4befe) 
![GitHub repo size](https://img.shields.io/github/repo-size/anymousdark/KALI-Hyper-?style=for-the-badge&color=cba6f7) 
<a href="https://discord.gg/kool-tech-world"> 
  <img src="https://img.shields.io/discord/1151869464405606400?style=for-the-badge&logo=discord&color=cba6f7">
</a>

<br/>
</div>

<div align="center">
<br>
  <a href="#-aviso-importante"><kbd> <br> Leia Primeiro <br> </kbd></a>&ensp;&ensp;
  <a href="#-como-usar-este-script"><kbd> <br> Instalação <br> </kbd></a>&ensp;&ensp;
  <a href="#-galeria-e-vídeos"><kbd> <br> Galeria <br> </kbd></a>&ensp;&ensp;
</div><br>

<p align="center">
  <img src="https://raw.githubusercontent.com/JaKooLit/Hyprland-Dots/main/assets/latte.png" width="200" />
</p>

<div align="center">
👇 Links relacionados ao Hyprland Dots 👇
<br/>
</div>
<div align="center">
<br>
  <a href="https://github.com/anymousdark/KALI-Hyper-"><kbd> <br> Repositório KALI-Hyper <br> </kbd></a>&ensp;&ensp;
  <a href="https://www.youtube.com/playlist?list=PLDtGd5Fw5_GjXCznR0BzCJJDIQSZJRbxx"><kbd> <br> YouTube <br> </kbd></a>&ensp;&ensp;
  <a href="https://github.com/JaKooLit/Hyprland-Dots/wiki"><kbd> <br> Wiki <br> </kbd></a>&ensp;&ensp;
  <a href="https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds"><kbd> <br> Atalhos <br> </kbd></a>&ensp;&ensp;
  <a href="https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ"><kbd> <br> FAQ <br> </kbd></a>&ensp;&ensp;
  <a href="https://discord.gg/kool-tech-world"><kbd> <br> Discord <br> </kbd></a>
</div><br>

<h3 align="center">
 <img src="https://github.com/JaKooLit/Telegram-Animated-Emojis/blob/main/Activity/Sparkles.webp" alt="Sparkles" width="38" height="38" />
 Demonstração KALI-Hyper Hyprland-Dotfiles
 <img src="https://github.com/JaKooLit/Telegram-Animated-Emojis/blob/main/Activity/Sparkles.webp" alt="Sparkles" width="38" height="38" />
</h3>

### 🎥 Galeria e Vídeos

- [Explicação em vídeo (Fev 2025)](https://youtu.be/wQ70lo7P6vA?si=_QcbrNKh_Bg0L3wC)
- [Playlist Hyprland no YouTube](https://youtube.com/playlist?list=PLDtGd5Fw5_GjXCznR0BzCJJDIQSZJRbxx&si=iaNjLulFdsZ6AV-t)
- [Demonstração AGS](https://youtu.be/zY5SLNPBJTs)

> **IMPORTANTE:** Faça backup do seu sistema com `snapper` ou `timeshift` antes de instalar o Hyprland (**altamente recomendado**).

> **ATENÇÃO:** Baixe este script em um diretório com permissão de escrita, de preferência dentro do seu `$HOME`.

---

## ⚠️ Pré-requisitos

- Não execute o instalador como root.  
- Usuário precisa ter privilégios para instalar pacotes.  
- Debian 13 (Trixie) ou superior.  
- Ative os `deb-src` no `/etc/apt/sources.list`.  
- Para GPUs NVIDIA, habilite drivers não-livres se necessário. Edite `install-scripts/nvidia.sh` para ajustar.

---

## 🚩 Mudando o gerenciador de login para SDDM

```bash
sudo apt install --no-install-recommends -y sddm
sudo dpkg-reconfigure sddm
