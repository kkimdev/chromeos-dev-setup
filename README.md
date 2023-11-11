# os-setup

## Crostini
- https://old.reddit.com/r/Crostini/wiki/index

Other things
- https://wiki.archlinux.org/title/bash
- ble.sh, bash-it, ohmybash
- preyproject
- shopt -s histappend 
- Snap install https://chromeunboxed.com/install-snap-packages-chromebook-crostini-linux-how-to/
- Nix
- Developer mode
  - https://www.reddit.com/r/ChromeOSFlex/comments/swxlz8/tutorial_enable_developer_mode_on_cros/
  - https://www.reddit.com/r/ChromeOSFlex/comments/1449a13/guide_reenable_chromeos_flex_developer_mode/

Useful Chrome extensions
- https://chrome.google.com/webstore/detail/window-shortcut-placer-ch/hcbbigdopjopjofpnpojicpkncepklli
- https://chrome.google.com/webstore/detail/window-relative-position/bkddeedcnaejmjmadijljckjoddhnnfk

```bash
# Null command at the end to prevent `apt-get` swallowing the following inputs.
# https://serverfault.com/questions/342697/prevent-sudo-apt-get-etc-from-swallowing-pasted-input-to-stdin
sudo apt-get update && sudo apt-get dist-upgrade -y && :

# command-not-found
sudo apt-get install command-not-found -y && sudo apt update

# Chrome OS shortcuts in Linux apps
# https://www.reddit.com/r/Crostini/wiki/enable-chrome-shortcuts-in-linux-apps
mkdir -p ~/.config/systemd/user/sommelier@.service.d/
mkdir -p ~/.config/systemd/user/sommelier-x@.service.d/

cat << EOF > ~/.config/systemd/user/sommelier@.service.d/cros-sommelier-override.conf
[Service]
Environment="SOMMELIER_ACCELERATORS=Super_L,<Alt>bracketleft,<Alt>bracketright,<Alt>minus,<Alt>equal,<Alt>1,<Alt>2,<Alt>3,<Alt>4,<Alt>5,<Alt>6,<Alt>7,<Alt>8,<Alt>9,print"
EOF

cp ~/.config/systemd/user/sommelier@.service.d/cros-sommelier-override.conf \
   ~/.config/systemd/user/sommelier-x@.service.d/cros-sommelier-x-override.conf

sudo halt --reboot


# Nix install
# https://github.com/DeterminateSystems/nix-installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
# https://nixos.org/manual/nix/stable/command-ref/conf-file.html
mkdir -p ~/.config/nix/
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

## Nix on Crostini
## https://nixos.wiki/wiki/Installing_Nix_on_Crostini
mkdir -p ~/.config/systemd/user/cros-garcon.service.d/
cat > ~/.config/systemd/user/cros-garcon.service.d/override.conf <<EOF
[Service]
Environment="PATH=%h/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/local/games:/usr/sbin:/usr/bin:/usr/games:/sbin:/bin"
Environment="XDG_DATA_DIRS=%h/.nix-profile/share:%h/.local/share:/usr/local/share:/usr/share"
EOF

# VS Code
NIXPKGS_ALLOW_UNFREE=1 nix profile install nixpkgs#vscode --impure

# Podman
nix profile install nixpkgs#podman

## https://github.com/containers/podman/issues/2542#issuecomment-522932449
sudo touch /etc/sub{u,g}id
sudo usermod --add-subuids 10000-75535 $(whoami)
sudo usermod --add-subgids 10000-75535 $(whoami)
podman system migrate

## https://github.com/containers/podman/issues/11037#issuecomment-947050246
sudo mkdir -p /etc/containers/
printf '[containers]\nkeyring=false\n' | sudo tee /etc/containers/containers.conf


# History arrow search
# https://wiki.archlinux.org/title/bash#History_completion
cat << EOF > ~/.inputrc
# https://codeinthehole.com/tips/the-most-important-command-line-tip-incremental-history-searching-with-inputrc/
"\e[A": history-search-backward
"\e[B": history-search-forward
set show-all-if-ambiguous on
EOF


# Bash-it
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
cd ~/.bash_it
git fetch --tags
git checkout "$(git describe --tags "$(git rev-list --tags --max-count=1)")"
cd ..
~/.bash_it/install.sh --silent --append-to-config
sed -i '/export BASH_IT_THEME=/s/.*/export BASH_IT_THEME="powerline"/' ~/.bashrc
# shellcheck disable=SC1090  # ~/.bashrc is generated.
source ~/.bashrc

```
