#!/bin/bash
echo
echo "This script run the mysql_config_editor utility in container !"
echo

source "$(dirname "$BASH_SOURCE")"/common.sh

if [ -z $CONTAINER_ID ]; then
  select_container $DEFAULT_IMAGE
fi
check_container ${CONTAINER_ID}

# check if mysql config already exists
LOGIN_CONFIG_DETAIL=$(docker exec -it ${CONTAINER_ID} mysql_config_editor print)
DO_EDIT=1

if [ "" != "$LOGIN_CONFIG_DETAIL" ]; then
  echo "Login config found: "
  echo "${LOGIN_CONFIG_DETAIL}"
  echo

  DO_EDIT=0

  read -p "Continue edit anyway? [y/N] " CONTINUE_EDIT
  case $CONTINUE_EDIT in
    [Yy]* )
      DO_EDIT=1
      ;;
  esac
fi

if [ $DO_EDIT -gt 0 ]; then
  docker exec -it ${CONTAINER_ID} sh -c 'echo Mysql root password: $MYSQL_ROOT_PASSWORD'
  docker exec -it ${CONTAINER_ID} \
      sh -c '\
        exec mysql_config_editor \
          set --skip-warn \
          --login-path=client \
          --host=localhost \
          -uroot \
          -p \
      '
fi

