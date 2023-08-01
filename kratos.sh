#!/bin/bash
# Logo goes here...
# 
#
### Script that customizes and installs necessary tools for debian linux to start and hacking and bug bounty hunting straight away.
### Coded by D4rkw1ng (Abdelaal Atif) v1.0

# Defining color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 1. Install updates and upgrades
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

# 2. Enable flatpak and add flathub repo to sources
sudo apt install flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 3. Install brave browser from flathub
flatpak install flathub com.brave.Browser -y

# 4. Install thunderbird
sudo apt install thunderbird -y

# 5. Remove debian libreoffice and then install from flathub
sudo apt remove --purge libreoffice* -y
flatpak install flathub org.libreoffice.LibreOffice -y

# 6. Echo in terminal that you can use tasksel command to install other desktop environments
echo "You can use 'tasksel' command to install other desktop environments."

# 7. Prompt user if they want to install Nvidia drivers. If yes then install them.
read -p "Do you want to install Nvidia drivers? (y/n): " nvidia_choice
if [ "$nvidia_choice" == "y" ]; then
    sudo apt install nvidia-driver -y
fi

# 8. Prompt user if they want to install steam for gaming. If yes then install it.
read -p "Do you want to install Steam for gaming? (y/n): " steam_choice
if [ "$steam_choice" == "y" ]; then
    sudo apt install steam -y
fi

# 9. Install multimedia codecs
sudo apt install ubuntu-restricted-extras -y

# 10. Add bookworm backports repo to sources list
echo "deb http://deb.debian.org/debian bookworm-backports main contrib non-free" | sudo tee /etc/apt/sources.list.d/backports.list
sudo apt update

# 11. Install synaptic package manager
sudo apt install synaptic -y

# 12. Install and configure tmux
echo "$YELLOW[*] Installing and configuring tmux...$NC"
sudo apt install tmux -y
cd
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .

echo "Script execution completed!"
