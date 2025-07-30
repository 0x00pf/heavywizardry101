#!/bin/sh

export HWUID=$(id -u)
export HWGID=$(id -g)

echo "run: sudo update-binfmts --enable"

docker run --rm --privileged -it \
           --user $HWUID:$HWGID \
	   --tmpfs /dev/shm:rw,exec \
	   -v /etc/group:/etc/group:ro \
	   -v /etc/passwd:/etc/passwd:ro \
	   -v /etc/shadow:/etc/shadow:ro \
           -v $PWD/code:/opt/code \
           --name hw101 hw101

