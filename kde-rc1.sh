#!/bin/bash

# --- Sudo Keep-Alive ---
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# 1. System Clock & Mirrors
sudo timedatectl set-ntp true
sudo hwclock --systohc
# Fixed Reflector list for speed
sudo reflector --country Taiwan,Singapore,"South Korea",thailand,vietnam,"Hong Kong" --age 6 --sort rate --save /etc/pacman.d/mirrorlist

# 2. Firewall Setup
sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload

# 3. External Scripts (yay and p10k)
chmod +x yay.sh p10k.sh hw-det.sh
./yay.sh  # Installed to $HOME/yay-bin


./hw-det.sh

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
yay -S --noconfirm jmtpfs ttf-ms-fonts ttf-meslo-nerd-font-powerlevel10k

# 8. Run P10K setup
./p10k.sh

# 1. Define paths
KONSOLE_DIR="$HOME/.local/share/konsole"
NEW_PROFILE="$KONSOLE_DIR/Arch.profile"
KONSOLE_RC="$HOME/.config/konsolerc"

# 2. Create the directory
mkdir -p "$KONSOLE_DIR"

# 3. Create the NEW profile (Arch.profile)
# This bypasses the read-only default profile entirely.
cat <<EOF > "$NEW_PROFILE"
[General]
Name=Arch
Parent=FALLBACK/

[Appearance]
Font=MesloLGS NF,12,-1,5,50,0,0,0,0,0
ColorScheme=BreezeDark
EOF

# 4. Force Konsole to use 'Arch.profile' as the Default
# We edit the global konsolerc file to point to our new creation.
mkdir -p "$HOME/.config"
if [ ! -f "$KONSOLE_RC" ]; then
    echo -e "[Desktop Entry]\nDefaultProfile=Arch.profile" > "$KONSOLE_RC"
else
    # Remove any existing DefaultProfile lines and add the correct one
    sed -i '/DefaultProfile=/d' "$KONSOLE_RC"
    echo -e "[Desktop Entry]\nDefaultProfile=Arch.profile" >> "$KONSOLE_RC"
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
