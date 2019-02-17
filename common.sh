
# $1 ancestor image
select_container() {
  local IMAGE=$1
  echo "======= containers running based on ${IMAGE} ========";
  docker ps --filter ancestor=$IMAGE --format='{{.ID}}\t{{.Names}}\t{{.CreatedAt}}'
  echo
  read -p "Select a container: " CONTAINER_ID
  echo
}

# check if container is running
# $1 container id
# $2 custom additional message
check_container() {
  local con=$(docker ps --filter id=$1 --format='{{.ID}}\t{{.Names}}')

  if [ "" = "$con" ]; then
    echo "Error: container not found."
    echo $2
    exit 1
  fi
}

# link: https://unix.stackexchange.com/a/358101
get_unused_port() {
  netstat -aln | awk '
    $6 == "LISTEN" {
      if ($4 ~ "[.:][0-9]+$") {
        split($4, a, /[:.]/);
        port = a[length(a)];
        p[port] = 1
      }
    }
    END {
      for (i = 3000; i < 65000 && p[i]; i++){};
      if (i == 65000) {exit 1};
      print i
    }
  '
}

# find proxy network by ancestor image
default_network() {
  local id=$(docker ps --filter ancestor=jwilder/nginx-proxy --format='{{.ID}}')
  if [ "$id" = "" ]; then
    echo "bridge"
  else
    docker container inspect -f '{{range $i,$e:=.NetworkSettings.Networks}}{{println $i}}{{end}}' $id | head -n 1
  fi
}

