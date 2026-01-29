#!/bin/bash

# --- Helper Function for Pauses ---
wait_and_print() {
    printf "\n\e[1;34m[INFO]\e[0m %s...\n" "$1"
    sleep 2
}

# --- 1. Localization & Clock ---
wait_and_print "Configuring system clock, locales, and hostname"
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
wait_and_print "Optimizing Pacman (Parallel Downloads) and enabling Multilib"
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

wait_and_print "Refreshing mirrorlist for Asia (Taiwan/Japan)"
reflector --country Taiwan,Japan --age 6 --sort rate --save /etc/pacman.d/mirrorlist

# --- 3. Base Package Install ---
wait_and_print "Beginning installation of base system and utility packages"
pacman -Syu --noconfirm
pacman -S --noconfirm grub grub-btrfs efibootmgr cmake ninja clang \
    networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools \
    base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils \
    inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa \
    pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call \
    power-profiles-daemon virt-manager qemu-desktop edk2-ovmf iproute2 dnsmasq \
    vde2 openbsd-netcat ipset firewalld flatpak sof-firmware nss-mdns \
    acpid os-prober ntfs-3g terminus-font zsh sudo

# --- 4. Create User ---
wait_and_print "Handing over to user.sh for account creation"
chmod +x user.sh
bash ./user.sh

# --- 0. Identify the User ---
wait_and_print "Detecting the primary system user"
TARGET_USER=$(awk -F: '$3 == 1000 {print $1}' /etc/passwd)
USER_HOME="/home/$TARGET_USER"

if [ -z "$TARGET_USER" ]; then
    TARGET_USER=$(ls /home | grep -v "lost+found" | head -n 1)
    USER_HOME="/home/$TARGET_USER"
fi

if [ -z "$TARGET_USER" ]; then
    printf "\e[1;31m[ERROR]\e[0m No human user found. Check user.sh results.\n"
    exit 1
fi

printf "\e[1;32m[OK]\e[0m User detected: %s\n" "$TARGET_USER"
sleep 1

# --- 5. Hardware & Desktop Environment ---
wait_and_print "Initializing Hardware Detection and KDE Plasma installation"
chmod +x hw-detect.sh kde-rc1.sh
bash ./kde-rc1.sh

# --- 6. Bootloader Configuration ---
wait_and_print "Installing and configuring the GRUB bootloader"
EFI_DIR="/boot"
[ -d "/boot/efi" ] && EFI_DIR="/boot/efi"

grub-install --target=x86_64-efi --efi-directory=$EFI_DIR --bootloader-id=GRUB
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# --- 7. Enable System Services ---
wait_and_print "Enabling essential system services and daemons"
SERVICES=(NetworkManager bluetooth cups sshd avahi-daemon
          power-profiles-daemon reflector.timer fstrim.timer
          libvirtd firewalld acpid)

for service in "${SERVICES[@]}"; do
    echo "Enabling $service..."
    systemctl enable "$service"
done

# --- Final Completion ---
printf "\n\e[1;32m--------------------------------------------------\e[0m\n"
printf "\e[1;32m       ARCH LINUX INSTALLATION COMPLETE!          \e[0m\n"
printf "\e[1;32m--------------------------------------------------\e[0m\n"
printf "Next steps: type 'exit', 'umount -R /mnt', then 'reboot'.\n"