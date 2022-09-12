# os-setup

## Crostini
- https://old.reddit.com/r/Crostini/wiki/index

Other things
- https://wiki.archlinux.org/title/bash
-  Arrow history, ble.sh, bash-it, ohmybash
- preyproject

```
sudo apt-get update && sudo apt-get dist-upgrade -y

# History arrow search
# https://wiki.archlinux.org/title/bash#History_completion
cat << EOF > ~/.inputrc
"\e[A": history-search-backward
"\e[B": history-search-forward
EOF

# Chrome OS shortcuts in Linux apps
# https://www.reddit.com/r/Crostini/wiki/enable-chrome-shortcuts-in-linux-apps
mkdir -p ~/.config/systemd/user/sommelier@.service.d/
mkdir -p ~/.config/systemd/user/sommelier-x@.service.d/

cat << EOF > ~/.config/systemd/user/sommelier@.service.d/cros-sommelier-override.conf
[Service]
Environment="SOMMELIER_ACCELERATORS=Super_L,<Alt>bracketleft,<Alt>bracketright,<Alt>minus,<Alt>equal,<Alt>1,<Alt>2,<Alt>3,<Alt>4,<Alt>5,<Alt>6,<Alt>7,<Alt>8,<Alt>9"
EOF

cp ~/.config/systemd/user/sommelier@.service.d/cros-sommelier-override.conf ~/.config/systemd/user/sommelier-x@.service.d/cros-sommelier-override.conf


# Podman

sudo apt-get install -y podman

## https://github.com/containers/podman/issues/2542#issuecomment-522932449
sudo touch /etc/sub{u,g}id
sudo usermod --add-subuids 10000-75535 $(whoami)
sudo usermod --add-subgids 10000-75535 $(whoami)
podman system migrate

## https://github.com/containers/podman/issues/11037#issuecomment-947050246
printf '[containers]\nkeyring=false\n' | sudo tee /etc/containers/containers.conf
```
