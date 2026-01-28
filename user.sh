# --- 1. User Creation & Password Prompt ---
read -p "Enter username: " NEW_USER
useradd -m -G wheel,libvirt,storage,power -s /bin/zsh "$NEW_USER"

echo "Setting password for $NEW_USER..."
passwd "$NEW_USER"

# --- 2. Root Password Logic ---
echo ""
read -p "Should the root password be the same as $NEW_USER's? (y/n): " SAME_PASS

if [[ "$SAME_PASS" =~ ^[Yy]$ ]]; then
    # We use 'sh -c' to pass the password securely via a pipe from the user's input
    # This requires 'sudo' or being in a chroot environment
    echo "Syncing root password with $NEW_USER..."
    # This grabs the encrypted hash from the new user and applies it to root
    USER_HASH=$(grep "^$NEW_USER:" /etc/shadow | cut -d: -f2)
    usermod -p "$USER_HASH" root
else
    echo "Setting a unique password for root..."
    passwd root
fi

# Set up sudo permissions for the new user
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
