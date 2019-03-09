#!/bin/bash

CUSTOM_OPTIONS="hc:d:o:"

source "$(dirname "$BASH_SOURCE")"/common.sh

while getopts "$CUSTOM_OPTIONS" opt; do
  case $opt in
    c)
      CONTAINER_ID=${OPTARG}
      ;;
    d)
      DATABASES=${OPTARG}
      ;;
    o)
      OUTPUT=${OPTARG}
      ;;
    h)
      echo "Usage:"
      echo "  -c container id"
      echo "  -d database"
      echo "  -o output"
      exit 0
      ;;
  esac
done

if [ -z $CONTAINER_ID ]; then
  select_container $DEFAULT_IMAGE
fi

check_container ${CONTAINER_ID}

if [ -z "${DATABASES}" ]; then
  DATABASES_OPTS="exec mysqldump --single-transaction -A "
else
  DATABASES_OPTS="exec mysqldump --single-transaction --databases ${DATABASES}"
fi

if [ -z "${OUTPUT}" ]; then
  docker exec -it ${CONTAINER_ID} sh -c "${DATABASES_OPTS}"
else
  docker exec -it ${CONTAINER_ID} sh -c "${DATABASES_OPTS}" > $OUTPUT
fi

