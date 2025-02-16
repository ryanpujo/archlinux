#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector -c Singapore -a 6 --sort rate --save /etc/pacman.d/mirrorlist

sudo firewall-cmd --add-port=1025-65535/tcp --permanent
sudo firewall-cmd --add-port=1025-65535/udp --permanent
sudo firewall-cmd --reload


git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
# you need to enable multilib to install wine
# sudo pacman -Syu wine
# optional dependency for wine
# sudo pacman -Syu lib32-giflib lib32-gnutls lib32-v4l-utils lib32-libpulse alsa-plugins lib32-alsa-plugins lib32-alsa-lib lib32-libxcomposite lib32-libxinerama lib32-opencl-icd-loader lib32-gst-plugins-base-libs lib32-sdl2 libgphoto2 sane samba dosbox

# lutris
# sudo pacman -Syu lutris
# optional dependency for lutris
# sudo pacman -S gamemode innoextract lib32-gamemode lib32-vkd3d python-protobuf vkd3d lib32-vulkan-mesa-layers steam-native-runtime vulkan-mesa-layers

sudo pacman -Syu xorg xorg-xinit xarchiver dconf-editor alacarte arc-gtk-theme arc-solid-gtk-theme accountsservice arc-icon-theme xfce4 xfce4-goodies exo lightdm lightdm-slick-greeter lightdm-gtk-greeter gtk-engine-murrine gtk-engines p7zip unrar xz kitty gst-libav gst-plugin-pipewire gst-plugins-bad gst-plugins-ugly gstreamer-vaapi archlinux-wallpaper firefox vlc papirus-icon-theme mtpfs gvfs-mtp dbeaver docker docker-compose jdk21-openjdk ttf-fira-code go libreoffice-fresh rhythmbox terminus-font powerline-fonts ttf-font-awesome adobe-source-code-pro-fonts ttf-jetbrains-mono noto-fonts noto-fonts-emoji noto-fonts-extra awesome-terminal-fonts thunar-archive-plugin thunar-volman xfce4-pulseaudio-plugin xdg-user-dirs htop gvfs

yay -S jmtpfs visual-studio-code-bin lightdm-settings insomnia-bin ttf-ms-fonts ttf-meslo-nerd-font-powerlevel10k

sudo groupadd docker
sudo usermod -aG docker $USER

sudo systemctl enable lightdm
sudo systemctl enable docker
sudo systemctl enable zramd
