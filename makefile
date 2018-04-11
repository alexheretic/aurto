PREFIX = /usr

all:
	@rm -rf target

	@install -D conf/aurto.pacman.conf target/etc/pacman.d/aurto
	@install -Dm440 conf/50_aurto_passwordless -t target/etc/sudoers.d
	@chmod 750 target/etc/sudoers.d

	@install -D bin/* -t target$(PREFIX)/bin
	@install -D lib/aurto/* -t target$(PREFIX)/lib/aurto
	@install -D timer/* -t target$(PREFIX)/lib/systemd/system

	@install -D completion/bash/aurto target$(PREFIX)/share/bash-completion/completions/aurto

	@if command -v tree >/dev/null 2>&1; then tree target; fi
