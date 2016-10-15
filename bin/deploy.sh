#!/bin/bash
set -e

cd ~/pinw-deploy/Docker/
v=$(date +%FH%H%M)

docker build -t "algolab/pinw:${v}" .
for cont in $(docker ps -f name=pinw -q)
do
    docker rm -f "$cont"
done

echo -n "Checking if pinwnet network exists..."
docker network ls | grep pinwnet || docker network create --subnet=172.18.10.0/24 pinwnet
echo "done"

echo "Halting and removing old pinw container"
docker ps -a | grep pinw && docker stop pinw && docker rm -f pinw

echo "Starting container pinw.${v} as $PINW_NAME"
docker run -d  -v ~/pinw-data:/home/data --name "pinw" --net pinwnet --ip 172.18.10.10  -e APP_UID="$(id -u)" -e APP_GID="$(id -g)"  "algolab/pinw:${v}"

# Terrible hack, until I fix the docker data volume stuff
echo "Fix UID, GID"
docker exec pinw /usr/local/sbin/inituidgid.sh
echo "done"
