#!/bin/bash

# 1. Install Oh My Zsh (Unattended mode)
# Without --unattended, this command starts a new Zsh shell and stops this script.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 2. Define ZSH_CUSTOM manually
# Since we are in a bash script, the Zsh variable $ZSH_CUSTOM doesn't exist yet.
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# 3. Clone Plugins & Theme
echo "Cloning plugins and theme..."
git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git clone --depth 1 https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git "$ZSH_CUSTOM/plugins/zsh-autocomplete"
git clone --depth 1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

# 4. Update .zshrc Theme
sed -i 's/^ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

# 5. Update .zshrc Plugins
# Note: I removed the .bak to keep it clean, but kept your list.
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete)/' ~/.zshrc

# 6. Optional: Add the P10K instant prompt & config source (if you have the file)
echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc

echo "Zsh configuration complete! Please run 'zsh' or restart your terminal."
