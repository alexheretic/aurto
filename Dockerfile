FROM archlinux:base-devel AS build

# Update & setup sudo user
RUN pacman -Syu --noconfirm && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    useradd --uid 1000 --shell /bin/bash --groups wheel --create-home build

USER build

WORKDIR /home/build

# Build aurutils & aurto
RUN curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/aurutils.tar.gz | tar xz && \
    cd aurutils && \
    gpg --recv-keys DBE7D3DD8C81D58D0A13D0E76BC26A17B9B7018A && \
    makepkg -si --noconfirm && \
    cd .. && \
    curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/aurto.tar.gz | tar xz && \
    cd aurto && \
    makepkg -si --noconfirm

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

#init aurto
RUN sed -i 's/--now//g' /usr/lib/aurto/install
RUN echo "Include = /etc/pacman.d/aurto" >> /etc/pacman.conf
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
USER aurto
RUN aurto init

USER root

RUN sudo tee /etc/systemd/system/ensure-aurto.service > /dev/null <<'EOF'
[Unit]
Description=Ensure aurto pacman DB
After=default.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'if [ ! -f /var/cache/pacman/aurto/aurto.db.tar.zst ]; then sudo install -d /var/cache/pacman/aurto -o "aurto" && sudo -u aurto tar acf /var/cache/pacman/aurto/aurto.db.tar.zst -T /dev/null && sudo -u aurto ln -rsf /var/cache/pacman/aurto/aurto.db{.tar.zst,}; fi'

[Install]
WantedBy=default.target
EOF

RUN systemctl enable ensure-aurto

WORKDIR /home/aurto

VOLUME ["/tmp", "/run", "/run/lock", "/etc/aurto", "/var/cache/pacman/aurto"]

CMD [ "/lib/systemd/systemd", "log-level=info", "unit=sysinit.target" ]
