#!/bin/bash

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector -c Taiwan -a 6 --sort rate --save /etc/pacman.d/mirrorlist

sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload


# git clone https://aur.archlinux.org/yay-bin.git
# cd yay-bin
# makepkg -si
sudo chmod +x yay.sh
./yay.sh

# you need to enable multilib to install wine
sudo pacman -Syu wine
# optional dependency for wine
 sudo pacman -Syu lib32-giflib lib32-gnutls lib32-v4l-utils lib32-libpulse alsa-plugins lib32-alsa-plugins lib32-alsa-lib lib32-libxcomposite lib32-libxinerama lib32-opencl-icd-loader lib32-gst-plugins-base-libs lib32-sdl2 libgphoto2 sane samba dosbox

# lutris
 sudo pacman -Syu lutris steam
# optional dependency for lutris
sudo pacman -S gamemode innoextract lib32-gamemode lib32-vkd3d python-protobuf vkd3d lib32-vulkan-mesa-layers vulkan-mesa-layers

sudo pacman -Syu xorg xorg-xinit plasma konsole sddm ark kwrite p7zip unrar xz libreoffice-still gst-libav gst-plugin-pipewire gst-plugins-bad gst-plugins-ugly gstreamer-vaapi archlinux-wallpaper firefox vlc vlc-plugin-ffmpeg papirus-icon-theme mtpfs gvfs-mtp dbeaver docker docker-compose jdk21-openjdk ttf-fira-code go rhythmbox terminus-font powerline-fonts ttf-font-awesome adobe-source-code-pro-fonts ttf-jetbrains-mono noto-fonts noto-fonts-emoji noto-fonts-extra awesome-terminal-fonts

yay -S jmtpfs intellij-idea-ultimate-edition visual-studio-code-bin insomnia-bin ttf-ms-fonts ttf-meslo-nerd-font-powerlevel10k

sudo chmod +x p10k.sh

./p10k.sh

sudo groupadd docker
sudo usermod -aG docker $USER

sudo systemctl enable sddm
sudo systemctl enable docker
