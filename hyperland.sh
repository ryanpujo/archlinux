sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector -c Singapore -a 6 --sort rate --save /etc/pacman.d/mirrorlist

git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd ..

git clone --depth=1 https://github.com/JaKooLit/Arch-Hyprland.git ~/Arch-Hyprland
cd ~/Arch-Hyprland
chmod +x install.sh
./install.sh

sudo pacman -Syu libreoffice-fresh dbeaver docker docker-compose jdk21-openjdk go make ttf-fira-code rhythmbox

yay -S visual-studio-code-bin insomnia-bin ttf-ms-fonts

# you need to enable multilib to install wine
# sudo pacman -Syu wine
# optional dependency for wine
# sudo pacman -Syu lib32-giflib lib32-gnutls lib32-v4l-utils lib32-libpulse alsa-plugins lib32-alsa-plugins lib32-alsa-lib lib32-libxcomposite lib32-libxinerama lib32-opencl-icd-loader lib32-gst-plugins-base-libs lib32-sdl2 libgphoto2 sane samba dosbox

# lutris
# sudo pacman -Syu lutris
# optional dependency for lutris
# sudo pacman -S gamemode innoextract lib32-gamemode lib32-vkd3d python-protobuf vkd3d lib32-vulkan-mesa-layers steam-native-runtime vulkan-mesa-layers 

sudo groupadd docker
sudo usermod -aG docker $USER

sudo systemctl enable docker