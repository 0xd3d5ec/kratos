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

# 1. Install and configure tmux
echo "$YELLOW[*] Installing and configuring tmux...$NC"
cd
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .

# 2. Install and configure 
echo "$YELLOW[*] Installing some necessary bug bounty tools...$NC"
sudo apt install zaproxy dirsearch feroxbuster subfinder sublist3r ffuf httpx nikto dotdotpwn
echo "$GREEN[+] Bug bounty tools installed successfully.$NC"

