#!/bin/bash

CUSTOM_OPTIONS="a:c:d:e:hi:l:n:P:p:t:"

source "$(dirname "$BASH_SOURCE")"/common.sh

while getopts "$CUSTOM_OPTIONS" opt; do
  case $opt in
    a)
      APPEND_ARGS=${OPTARG}
      ;;
    c)
      CERT_NAME=${OPTARG}
      ;;
    d)
      DOMAIN=${OPTARG}
      ;;
    e)
      ENV_VOLUME=${OPTARG}
      ;;
    i)
      IMAGE=${OPTARG}
      ;;
    l)
      LOGGING_ARGS=${OPTARG}
      ;;
    n)
      NETWORK=${OPTARG}
      ;;
    P)
      PORT_MAPPING=${OPTARG}
      ;;
    p)
      PROJECT=${OPTARG}
      ;;
    t)
      TAG=${OPTARG}
      ;;
    h)
      echo "Usage:"
      echo "  -a append args"
      echo "  -c cert name"
      echo "  -d domain"
      echo "  -e env file volume"
      echo "  -i image"
      echo "  -l logging args"
      echo "  -n network"
      echo "  -P port to mapping to"
      echo "  -p project"
      echo "  -t tag"
      exit 0
      ;;
  esac
done

if [ -z $DOMAIN ]; then
  echo "ERROR: missing -p DOMAIN"
  exit 1
fi
if [ -z $PROJECT ]; then
  echo "ERROR: missing -p PROJECT"
  exit 1
fi
if [ -z $TAG ]; then
  echo "ERROR: missing -t TAG"
  exit 1
fi

if [ -z $IMAGE ]; then
  IMAGE=${PROJECT}:${TAG}
fi
if [ -z $NETWORK ]; then
  NETWORK=$(default_network)
fi
if [ ! -z $CERT_NAME ]; then
  CERT_NAME_ARGS="-e CERT_NAME=${CERT_NAME}"
fi
if [ ! -z $PORT_MAPPING ]; then
  NEW_PORT=$(get_unused_port)
  PORT_MAPPING_ARGS="-p ${NEW_PORT}:${PORT_MAPPING}"
fi
if [ ! -z $ENV_VOLUME ]; then
  ENV_VOLUME_ARGS="-v ${ENV_VOLUME}"
fi

RUNNING_CONTAINER_ID=$(docker ps \
  -f "label=SERVICE_NAME=web_${PROJECT}" \
  -f "label=SERVICE_TAGS=${TAG}" \
  --format="{{.ID}}")

TIMESTR=$(date +%m%d_%H%M%S)

docker run --restart always -it -d \
  ${CERT_NAME_ARGS} \
  ${ENV_VOLUME_ARGS} \
  ${PORT_MAPPING_ARGS} \
  ${LOGGING_ARGS} \
  -e VIRTUAL_HOST=${DOMAIN} \
  -l SERVICE_NAME=web_${PROJECT} \
  -l SERVICE_TAGS=${TAG} \
  --name web_${PROJECT}_${TAG}_${TIMESTR} \
  --network ${NETWORK} \
  ${APPEND_ARGS} \
  ${IMAGE}

if [ "" != "$RUNNING_CONTAINER_ID" ]; then
  echo "Removing running container: ${RUNNING_CONTAINER_ID} ..."
  docker container rm -f ${RUNNING_CONTAINER_ID}
fi

