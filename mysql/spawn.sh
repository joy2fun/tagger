#!/bin/bash

CUSTOM_OPTIONS="b:f:hn:o:p:s:t:"

source "$(dirname "$BASH_SOURCE")"/common.sh

while getopts "$CUSTOM_OPTIONS" opt; do
  case $opt in
    b)
      BACKUP_ROOT=${OPTARG}
      ;;
    f)
      FROM_CONTAINER_ID=${OPTARG}
      ;;
    n)
      NETWORK=${OPTARG}
      ;;
    p)
      PROJECT=${OPTARG}
      ;;
    s)
      SOURCE_TAG=${OPTARG}
      ;;
    t)
      TAG=${OPTARG}
      ;;
    h)
      echo "Usage:"
      echo "  -b backup dir for dumping"
      echo "  -f from container id. query based on source tag if not present"
      echo "  -n network"
      echo "  -p project"
      echo "  -s source tag"
      echo "  -t tag"
      exit 0
      ;;
  esac
done

if [ -z $PROJECT ]; then
  echo "ERROR: missing -p PROJECT"
  exit 1
fi
if [ -z $BACKUP_ROOT ]; then
  echo "ERROR: missing -b BACKUP_ROOT"
  exit 1
fi
if [ -z $SOURCE_TAG ] && [ -z $FROM_CONTAINER_ID ]; then
  echo "ERROR: missing -s SOURCE_TAG or -f FROM_CONTAINER_ID"
  exit 1
fi
if [ -z $TAG ]; then
  echo "ERROR: missing -t TAG"
  exit 1
fi

mkdir -p ${BACKUP_ROOT}/${PROJECT}/${TAG}

OUTPUT=${BACKUP_ROOT}/${PROJECT}/${TAG}/db.sql

if [ -z $FROM_CONTAINER_ID ]; then
  FROM_CONTAINER_ID=$(docker ps \
    -f "label=SERVICE_NAME=mysql_${PROJECT}" \
    -f "label=SERVICE_TAGS=${SOURCE_TAG}" \
    --format="{{.ID}}")
fi

check_container ${FROM_CONTAINER_ID} "source container [${FROM_CONTAINER_ID}] does not exist"

echo "dumping all databases ..."
test -t 1 && USE_TTY="-t"
docker exec ${USE_TTY} ${FROM_CONTAINER_ID} \
  sh -c 'exec mysqldump --single-transaction -A ' > $OUTPUT

# check before creating
CONTAINER_ROW=$(docker ps \
  -a \
  -f "label=SERVICE_NAME=mysql_${PROJECT}" \
  -f "label=SERVICE_TAGS=${TAG}" \
  --format="{{.ID}}\t{{.Names}}")

if [ "" != "$CONTAINER_ROW" ]; then
  echo "Found created container: ${CONTAINER_ROW}"
  FOUND_CONTAINER_ID=$(echo $CONTAINER_ROW | awk '{print $1}')
  echo "Removing container ${FOUND_CONTAINER_ID} ..."
  docker container rm -f ${FOUND_CONTAINER_ID}
fi

if [ -z $NETWORK ]; then
  NETWORK=$(default_network)
fi

PORT=$(get_unused_port)

docker run --restart always -it -d \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=true \
  -l SERVICE_NAME=mysql_${PROJECT} \
  -l SERVICE_TAGS=${TAG} \
  -v mysql_${PROJECT}_${TAG}:/var/lib/mysql \
  -v ${BACKUP_ROOT}/${PROJECT}/${TAG}:${DEFAULT_INIT_DIR} \
  --name mysql_${PROJECT}_${TAG}_${PORT} \
  --network ${NETWORK} \
  -p ${PORT}:3306 \
  ${DEFAULT_IMAGE}

