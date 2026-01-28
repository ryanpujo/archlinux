#!/bin/bash

# --- 1. CPU Microcode (Physical Only) ---
echo "Detecting CPU for microcode..."
if grep -q "GenuineIntel" /proc/cpuinfo; then
    echo "Intel CPU detected."
     pacman -S --noconfirm intel-ucode
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    echo "AMD CPU detected."
     pacman -S --noconfirm amd-ucode
fi

# --- 2. Virtualization Detection ---
# We check this first because VMs often report "dummy" GPU info
VIRT=$(systemd-detect-virt)

if [ "$VIRT" != "none" ]; then
    echo "Virtual Environment Detected: $VIRT"
    case "$VIRT" in
        kvm|qemu)
            echo "Installing QEMU/KVM Guest Tools..."
             pacman -S --noconfirm qemu-guest-agent spice-vdagent xf86-video-qxl mesa
             systemctl enable qemu-guest-agent
            ;;
        oracle|virtualbox)
            echo "Installing VirtualBox Guest Tools..."
             pacman -S --noconfirm virtualbox-guest-utils
             systemctl enable vboxservice
            ;;
        *)
            echo "Generic VM detected, installing standard Mesa drivers..."
             pacman -S --noconfirm mesa
            ;;
    esac
else
    # --- 3. Physical GPU Drivers ---
    echo "Physical Hardware Detected. Scanning GPU..."
    GPU_TYPE=$(lspci | grep -E "VGA|3D" | tr '[:upper:]' '[:lower:]')

    if echo "$GPU_TYPE" | grep -q "nvidia"; then
        echo "NVIDIA GPU detected."
        # Note: nvidia-open is for Turing (RTX 20xx) or newer.
        # Use 'nvidia' for older cards.
         pacman -S --noconfirm nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings
    elif echo "$GPU_TYPE" | grep -q "amd"; then
        echo "AMD GPU detected."
         pacman -S --noconfirm xf86-video-amdgpu mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
    elif echo "$GPU_TYPE" | grep -q "intel"; then
        echo "Intel GPU detected."
         pacman -S --noconfirm mesa lib32-mesa vulkan-intel lib32-vulkan-intel
    fi
fi

echo "Hardware detection and driver installation complete."
