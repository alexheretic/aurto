FROM archlinux:base-devel AS build

# Setup sudo user & install dependencies
RUN pacman -Sy --noconfirm git pacutils perl-json-xs devtools pacman-contrib ninja cargo && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    useradd --uid 1000 --shell /bin/bash --groups wheel --create-home build

USER build

WORKDIR /home/build

# Build aurutils & aurto
RUN curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/aurutils.tar.gz | tar xz && \
    cd aurutils && \
    gpg --recv-keys DBE7D3DD8C81D58D0A13D0E76BC26A17B9B7018A && \
    makepkg -i --noconfirm && \
    cd .. && \
    curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/aurto.tar.gz | tar xz && \
    cd aurto && \
    makepkg -i --noconfirm

FROM archlinux:latest

ENV USER_ID="1002" \
    USER=aurto

WORKDIR /

# Remove unnecessary units
RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
  /etc/systemd/system/*.wants/* \
  /lib/systemd/system/local-fs.target.wants/* \
  /lib/systemd/system/sockets.target.wants/*udev* \
  /lib/systemd/system/sockets.target.wants/*initctl* \
  /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
  /lib/systemd/system/systemd-update-utmp*

# Install dependencies and setup sudo user
RUN pacman -Syu --needed --noconfirm base-devel sudo pacman-contrib && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    useradd --uid ${USER_ID} --shell /bin/bash --groups wheel --create-home aurto

WORKDIR /tmp

# Copy aurutils & aurto from build stage
COPY --from=build /home/build/aurutils/aurutils-*.pkg.tar.zst /tmp/
COPY --from=build /home/build/aurto/aurto-*.pkg.tar.zst /tmp/

# Install aurto & aurutils
RUN pacman -U --noconfirm /tmp/aurutils-*.pkg.tar.zst && \
    pacman -U --noconfirm /tmp/aurto-*.pkg.tar.zst && \
    
    # Disable chroot for aurto
    touch /usr/lib/aurto/conf-disable-chroot && \

    # Cleanup
    rm -r /tmp/* && \
    paccache -rk0 && \

    # Setup pacman hook
    mkdir -p /etc/pacman.d/hooks/ && \
    echo -e "[Trigger]\nType = Package\nOperation = Remove\nOperation = Install\nOperation = Upgrade\nTarget = *\n\n[Action]\nDescription = Removing unnecessary cached files (keeping the latest one)...\nWhen = PostTransaction\nExec = /usr/bin/paccache -rk0" > /etc/pacman.d/hooks/pacman-cache-cleanup.hook

WORKDIR /home/aurto

VOLUME ["/tmp", "/run", "/run/lock", "/etc/aurto", "/var/cache/pacman/aurto"]

CMD [ "/lib/systemd/systemd", "log-level=info", "unit=sysinit.target" ]