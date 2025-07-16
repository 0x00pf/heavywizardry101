#!/bin/sh

export UID=$(id -u)
export GID=$(id -g)

echo "run: sudo update-binfmts --enable"

docker run --rm --privileged -it \
           --user $UID:$GID \
	   --tmpfs /dev/shm:rw,exec \
	   -v /etc/group:/etc/group:ro \
	   -v /etc/passwd:/etc/passwd:ro \
	   -v /etc/shadow:/etc/shadow:ro \
           -v $PWD/code:/opt/code \
           --name p4w p4w

