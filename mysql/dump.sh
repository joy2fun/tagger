#!/bin/bash

source "$(dirname "$BASH_SOURCE")"/common.sh

if [ -z $CONTAINER_ID ]; then
  select_container $DEFAULT_IMAGE
fi
check_container ${CONTAINER_ID}

if [ -z $OUTPUT ]; then
  docker exec -it ${CONTAINER_ID} sh -c 'exec mysqldump --single-transaction -A '
else
  docker exec -it ${CONTAINER_ID} sh -c 'exec mysqldump --single-transaction -A ' > $OUTPUT
fi

