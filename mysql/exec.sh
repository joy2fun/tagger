#!/bin/bash

source "$(dirname "$BASH_SOURCE")"/common.sh

if [ -z $CONTAINER_ID ]; then
  select_container $DEFAULT_IMAGE
fi
check_container ${CONTAINER_ID}

if [ "$STMT" = "" ]; then
  read -p "Input SQL statement: " STMT
fi

docker exec -it ${CONTAINER_ID} sh -c "exec mysql -e \"${STMT};\""

