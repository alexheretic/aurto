# aurto with docker

After installing docker on your machine, run this command to create the container:
```sh
docker run -d --name aurto-docker \
  --privileged --cap-add SYS_ADMIN --security-opt seccomp=unconfined \
  --cgroup-parent=docker.slice --cgroupns private \
  --tmpfs /tmp --tmpfs /run --tmpfs /run/lock \
  -v aurto_db:/var/cache/pacman/aurto \
  -v aurto_config:/etc/aurto \
  ghcr.io/alexheretic/aurto:master
```

> Make sure to replace **aurto_db** and **aurto_config** with an actual path if you don't want it to store the pacman repo and config files in a docker volume

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