#!/bin/bash

CUSTOM_OPTIONS="hi:n:p:t:v:"

source "$(dirname "$BASH_SOURCE")"/common.sh

while getopts "$CUSTOM_OPTIONS" opt; do
  case $opt in
    i)
      DEFAULT_IMAGE=${OPTARG}
      ;;
    n)
      NETWORK=${OPTARG}
      ;;
    p)
      PROJECT=${OPTARG}
      ;;
    t)
      TAG=${OPTARG}
      ;;
    v)
      INIT_DIR=${OPTARG}
      ;;
    h)
      echo "Usage:"
      echo "  -i image"
      echo "  -n network"
      echo "  -p project"
      echo "  -t tag"
      echo "  -v init volume"
      exit 0
      ;;
  esac
done

if [ -z $PROJECT ]; then
  echo "ERROR: missing -p PROJECT"
  exit 1
fi
if [ -z $TAG ]; then
  echo "ERROR: missing -t TAG"
  exit 1
fi

if [ -z $INIT_DIR ]; then
  INIT_DIR_ARGS=
else
  if [ ! -d "$INIT_DIR" ]; then
    echo "ERROR: init dir does not exist."
    exit 1
  fi
  INIT_DIR_ARGS="-v ${INIT_DIR}:${DEFAULT_INIT_DIR} "
fi

if [ -z $NETWORK ]; then
  NETWORK=$(default_network)
fi

CONTAINER_ROW=$(docker ps \
  -a \
  -f "label=SERVICE_NAME=mysql_${PROJECT}" \
  -f "label=SERVICE_TAGS=${TAG}" \
  --format="{{.ID}}\t{{.Names}}")

if [ "" != "$CONTAINER_ROW" ]; then
  echo "Found created container: ${CONTAINER_ROW}"
  FOUND_CONTAINER_ID=$(echo $CONTAINER_ROW | awk '{print $1}')
  echo "Removing container: ${FOUND_CONTAINER_ID} ..."
  docker container rm -f ${FOUND_CONTAINER_ID}
fi

PORT=$(get_unused_port)

docker run --restart always -it -d \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=true \
  -l SERVICE_NAME=mysql_${PROJECT} \
  -l SERVICE_TAGS=${TAG} \
  -v mysql_${PROJECT}_${TAG}:/var/lib/mysql \
  ${INIT_DIR_ARGS} \
  --name mysql_${PROJECT}_${TAG}_${PORT} \
  --network ${NETWORK} \
  -p ${PORT}:3306 \
  ${DEFAULT_IMAGE}

