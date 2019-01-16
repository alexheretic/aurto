# Maintainer: Alex Butler <alexheretic@gmail.com>
# Only used for local package testing, see AUR for the actual PKGBUILD
pkgname=aurto
pkgver=###VERSION
pkgrel=999
pkgdesc="A simple aur tool for managing a local 'aurto' repository"
arch=('any')
url="https://github.com/alexheretic/aurto"
license=('MIT')
depends=('aurutils'
         'devtools'
         'systemd'
         'pacutils'
         'pacman-contrib'
         'curl')
optdepends=()
makedepends=('cargo')
install="aurto.install"
source=("aurto-git.tar.gz")
sha256sums=('eb94c0a2920ddea570621da7326f3d60c30401e8c42073b5b3ed3b1216c1ce4b')
backup=('usr/lib/systemd/system/check-aurto-git-trigger.timer'
        'usr/lib/systemd/system/update-aurto.timer'
        'etc/aurto/makepkg-chroot.conf')

build() {
  make
}

package() {
  cp -r target/* "$pkgdir"/
}
