#!/bin/bash

ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
hwclock --systohc
sed -i '171s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "archlinux" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts
echo root:password | chpasswd

# You can add xorg to the installation packages, I usually add it at the DE or WM install script
# You can remove the tlp package if you are installing on a desktop or vm

echo "ParallelDownloads = 5" >> /etc/pacman.conf

# uncomment these 2 lines to enable multilib repository
echo "[multilib]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

pacman -Syu grub grub-btrfs efibootmgr cmake ninja clang networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools base-devel linux-headers linux-atm avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call power-profiles-daemon virt-manager qemu edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld flatpak sof-firmware nss-mdns acpid os-prober ntfs-3g terminus-font

# pacman -S --noconfirm xf86-video-amdgpu
pacman -S --noconfirm nvidia-open nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB #change the directory to /boot/efi is you mounted the EFI partition at /boot/efi

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable power-profiles-daemon.service
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid

useradd -m ryanpujo
echo ryanpujo:password | chpasswd
usermod -aG libvirt ryanpujo

echo "ryanpujo ALL=(ALL) ALL" >> /etc/sudoers.d/ryanpujo


printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"




