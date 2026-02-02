# aurto with docker

After installing docker on your machine, run this command to create the container:

```sh
docker run -d --name aurto-docker \
  --privileged --cap-add SYS_ADMIN --security-opt seccomp=unconfined \
  --cgroup-parent=docker.slice --cgroupns private \
  --tmpfs /tmp --tmpfs /run --tmpfs /run/lock \
  ghcr.io/alexheretic/aurto:main
```

## Docker volume examples

Add the following `docker run` args to configure various volumes if required (replace "/path/to/aurto-docker/" with some real path).

- Store aurto package db dir outside docker volume: `-v /path/to/aurto-docker/db:/var/cache/pacman/aurto`
- Custom aurto config dir: `-v /path/to/aurto-docker/config/:/etc/aurto`
- Custom pacman.conf file: `-v /path/to/aurto-docker/pacman.conf:/etc/pacman.conf`
- Custom makepkg.conf file: `-v /path/to/aurto-docker/makepkg.conf:/etc/makepkg.conf`

## Next steps

Then running the commands like a normal installation, first initialise the 'aurto' repo & systemd timers.

```sh
docker exec -it --user aurto aurto-docker aurto init
```

Recommended: Add **aurto** to the 'aurto' repo to provide self updates.

```sh
docker exec -it --user aurto aurto-docker aurto add aurto
```

Also recommended: Add an alias to .bashrc so you only have to write aurto instead of the full docker command.

```sh
alias aurto="docker exec -it --user aurto aurto-docker aurto"
```
