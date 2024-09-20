# Maintainer: Alex Butler <alexheretic@gmail.com>
# Only used for local package testing, see AUR for the actual PKGBUILD
pkgname=aurto
pkgver=###VERSION
pkgrel=999
pkgdesc="An AUR tool for managing an auto-updating local 'aurto' package repository using aurutils."
arch=('x86_64' 'aarch64' 'armv7h')
url="https://github.com/alexheretic/aurto"
license=('MIT')
depends=('aurutils'
         'devtools'
         'systemd'
         'pacutils'
         'pacman-contrib'
         'less'
         'sudo'
         'zstd'
         'ninja')
optdepends=()
makedepends=('cargo')
install="aurto.install"
# ring doesn't build with lto enabled: https://github.com/briansmith/ring/issues/1444
options=(!lto)
source=("aurto-git.tar.gz")
sha256sums=('eb94c0a2920ddea570621da7326f3d60c30401e8c42073b5b3ed3b1216c1ce4b')
backup=('usr/lib/systemd/system/check-aurto-git-trigger.timer'
        'usr/lib/systemd/system/update-aurto.timer'
        'usr/lib/systemd/system/update-aurto-startup.timer'
        'etc/aurto/pacman-chroot.conf'
        'etc/aurto/makepkg-chroot.conf')

build() {
  make
}

package() {
  cp -r target/* "$pkgdir"/
}
