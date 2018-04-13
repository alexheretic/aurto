# Maintainer: Alex Butler <alexheretic@gmail.com>
pkgname=aurto
pkgver=###VERSION
pkgrel=999
pkgdesc="A simple aur tool for managing a local 'aurto' repository"
arch=('any')
url="https://github.com/alexheretic/aurto"
license=('MIT')
depends=('aurutils<1.6.0'
         'devtools'
         'systemd'
         'pacutils')
optdepends=()
makedepends=()
install="aurto.install"
source=("aurto-git.tar.gz")
sha256sums=('eb94c0a2920ddea570621da7326f3d60c30401e8c42073b5b3ed3b1216c1ce4b')

build() {
  make
}

package() {
  cp -r target/* "$pkgdir"/
}
