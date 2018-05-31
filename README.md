# aurto
An Arch Linux AUR tool for managing an auto-updating local 'aurto' package repository using [aurutils](https://github.com/AladW/aurutils).

![](https://image.ibb.co/imkghn/output_4.gif "Usage v0.6")

- Simple `aurto add`, `aurto remove`, `aurto addpkg` management of local ***aurto*** repo packages.
- Automatic on startup & hourly update of aur packages in the ***aurto*** repo.
- Automatic daily update of `*-git` packages in the ***aurto*** repo.
- Uses _makechrootpkg_ to build packages isolated from the main system.
- Automatic removal of packages no longer in the AUR from the ***aurto*** repo.
- Automatic removal of packages with unknown/distrusted maintainers from the ***aurto*** repo.

# Install
From a plain Arch install, first install **aurutils** from the aur (skip if already installed).
```sh
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/aurutils.tar.gz | tar xz
cd aurutils
gpg --recv-keys DBE7D3DD8C81D58D0A13D0E76BC26A17B9B7018A
makepkg -srci
```

Install **aurto** from [the aur](https://aur.archlinux.org/packages/aurto).
```sh
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/aurto.tar.gz | tar xz
cd aurto
makepkg -srci

```

Optional: Add the **aurto** itself to the 'aurto' repo using the package you just built.
```sh
aurto addpkg aurto*pkg.tar*
```

# Usage
You add aur packages to your local 'aurto' repo. This is different to installing them.
```sh
aurto add|addpkg|remove PACKAGES
```
Once added you can install them as normal with pacman.
The packages are automatically updated periodically,
you'll see ***aurto*** updates in the same way as other repos after a `pacman -Syu`.

# Useful commands
View the contents of the ***aurto*** repo.
```sh
pacman -Sl aurto
```

Check recent automatic update logs.
```sh
journalctl -eu update-aurto
```

Add a directory full of built packages to the ***aurto*** repo
```sh
aurto addpkg $(find /path/to/packages/*pkg.tar*)
```

Show repo-less installed packages, these may have not been added to ***aurto*** yet or may have been automatically dropped from ***aurto*** because of maintainer change or removal from the AUR.
```sh
pacman -Qm
```

Rebuild all orphans packages into the ***aurto*** repo
```sh
aurto add $(pacman -Qqm)
```

# Maintainer Trust
**aurto** uses a system of maintainer trust for limited security. On adding packages with unknown maintainers you'll be asked whether you want to trust these maintainers.
```
$ aurto add spotify
aurto: Trust maintainer(s): AWhetter? [y/N]
```
If not the package will _not_ be added to the ***aurto*** repo.

If any ***aurto*** repo packages changes maintainer to an unknown maintainer they will be removed from the ***aurto*** repo on the next _update-aurto_ run. A warning will appear in the _update-aurto_ logs
```
WARNING: Packages with unknown maintainers removed from aurto, ...
```
If desired such packages can be re-added and the new maintainer added to the local trusted users.

Local trusted users are stored in `/etc/aurto/trusted-users` initially populated with the [Arch Linux Trusted Users](https://wiki.archlinux.org/index.php/Trusted_Users#Active_Trusted_Users) & me.

Clear `/etc/aurto/trusted-users` to trust no-one.<br/>
Remove `/etc/aurto/trusted-users` to trust everyone.

# Limitations & Security
**aurto** automatically builds and regularly re-builds updated remote code from the aur.
Code is _built_ in a clean chroot, but presumably will eventually be installed to your system.
Take care trusting maintainers.

If aurto can't do what you want use [aurutils](https://github.com/AladW/aurutils) directly.
