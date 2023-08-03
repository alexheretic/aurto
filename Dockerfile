FROM archlinux:latest

ENV USER_ID="1002" \
    TZ="Europe/Madrid" \
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
RUN pacman -Syu --noconfirm base-devel sudo && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    useradd --uid ${USER_ID} --shell /bin/bash --groups wheel --create-home aurto

WORKDIR /tmp

RUN mkdir gosu; \
    cd gosu; \
    curl -L https://github.com/tianon/gosu/releases/latest/download/gosu-amd64 > gosu && \
    curl -L https://github.com/tianon/gosu/releases/latest/download/gosu-amd64.asc > gosu.asc && \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify gosu.asc gosu && \
    mv gosu /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu && \
    cd .. && \

    curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/aurutils.tar.gz | tar xz && \
    chown -R aurto aurutils && \
    cd aurutils && \
    gpg --recv-keys DBE7D3DD8C81D58D0A13D0E76BC26A17B9B7018A && \
    gosu aurto makepkg -srci --noconfirm && \
    cd .. && \

    # Install aurto
    curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/aurto.tar.gz | tar xz && \
    chown -R aurto aurto && \
    cd aurto && \
    sed -i -e 's/systemctl enable --now/systemctl enable/g' aurto.install && \
    gosu aurto makepkg -srci --noconfirm && \

    # Cleanup
    rm -r /tmp/* && \
    pacman -Sy && \
    pacman -Rs base-devel --noconfirm && \

    # Set timezone
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

WORKDIR /home/aurto

VOLUME ["/tmp", "/run", "/run/lock", "/etc/aurto", "/var/cache/pacman/aurto"]

CMD [ "/lib/systemd/systemd", "log-level=info", "unit=sysinit.target" ]