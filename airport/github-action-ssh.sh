#!/bin/bash

if [[ -z "$TOKEN" ]]; then
  echo "Please set 'TOKEN'"
  exit 2
fi

if [[ -z "$USER_PASS" ]]; then
  echo "Please set 'USER_PASS' for user: $USER"
  exit 3
fi

echo "### Update user: $USER password ###"
echo -e "$USER_PASS\n$USER_PASS" | sudo passwd "$USER"

address=./airport/address
log=./airport/.log
container_name=deploy_container

docker pull yanboer/deploy-environment:alpine > /dev/null
docker run -itd --name $container_name --net=host yanboer/deploy-environment:alpine --authtoken $TOKEN --region us --log stdout tcp 22 > /dev/null

sleep 10
docker logs $container_name > $log

HAS_ERRORS=$(grep "command failed" < $log)

if [[ -z "$HAS_ERRORS" ]]; then
  echo ""
  echo "=========================================="
  echo "To connect: $(grep -o -E "tcp://(.+)" < $log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")"
  echo "=========================================="

  date +'%Y-%m-%d %H:%M:%S' > $address
  echo "To connect: $(grep -o -E "tcp://(.+)" < $log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")" >> $address
else
  echo "$HAS_ERRORS"
  exit 4
fi

