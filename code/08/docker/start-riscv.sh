#!/bin/bash

# Remove any previous container
docker stop $(docker ps -q -f name=victim*)

# Destroy network 
docker network rm piconet
docker network create --subnet=172.20.0.0/24 piconet


N=$1
echo "Starting $N machines...."
#for ((i = 1; i < N; i++))
echo  "char *hosts[] ={" > host.h
for i in $(shuf -i 3-127 | head -$N)
do
   ADDR="172.20.0.$i"
   NAME="victim$i"
   echo -n "\"$ADDR\"," >> host.h
   #echo  docker run --net piconet --ip ${ADDR} -v $PWD/snsr:/opt/snsr --name ${NAME} -it alpine
   #docker run --rm --net piconet --ip ${ADDR} --security-opt label=disable -v $PWD/snase:/opt/snase --name ${NAME} -d alpine /opt/snase/snase
	 #docker run --rm --net piconet --ip ${ADDR} --security-opt label=disable -v $PWD/snase:/opt/snase --name ${NAME} -d alpine-qemu /opt/snase/run-mips.sh
   docker run --rm --net piconet --ip ${ADDR} --security-opt label=disable -v $PWD/snase:/opt/snase --name ${NAME} -d alpine-qemu /opt/snase/run-riscv.sh
done
echo  -n " NULL};" >> host.h 
# Run the attacker machine
docker run --rm --net piconet --ip 172.20.0.2 -v $PWD/snase:/opt/snase --name attacker -it alpine-qemu
