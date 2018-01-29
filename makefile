
PREFIX = /usr
build_dist_args?=

all:
	@rm -rf target

	@mkdir -p target/etc/pacman.d
	@cp conf/aurto.pacman.conf target/etc/pacman.d/

	@mkdir -p target$(PREFIX)/bin
	@cp -r bin/* target$(PREFIX)/bin/

	@mkdir -p target$(PREFIX)/lib/aurto
	@cp -r lib/*  target$(PREFIX)/lib/aurto/

	@mkdir -p target$(PREFIX)/lib/systemd/system
	@cp -r timer/* target$(PREFIX)/lib/systemd/system/

	@if command -v tree >/dev/null 2>&1; then tree target; fi
