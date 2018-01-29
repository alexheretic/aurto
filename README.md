# aurto
A simple Arch Linux aur tool for managing a local 'aurto' repository with [aurutils](https://github.com/AladW/aurutils).

- Simple `aurto add`, `aurto remove` management of local ***aurto*** repo package.
- Automatic hourly checks & updates aur packages in the ***aurto*** repo.
- Automatic daily checks & updates `*-git` packages in the ***aurto*** repo.
- Uses systemd-nspawn containers to build packages.

# Install
From a plain Arch install, first install **aurutils** from the aur (skip if already installed).
```sh
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/aurutils.tar.gz | tar xz
cd aurutils
gpg --recv-keys DBE7D3DD8C81D58D0A13D0E76BC26A17B9B7018A
makepkg -srci
```

Install **aurto** from the aur.
```sh
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/aurto.tar.gz | tar xz
cd aurto
makepkg -srci
```

# Usage
You add aur packages to your local 'aurto' repo. This is different to installing them.
```sh
aurto add|remove PACKAGES
```
Once added you can install them as normal with pacman.
The packages are automatically updated periodically,
you'll see ***aurto*** updates in the same way as other repos after a `pacman -Syu`.

# Useful commands
View the contents of the ***aurto*** repo, _you may want to `pacman -Sy` first if recently changed_.
```sh
pacman -Sl aurto
```

Check recent auto-update logs.
```sh
journalctl -u update-aurto --since '12 hours ago' -e
```

# Limitations & Security
aurto automatically builds and regularly re-builds updated remote code from the aur.
Code is _built_ in a container, but presumably will eventually be installed to your system.
Only add aur packages from maintainers you trust.

aurto is for simple folk's simple needs. If it can't do what you want uninstall & use [aurutils](https://github.com/AladW/aurutils) directly.
