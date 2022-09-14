# os-setup

## Crostini
- https://old.reddit.com/r/Crostini/wiki/index

Other things
- https://wiki.archlinux.org/title/bash
- ble.sh, bash-it, ohmybash
- preyproject
- shopt -s histappend 
- Snap install https://chromeunboxed.com/install-snap-packages-chromebook-crostini-linux-how-to/


```bash
# Null command at the end to prevent `apt-get` swallowing the following inputs.
# https://serverfault.com/questions/342697/prevent-sudo-apt-get-etc-from-swallowing-pasted-input-to-stdin
sudo apt-get update && sudo apt-get dist-upgrade -y && :

# History arrow search
# https://wiki.archlinux.org/title/bash#History_completion
cat << EOF > ~/.inputrc
# https://codeinthehole.com/tips/the-most-important-command-line-tip-incremental-history-searching-with-inputrc/
"\e[A": history-search-backward
"\e[B": history-search-forward
set show-all-if-ambiguous on
EOF

# Chrome OS shortcuts in Linux apps
# https://www.reddit.com/r/Crostini/wiki/enable-chrome-shortcuts-in-linux-apps
mkdir -p ~/.config/systemd/user/sommelier@.service.d/
mkdir -p ~/.config/systemd/user/sommelier-x@.service.d/

cat << EOF > ~/.config/systemd/user/sommelier@.service.d/cros-sommelier-override.conf
[Service]
Environment="SOMMELIER_ACCELERATORS=Super_L,<Alt>bracketleft,<Alt>bracketright,<Alt>minus,<Alt>equal,<Alt>1,<Alt>2,<Alt>3,<Alt>4,<Alt>5,<Alt>6,<Alt>7,<Alt>8,<Alt>9"
EOF

cp ~/.config/systemd/user/sommelier@.service.d/cros-sommelier-override.conf \
   ~/.config/systemd/user/sommelier-x@.service.d/cros-sommelier-x-override.conf

sudo halt --reboot

# Podman

sudo apt-get install -y podman && :

## https://github.com/containers/podman/issues/2542#issuecomment-522932449
sudo touch /etc/sub{u,g}id
sudo usermod --add-subuids 10000-75535 $(whoami)
sudo usermod --add-subgids 10000-75535 $(whoami)
podman system migrate

## https://github.com/containers/podman/issues/11037#issuecomment-947050246
sudo mkdir -p /etc/containers/
printf '[containers]\nkeyring=false\n' | sudo tee /etc/containers/containers.conf


# VS Code install
# https://code.visualstudio.com/blogs/2020/12/03/chromebook-get-started
# https://code.visualstudio.com/docs/setup/linux
sudo apt-get install -y gnome-keyring && :
sudo apt-get install -y wget gpg && :
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update
sudo apt install code


```
