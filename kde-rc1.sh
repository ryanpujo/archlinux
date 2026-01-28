#!/bin/bash

# --- 0. Identify the User ---
# We look for the user with UID 1000 (the first human user created)
TARGET_USER=$(awk -F: '$3 == 1000 {print $1}' /etc/passwd)
USER_HOME="/home/$TARGET_USER"

# Fallback: If UID 1000 isn't found, try grabbing the first folder in /home
if [ -z "$TARGET_USER" ]; then
    TARGET_USER=$(ls /home | grep -v "lost+found" | head -n 1)
    USER_HOME="/home/$TARGET_USER"
fi

if [ -z "$TARGET_USER" ]; then
    echo "Error: No human user (UID 1000) or home directory found!"
    echo "Check if user.sh actually succeeded."
    exit 1
fi

echo "Installing KDE for user: $TARGET_USER"

# --- 1. System Clock & Mirrors ---
# In chroot, we use the binaries directly without sudo
# reflector --country Indonesia,Singapore,Taiwan --age 6 --sort rate --save /etc/pacman.d/mirrorlist

# --- 2. Firewall Setup ---
# Pre-configure firewall for KDE Connect and local networking
systemctl enable firewalld
firewall-cmd --permanent --add-port=1025-65535/tcp
firewall-cmd --permanent --add-port=1025-65535/udp
firewall-cmd --reload

# --- 3. Graphics, Desktop & Core Apps ---
pacman -S --noconfirm xorg xorg-xinit kio-extras kio-fuse plasma-desktop ffmpegthumbs dolphin-plugins konsole sddm \
    firefox vlc docker docker-compose jdk21-openjdk go \
    ark kwrite p7zip unrar xz libreoffice-still dolphin kio

# --- 4. Wine & Gaming (Multilib) ---
pacman -S --noconfirm wine steam lutris gamemode innoextract \
    lib32-giflib lib32-gnutls lib32-v4l-utils lib32-libpulse \
    alsa-plugins lib32-alsa-plugins lib32-alsa-lib lib32-libxcomposite \
    lib32-libxinerama lib32-opencl-icd-loader lib32-gst-plugins-base-libs \
    lib32-sdl2 libgphoto2 sane samba dosbox

# --- 5. Fonts & Themes ---
pacman -S --noconfirm papirus-icon-theme archlinux-wallpaper \
    noto-fonts-emoji noto-fonts-extra ttf-fira-code ttf-jetbrains-mono

# --- 6. AUR Setup & Hardware Detection ---
chmod +x yay.sh p10k.sh hw-det.sh

# Run Hardware detection (drivers)
bash ./hw-det.sh

# Install yay as the TARGET_USER
# We use -H to ensure the home directory environment is set correctly
sudo -u "$TARGET_USER" -H bash ./yay.sh

# --- 7. AUR Packages ---
echo "Installing AUR packages as $TARGET_USER..."
sudo -u "$TARGET_USER" -H yay -S --noconfirm ttf-ms-fonts ttf-meslo-nerd-font-powerlevel10k

# --- 8. Run P10K setup ---
sudo -u "$TARGET_USER" -H bash ./p10k.sh

# --- 9. Konsole Profile Automation ---
KONSOLE_DIR="$USER_HOME/.local/share/konsole"
mkdir -p "$KONSOLE_DIR"

cat <<EOF > "$KONSOLE_DIR/Arch.profile"
[General]
Name=Arch
Parent=FALLBACK/

[Appearance]
Font=MesloLGS NF,12,-1,5,50,0,0,0,0,0
ColorScheme=BreezeDark
EOF

# Force Konsole to use 'Arch.profile' as the Default
mkdir -p "$USER_HOME/.config"
echo -e "[Desktop Entry]\nDefaultProfile=Arch.profile" > "$USER_HOME/.config/konsolerc"

# Fix permissions for everything created in the home folder
chown -R "$TARGET_USER:$TARGET_USER" "$USER_HOME"

# --- 10. Services ---
systemctl enable sddm
systemctl enable docker
usermod -aG docker "$TARGET_USER"
chsh -s /bin/zsh "$TARGET_USER"

echo "--------------------------------------------------"
echo "KDE INSTALL COMPLETE!"
echo "--------------------------------------------------"