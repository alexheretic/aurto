# aurto
An Arch Linux AUR tool for managing an auto-updating local 'aurto' package repository using [aurutils](https://github.com/AladW/aurutils).

![](https://image.ibb.co/imkghn/output_4.gif "Usage v0.6")

- Simple `aurto add`, `aurto remove`, `aurto addpkg` management of local ***aurto*** repo packages.
- Automatic on startup & hourly update of aur packages in the ***aurto*** repo.
- Automatic daily update of VCS, ie "*-git", packages in the ***aurto*** repo.
- Maintainer trust system: Package maintainers must be ok-ed before adding into, or auto-updating in, the ***aurto*** repo.
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

Initialise the 'aurto' repo & systemd timers.
```sh
aurto init
```

Recommended: Add **aurto** to the 'aurto' repo to provide self updates.
```sh
aurto add aurto
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
View current packages, logs & info.
```sh
aurto status
```

Add a directory full of built packages to the ***aurto*** repo
```sh
aurto addpkg $(find /path/to/packages/*pkg.tar*)
```

Show no-repo installed packages, these may have not been added to ***aurto*** yet or may have been automatically dropped from ***aurto*** because of maintainer change or removal from the AUR.
```sh
pacman -Qm
```

Rebuild all aur/no-repo packages into the ***aurto*** repo
```sh
aurto add $(pacman -Qqm)
```

# Maintainer Trust
**aurto** uses a system of maintainer trust for limited security. On adding packages with unknown maintainers you'll be asked whether you want to trust these maintainers.
```
$ aurto add spotify
aurto: Trust maintainer(s): AWhetter? [y/N]
```
If you don't say **y** the package is not added.

If any ***aurto*** repo packages change maintainer to an unknown user the packages will be removed from the ***aurto*** repo on the next _update-aurto_ run. A warning will appear in the _update-aurto_ logs
```
WARNING: Packages with unknown maintainers removed from aurto, ...
```
If desired such packages can be re-added and the new maintainers added to the local trusted users.

Local trusted users are stored in `/etc/aurto/trusted-users` initially populated with the aurutils & aurto maintainers.

Clear `/etc/aurto/trusted-users` to trust no-one.<br/>
Remove `/etc/aurto/trusted-users` to trust everyone.

# Config
**aurto** builds packages in a chroot using `/etc/aurto/makepkg-chroot.conf` &  `/etc/aurto/pacman-chroot.conf`.
These can be customized in the same way as the main _makepkg.conf, pacman.conf_, for example to change compression. 

# Running on docker
**aurto** can also be ran on docker to allow for installation on non Arch distros for hosting a aur repo, etc.

You can find the documentation on how to install it [here](./dockerREADME.md).

# Limitations & Security
**aurto** automatically builds and regularly re-builds updated remote code from the aur.
Code is _built_ in a clean chroot, but presumably will eventually be installed to your system.
Take care trusting maintainers.

If aurto can't do what you want use [aurutils](https://github.com/AladW/aurutils) directly.
