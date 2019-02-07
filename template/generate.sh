#!/bin/bash

while getopts "c:e:hp:t:" opt; do
  case $opt in
    c)
      CONSUL_TEMPLATE_CONFIG_DIR=${OPTARG}
      ;;
    e)
      ENV_BASE_DIR=${OPTARG}
      ;;
    p)
      PROJECT=${OPTARG}
      ;;
    t)
      TAG=${OPTARG}
      ;;
    h)
      echo "Usage:"
      echo "  -c consule template base dir"
      echo "  -e env files base dir"
      echo "  -p project"
      echo "  -t tag"
      exit 0
      ;;
  esac
done

if [ -z $CONSUL_TEMPLATE_CONFIG_DIR ]; then
  echo "ERROR: missing -c CONSUL_TEMPLATE_CONFIG_DIR"
  exit 1
fi
if [ -z $ENV_BASE_DIR ]; then
  echo "ERROR: missing -e ENV_BASE_DIR"
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

if [ ! -d "$CONSUL_TEMPLATE_CONFIG_DIR" ]; then
  echo "ERROR: CONSUL_TEMPLATE_CONFIG_DIR is not a directory"
  exit 1
fi

if [ ! -d "$ENV_BASE_DIR" ]; then
  echo "ERROR: ENV_BASE_DIR is not a directory"
  exit 1
fi

mkdir -p ${ENV_BASE_DIR}/${PROJECT}/${TAG}

CONSUL_TEMPLATE_CONFIG_FILE=${CONSUL_TEMPLATE_CONFIG_DIR}/${PROJECT}_${TAG}.hcl
SOURCE=${ENV_BASE_DIR}/${PROJECT}/${TAG}/.env.tpl
DESTINATION=${ENV_BASE_DIR}/${PROJECT}/${TAG}/.env

tee $CONSUL_TEMPLATE_CONFIG_FILE > /dev/null <<EOF
template {
  source = "${SOURCE}"
  destination = "${DESTINATION}"
  backup = false
  wait {
    min = "5s"
    max = "10s"
  }
}
EOF

