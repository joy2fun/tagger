#!/bin/bash

source "$(dirname "$BASH_SOURCE")"/../common.sh

DEFAULT_IMAGE=${DEFAULT_MYSQL_IMAGE:-mysql:5.7}
DEFAULT_INIT_DIR=/docker-entrypoint-initdb.d

mysql_show_databases() {
  local CONTAINER_ID=$1
  docker exec -it ${CONTAINER_ID} sh -c 'exec mysql -e "show databases;"'
}

if [ -z $CUSTOM_OPTIONS ]; then
  while getopts "hc:i:o:s:" opt; do
    case $opt in
      c)
        CONTAINER_ID=${OPTARG}
        ;;
      i)
        DEFAULT_IMAGE=${OPTARG:-$DEFAULT_IMAGE}
        ;;
      o)
        OUTPUT=${OPTARG}
        ;;
      s)
        STMT=${OPTARG}
        ;;
      h)
        echo "Usage:"
        echo "  - c container"
        echo "  - i image"
        exit 0
        ;;
    esac
  done
fi

