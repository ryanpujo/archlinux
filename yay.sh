# 1. Safety Check: Ensure the script is NOT run as root
if [[ $EUID -eq 0 ]]; then
   echo "Error: Do not run this script as root/sudo. It will ask for your password when needed."
   exit 1
fi

# 2. Check and Install yay in the user's home directory
if ! command -v yay &> /dev/null; then
    echo "Installing yay-bin in $HOME/yay-bin..."

    # Move to home directory to ensure a clean build environment
    cd "$HOME" || exit

    # Clone the repository
    git clone https://aur.archlinux.org/yay-bin.git

    # Enter the folder
    cd yay-bin || exit

    # Build and install (this will prompt for your sudo password)
    makepkg -si --noconfirm

    # Clean up: Go back home and remove the build folder
    cd "$HOME" || exit
    rm -rf "$HOME/yay-bin"

    echo "yay-bin installed successfully."
fi
