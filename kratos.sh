# Logo goes here...
# 
#
### Script that customizes and installs necessary tools for debian linux to start and hacking and bug bounty hunting straight away.
### Coded by D4rkw1ng (Abdelaal Atif) v1.0

# 1. Install and configure tmux
cd
git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
