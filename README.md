# Chromebook Setup

- https://old.reddit.com/r/Crostini/wiki/index

## Other things
- https://wiki.archlinux.org/title/bash
- ble.sh, bash-it, ohmybash
- preyproject
- shopt -s histappend 
- Snap install https://chromeunboxed.com/install-snap-packages-chromebook-crostini-linux-how-to/
- Nix
- Developer mode
  - https://www.reddit.com/r/ChromeOSFlex/comments/swxlz8/tutorial_enable_developer_mode_on_cros/
  - https://www.reddit.com/r/ChromeOSFlex/comments/1449a13/guide_reenable_chromeos_flex_developer_mode/

## Useful Chrome extensions
- https://chrome.google.com/webstore/detail/window-shortcut-placer-ch/hcbbigdopjopjofpnpojicpkncepklli
- https://chrome.google.com/webstore/detail/window-relative-position/bkddeedcnaejmjmadijljckjoddhnnfk

## Channel Update
chrome://os-settings/help/details

Beta channel is recommended

## Terminal settings
![image](https://github.com/kkimdev/os-setup/assets/503414/bded2e48-5274-4541-aef7-cdf24a1b9888)


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

# micro
nix profile install nixpkgs#micro

## https://github.com/containers/podman/issues/2542#issuecomment-522932449
sudo touch /etc/sub{u,g}id
sudo usermod --add-subuids 10000-75535 $(whoami)
sudo usermod --add-subgids 10000-75535 $(whoami)
podman system migrate

## https://github.com/containers/podman/issues/11037#issuecomment-947050246
sudo mkdir -p /etc/containers/
printf '[containers]\nkeyring=false\n' | sudo tee /etc/containers/containers.conf

# Required config for podman inside podman.
# See https://www.redhat.com/sysadmin/podman-inside-container and
# https://github.com/containers/podman/issues/11037#issuecomment-947050246
touch /etc/containers/containers.conf
tee /etc/containers/containers.conf << EOF
[containers]
keyring=false
netns="host"
userns="host"
ipcns="host"
utsns="host"
cgroupns="host"
cgroups="disabled"
[engine]
cgroup_manager="cgroupfs"
events_logger="file"
runtime="crun"
EOF

# TODO: We unnecessarily needed `--storage-driver vfs` for nested podmans.
# https://stackoverflow.com/questions/72156494/is-it-possible-to-nest-docker-podman-containers
# TODO: Add this only when it's built as a container image.
touch /etc/containers/storage.conf
tee /etc/containers/storage.conf << EOF
[storage]
# Default Storage Driver, Must be set for proper operation.
driver = "vfs"
# Temporary storage location
runroot = "/run/containers/storage"
# Primary Read/Write location of container storage
graphroot = "/var/lib/containers/storage"
EOF

touch /etc/containers/policy.json
tee /etc/containers/policy.json << EOF
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ]
}
EOF

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
# Theme disabled
# sed -i '/export BASH_IT_THEME=/s/.*/export BASH_IT_THEME="powerline"/' ~/.bashrc
source ~/.bashrc

# starship prompt theme
nix profile install nixpkgs#starship
starship preset tokyo-night -o ~/.config/starship.toml
grep -qxF 'eval "$(starship init bash)"' ~/.bashrc || echo 'eval "$(starship init bash)"' >> ~/.bashrc
source ~/.bashrc

# direnv setup
# https://direnv.net/docs/hook.html
nix profile install nixpkgs#direnv
append_if_not_exist() {
  # https://stackoverflow.com/a/28021305
  grep -xqF -- "$1" "$2" || echo "$1" >> "$2"
}
# shellcheck disable=SC2016  # Intended single quotes
append_if_not_exist 'eval "$(direnv hook bash)"' ~/.bashrc
source ~/.bashrc

# Install fuck
nix profile install nixpkgs#thefuck

```

## Nerd font
- Crostini Terminal: https://www.reddit.com/r/Crostini/comments/s1dgvk/comment/jm9rix7/?utm_source=share&utm_medium=web2x&context=3

```css
/* chrome-untrusted://terminal/html/nassh_preferences_editor.html */

@font-face {
font-family: "JetBrainsMono Nerd Font";
src: url(https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf);
font-weight: normal;
font-style: normal;
}
```

- VS Code: https://stackoverflow.com/a/68972770

```bash
nix profile install nixpkgs#nerdfonts

mkdir -p ~/.config/fontconfig/conf.d/

cat << EOF > ~/.config/fontconfig/conf.d/10-nix-fonts.conf
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
  <dir>~/.nix-profile/share/fonts/</dir>
</fontconfig>
EOF
```
## Github

```bash
# https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
cat ~/.ssh/id_ed25519.pub
# https://github.com/settings/keys

git config --global user.name "..."
git config --global user.email "..." # Use private email from https://github.com/settings/emails
git config --global core.editor 'code --wait --new-window'
git config --global diff.tool diff-code
git config --global difftool.diff-code.cmd 'code --wait --new-window --diff $LOCAL $REMOTE'

```
## Nix upgrade
```
NIXPKGS_ALLOW_UNFREE=1 nix profile upgrade --regex '.*' --impure
nix store gc
```

## [WIP] starship config
```bash
# cat ~/.config/starship.toml

# personal laptop config
format = """
[░▒▓](#a3aed2)\
[  ](bg:#a3aed2 fg:#090c0c)\
[](bg:#769ff0 fg:#a3aed2)\
$directory\
[](fg:#769ff0 bg:#394260)\
$git_branch\
$git_status\
[](fg:#394260 bg:#212736)\
$nodejs\
$rust\
$golang\
$php\
[](fg:#212736 bg:#1d2230)\
$time\
[ ](fg:#1d2230)\
\n$character"""

[directory]
style = "fg:#e3e5e5 bg:#769ff0"
format = "[ $path ]($style)[$read_only]($read_only_style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = " "
"Pictures" = " "

[git_branch]
symbol = ""
style = "bg:#394260"
format = '[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)'

[git_status]
style = "bg:#394260"
format = '[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)'

[nodejs]
symbol = ""
style = "bg:#212736"
format = '[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)'

[rust]
symbol = ""
style = "bg:#212736"
format = '[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)'

[golang]
symbol = ""
style = "bg:#212736"
format = '[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)'

[php]
symbol = ""
style = "bg:#212736"
format = '[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)'

[time]
disabled = false
time_format = "%R" # Hour:Minute Format
style = "bg:#1d2230"
format = '[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)'

# work laptop config
```


