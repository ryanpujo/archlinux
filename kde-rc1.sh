#!/bin/bash

# --- Sudo Keep-Alive ---
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# 1. System Clock & Mirrors
sudo timedatectl set-ntp true
sudo hwclock --systohc
# Fixed Reflector list for speed
sudo reflector --country Taiwan,Singapore,"South Korea" --age 6 --sort rate --save /etc/pacman.d/mirrorlist

# 2. Firewall Setup
sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload

# 3. External Scripts (yay and p10k)
chmod +x yay.sh p10k.sh
./yay.sh  # Installed to $HOME/yay-bin

# 4. Core Graphics & Apps (Consolidated for faster download)
sudo pacman -Syu --noconfirm xorg xorg-xinit plasma konsole sddm \
    firefox vlc docker docker-compose jdk21-openjdk go \
    ark kwrite p7zip unrar xz libreoffice-still

# 5. Wine & Gaming (Consolidated)
sudo pacman -S --noconfirm wine steam lutris gamemode innoextract \
    lib32-giflib lib32-gnutls lib32-v4l-utils lib32-libpulse \
    alsa-plugins lib32-alsa-plugins lib32-alsa-lib lib32-libxcomposite \
    lib32-libxinerama lib32-opencl-icd-loader lib32-gst-plugins-base-libs \
    lib32-sdl2 libgphoto2 sane samba dosbox

# 6. Fonts & Themes
sudo pacman -S --noconfirm papirus-icon-theme archlinux-wallpaper \
    noto-fonts-emoji noto-fonts-extra ttf-fira-code ttf-jetbrains-mono

# 7. AUR Packages
yay -S --noconfirm jmtpfs intellij-idea-ultimate-edition visual-studio-code-bin \
    insomnia-bin ttf-ms-fonts ttf-meslo-nerd-font-powerlevel10k

# 8. Run P10K setup
./p10k.sh

# 9. Configure Konsole Font
KONSOLE_PROFILE="$HOME/.local/share/konsole/Shell.profile"
mkdir -p "$HOME/.local/share/konsole"
if [ ! -f "$KONSOLE_PROFILE" ]; then
    echo -e "[Appearance]\nFont=MesloLGS NF,12,-1,5,50,0,0,0,0,0" > "$KONSOLE_PROFILE"
else
    if grep -q "^Font=" "$KONSOLE_PROFILE"; then
        sed -i "s/^Font=.*/Font=MesloLGS NF,12,-1,5,50,0,0,0,0,0/" "$KONSOLE_PROFILE"
    else
        echo "Font=MesloLGS NF,12,-1,5,50,0,0,0,0,0" >> "$KONSOLE_PROFILE"
    fi
fi

# 10. Permissions, Shell, and Services
sudo chsh -s /bin/zsh $USER
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable sddm
sudo systemctl enable docker

echo "--------------------------------------------------"
echo "INSTALL COMPLETE! REBOOTING IN 10 SECONDS..."
echo "--------------------------------------------------"
sleep 10
sudo reboot
