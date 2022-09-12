# os-setup

## Crostini
```
sudo apt-get update && sudo apt-get dist-upgrade -y

# Podman
## https://github.com/containers/podman/issues/2542#issuecomment-522932449
sudo touch /etc/sub{u,g}id
sudo usermod --add-subuids 10000-75535 $(whoami)
sudo usermod --add-subgids 10000-75535 $(whoami)
podman system migrate

# https://github.com/containers/podman/issues/11037#issuecomment-947050246
printf '[containers]\nkeyring=false\n' | sudo tee /etc/containers/containers.conf
```

Other things:
- https://wiki.archlinux.org/title/bash
-  Arrow history, ble.sh, bash-it, ohmybash
- ChromsOS shortcut in Linux apps https://www.reddit.com/r/Crostini/wiki/enable-chrome-shortcuts-in-linux-apps
- preyproject
