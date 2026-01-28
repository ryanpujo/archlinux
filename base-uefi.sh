#!/bin/bash

# 1. Localization & Clock
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

# 2. System Tweaks
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

chmod +x kde-rc1.sh user.sh

# Fixed Reflector list for speed
reflector --country Taiwan, "South Korea",thailand,vietnam,"Hong Kong" --age 6 --sort rate --save /etc/pacman.d/mirrorlist

# 3. Base Package Install
pacman -Syu --noconfirm
pacman -S --noconfirm grub grub-btrfs efibootmgr cmake ninja clang \
networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools \
base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils \
inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa \
pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call \
power-profiles-daemon virt-manager qemu-desktop edk2-ovmf bridge-utils dnsmasq \
vde2 openbsd-netcat iptables-nft ipset firewalld flatpak sof-firmware nss-mdns \
acpid os-prober ntfs-3g terminus-font zsh sudo

./user.sh
./kde-rc1.sh

# 5. Bootloader
# Check for EFI directory
EFI_DIR="/boot"
[ -d "/boot/efi" ] && EFI_DIR="/boot/efi"

grub-install --target=x86_64-efi --efi-directory=$EFI_DIR --bootloader-id=GRUB
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg


SERVICES=(NetworkManager bluetooth cups sshd avahi-daemon
          power-profiles-daemon reflector.timer fstrim.timer
          libvirtd firewalld acpid)

for service in "${SERVICES[@]}"; do
    systemctl enable "$service"
done

printf "\e[1;32mInstallation complete! Exit, umount -R /mnt, and reboot.\e[0m\n"
