#!/bin/bash

# --- 1. Localization & Clock ---
echo "Setting up time and locales..."
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
hwclock --systohc
sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "archlinux" > /etc/hostname

cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain archlinux
EOF

# --- 2. System Tweaks ---
# Speed up pacman and enable multilib for gaming/32-bit apps
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

reflector --country Taiwan,Japan --age 6 --sort rate --save /etc/pacman.d/mirrorlist

# --- 3. Base Package Install ---
echo "Installing base system packages..."
pacman -Syu --noconfirm
pacman -S --noconfirm grub grub-btrfs efibootmgr cmake ninja clang \
    networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools \
    base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils \
    inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa \
    pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call \
    power-profiles-daemon virt-manager qemu-desktop edk2-ovmf iproute2 dnsmasq \
    vde2 openbsd-netcat ipset firewalld flatpak sof-firmware nss-mdns \
    acpid os-prober ntfs-3g terminus-font zsh sudo git

# --- 4. Create User (Critical: Must happen before KDE/AUR) ---
# This script will prompt for username and passwords
chmod +x user.sh
bash ./user.sh

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

echo "User detected: $TARGET_USER"

# --- 5. Hardware & Desktop Environment ---
# These scripts use the user created above for AUR/Driver tasks
chmod +x hw-detect.sh kde-rc1.sh
bash ./kde-rc1.sh

# --- 6. Bootloader Configuration ---
echo "Configuring GRUB..."
EFI_DIR="/boot"
[ -d "/boot/efi" ] && EFI_DIR="/boot/efi"

grub-install --target=x86_64-efi --efi-directory=$EFI_DIR --bootloader-id=GRUB
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# --- 7. Enable System Services ---
SERVICES=(NetworkManager bluetooth cups sshd avahi-daemon
          power-profiles-daemon reflector.timer fstrim.timer
          libvirtd firewalld acpid)

for service in "${SERVICES[@]}"; do
    systemctl enable "$service"
done

printf "\e[1;32m--------------------------------------------------\e[0m\n"
printf "\e[1;32mARCH LINUX INSTALLATION COMPLETE!\e[0m\n"
printf "\e[1;32mType: exit, umount -R /mnt, then reboot.\e[0m\n"
printf "\e[1;32m--------------------------------------------------\e[0m\n"