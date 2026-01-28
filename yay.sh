#!/bin/bash

# 1. Safety Check: Ensure the script is NOT run as root
if [[ $EUID -eq 0 ]]; then
   echo "Error: yay cannot be built as root. Please run as a normal user."
   exit 1
fi

# 2. Check and Install yay
if ! command -v yay &> /dev/null; then
    echo "Building yay-bin..."

    # Use /tmp for building to keep the home directory clean
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$BUILD_DIR"

    cd "$BUILD_DIR" || exit

    # Build and install
    # --needed prevents re-installing base-devel dependencies
    makepkg -si --noconfirm

    # Clean up
    cd ~ || exit
    rm -rf "$BUILD_DIR"

    echo "yay-bin installed successfully."
else
    echo "yay is already installed. Skipping..."
fi
