#!/bin/bash
set -e

cd ~/pinw-deploy/Docker/
v=$(date +%FH%H%M)

docker build -t "algolab/pinw:${v}" .
for cont in $(docker ps -f name=pinw -q)
do
    docker rm -f "$cont"
done

# Create the pinw-data container, if it does not exist
# It will contain all data used by pinw, included the configuration
# and the databases
docker ps -f name=pinw-data -q || docker volume create --name pinw-data


echo -n "Checking if pinwnet network exists..."
docker network ls | grep pinwnet || docker network create --subnet=172.18.10.0/24 pinwnet
echo "done"

echo "Halting and removing old pinw container"
docker ps -a | grep pinw && docker stop pinw && docker rm -f pinw

echo "Starting container pinw.${v} as $PINW_NAME"
docker run -d  -v ~/pinw-data:/home/data --name "pinw" --net pinwnet --ip 172.18.10.10  -e APP_UID="$(id -u)" -e APP_GID="$(id -g)"  "algolab/pinw:${v}"

# To restore from backup
# docker run -d -v pinw-data:/home/app/data -v ~/pinw-data:/backup --name "pinw-backup" 82da67e28b16
# docker exec pinw-backup "/bin/cp -av /backup/* /home/app/data/"
# docker stop pinw-backup
# docker rm   pinw-backup

# To backup data
# docker run -d -v pinw-data:/home/app/data -v ~/pinw-data:/backup --name "pinw-backup-cron" 82da67e28b16
# docker exec pinw-backup-cron "/bin/cp -av /home/app/data/* /backup/"
# docker stop pinw-backup-cron
# docker rm   pinw-backup-cron
echo "done"

