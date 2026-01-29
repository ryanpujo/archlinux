#!/bin/bash

# --- Helper Function for Visuals ---
status_msg() {
    printf "\n\e[1;36m>> [PROCESS]\e[0m %s...\n" "$1"
    sleep 1.5
}

# --- 0. Identify the User ---
status_msg "Identifying primary system user"
TARGET_USER=$(awk -F: '$3 == 1000 {print $1}' /etc/passwd)
USER_HOME="/home/$TARGET_USER"

if [ -z "$TARGET_USER" ]; then
    TARGET_USER=$(ls /home | grep -v "lost+found" | head -n 1)
    USER_HOME="/home/$TARGET_USER"
fi

if [ -z "$TARGET_USER" ]; then
    printf "\e[1;31m[!] Error:\e[0m No human user found. Aborting.\n"
    exit 1
fi

printf "\e[1;32m[OK]\e[0m Target User: %s\n" "$TARGET_USER"

# --- 2. Firewall Setup ---
status_msg "Configuring Firewalld for KDE Connect and local networking"
firewall-cmd --permanent --add-port=1025-65535/tcp
firewall-cmd --permanent --add-port=1025-65535/udp
firewall-cmd --reload

# --- 3. Graphics, Desktop & Core Apps ---
status_msg "Installing Plasma Desktop, Firefox, and Development tools"
pacman -S --noconfirm xorg xorg-xinit kio-extras kio-fuse plasma-desktop ffmpegthumbs dolphin-plugins konsole sddm \
    firefox vlc docker docker-compose jdk21-openjdk go \
    ark kwrite p7zip unrar xz libreoffice-still dolphin kio

# --- 4. Wine & Gaming (Multilib) ---
status_msg "Deploying Wine, Steam, and Gaming dependencies"
pacman -S --noconfirm wine steam lutris gamemode innoextract \
    lib32-giflib lib32-gnutls lib32-v4l-utils lib32-libpulse \
    alsa-plugins lib32-alsa-plugins lib32-alsa-lib lib32-libxcomposite \
    lib32-libxinerama lib32-opencl-icd-loader lib32-gst-plugins-base-libs \
    lib32-sdl2 libgphoto2 sane samba dosbox

# --- 5. Fonts & Themes ---
status_msg "Installing system fonts and Papirus icon theme"
pacman -S --noconfirm papirus-icon-theme archlinux-wallpaper \
    noto-fonts-emoji noto-fonts-extra ttf-fira-code ttf-jetbrains-mono

# --- 6. AUR Setup & Hardware Detection ---
status_msg "Running hardware-specific driver detection"
chmod +x yay.sh p10k.sh hw-det.sh
bash ./hw-det.sh

status_msg "Installing 'yay' AUR Helper for $TARGET_USER"
sudo -u "$TARGET_USER" -H bash ./yay.sh

# --- 7. AUR Packages ---
status_msg "Fetching Microsoft and Nerd fonts from AUR"
sudo -u "$TARGET_USER" -H yay -S --noconfirm ttf-ms-fonts ttf-meslo-nerd-font-powerlevel10k

# --- 8. Run P10K setup ---
status_msg "Setting up Powerlevel10k ZSH theme"
sudo -u "$TARGET_USER" -H bash ./p10k.sh

# --- 9. Konsole Profile Automation ---
status_msg "Customizing Konsole profile and font defaults"
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

mkdir -p "$USER_HOME/.config"
echo -e "[Desktop Entry]\nDefaultProfile=Arch.profile" > "$USER_HOME/.config/konsolerc"

status_msg "Finalizing file permissions for $USER_HOME"
chown -R "$TARGET_USER:$TARGET_USER" "$USER_HOME"

# --- 10. Services ---
status_msg "Enabling SDDM and Docker services"
systemctl enable sddm
systemctl enable docker
usermod -aG docker "$TARGET_USER"
chsh -s /bin/zsh "$TARGET_USER"

printf "\n\e[1;32m--------------------------------------------------\e[0m\n"
printf "\e[1;32m       KDE PLASMA INSTALLATION COMPLETE!          \e[0m\n"
printf "\e[1;32m--------------------------------------------------\e[0m\n"