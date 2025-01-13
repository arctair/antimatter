#!/usr/bin/env zsh

seed="$1"

set -e

docker build -t wavy-bacon .
id=$(docker run -dip 25565:25565 wavy-bacon)
echo $id
if [ "$seed" != "" ]; then
  docker cp $seed $id:/home/minecraft/backups/
  docker exec $id tar xf /home/minecraft/backups/$seed
fi
docker exec -d $id /bin/start
