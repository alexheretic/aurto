PREFIX = /usr

all:
	@rm -rf target

	@(cd trust-check && CARGO_INCREMENTAL=0 cargo build --release && strip target/release/trust-check)

	@install -D conf/aurto.pacman.conf target/etc/pacman.d/aurto
	@install -Dm440 conf/50_aurto_passwordless -t target/etc/sudoers.d
	@chmod 750 target/etc/sudoers.d
	@install -Dm644 conf/makepkg-chroot.conf -t target/etc/aurto

	@install -D bin/* -t target$(PREFIX)/bin
	@install -D lib/aurto/* -t target$(PREFIX)/lib/aurto
	@install trust-check/target/release/trust-check -t target$(PREFIX)/lib/aurto
	@install -D timer/* -t target$(PREFIX)/lib/systemd/system

	@install -D completion/bash/aurto target$(PREFIX)/share/bash-completion/completions/aurto
	@install -D completion/fish/aurto.fish target$(PREFIX)/share/fish/completions/aurto.fish
	@install -D completion/zsh/_aurto target$(PREFIX)/share/zsh/site-functions/_aurto

	@if command -v tree >/dev/null 2>&1; then tree target; fi
