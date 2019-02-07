#!/bin/bash

source "$(dirname "$BASH_SOURCE")"/common.sh

check_container ${CONTAINER_ID}

docker exec -i ${CONTAINER_ID} sh -c "exec mysql --default-character-set=utf8 --"

