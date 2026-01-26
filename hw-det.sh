# --- Dynamic Driver & Microcode Detection ---
echo "Detecting hardware..."

# 1. CPU Microcode
if grep -q "GenuineIntel" /proc/cpuinfo; then
    sudo pacman -S --noconfirm intel-ucode
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    sudo pacman -S --noconfirm amd-ucode
fi

# 2. GPU Drivers
GPU_TYPE=$(lspci | grep -E "VGA|3D" | tr '[:upper:]' '[:lower:]')

if echo "$GPU_TYPE" | grep -q "nvidia"; then
    echo "NVIDIA GPU detected. Installing proprietary drivers..."
    sudo pacman -S --noconfirm nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings
elif echo "$GPU_TYPE" | grep -q "amd"; then
    echo "AMD GPU detected. Installing Mesa drivers..."
    sudo pacman -S --noconfirm xf86-video-amdgpu mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
elif echo "$GPU_TYPE" | grep -q "intel"; then
    echo "Intel GPU detected. Installing Mesa drivers..."
    sudo pacman -S --noconfirm mesa lib32-mesa vulkan-intel lib32-vulkan-intel
fi
