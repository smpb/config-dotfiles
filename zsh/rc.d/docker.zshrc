#
# Docker settings
#   based off of content in this gist: https://gist.github.com/jgrodziski/9ed4a17709baad10dbcd4530b60dfcbb
#

# Docker container names
function _docker_names {
  for ID in `command docker ps | awk '{print $1}' | grep -v 'CONTAINER'`
  do
    command docker inspect $ID | grep Name | head -1 | awk '{print $2}' | sed 's/,//g' | sed 's%/%%g' | sed 's/"//g'
  done
}

# Docker container IPs
function _docker_ips {
  local OUT="Container\tAddress\n"

  for DOC in `_docker_names`
  do
    IP=`command docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' "$DOC"`
    OUT+=$DOC'\t'$IP'\n'
  done

  echo $OUT | column -t
}

# Set the docker host socket, if needed
function _docker_host {
  if type colima &>/dev/null
  then
    local COLIMA_PATH=""

    if [[ -d "$HOME/.colima" ]];
    then
      COLIMA_PATH="$HOME/.colima"
    fi

    if [[ -n "$XDG_CONFIG_HOME" ]] && [[ -d "$XDG_CONFIG_HOME/colima" ]];
    then
      COLIMA_PATH="$XDG_CONFIG_HOME/colima${COLIMA_PATH:+ $COLIMA_PATH}"
    fi

    if [[ -n "$COLIMA_PATH" ]];
    then
      export DOCKER_HOST="unix://$(find $COLIMA_PATH -name docker.sock -print -quit 2> /dev/null)"
    fi
  fi
}

#
# an approach similar to 'git' aliases
#
function dk() {
  case $1 in
    # Print all the aliases
    alias)
      command echo "$(which dk | awk -v size=$(which dk | grep -c '') 'NR>2 && NR<(size-1)')"
      ;;

    # Compose alias
    cm)
      shift 1
      command docker compose "$@"
      ;;

    # Compose build
    cmb)
      command docker compose build
      ;;

    # Compose down
    cmd)
      command docker compose down
      ;;

    # Execute command (bash, by default) in a composed service
    cmex)
      shift 1
      command docker compose exec -u root -it $1 ${2:-bash}
      ;;

    # Attach to composed service logs
    cml)
      command docker compose logs -f
      ;;

    # Compose run
    cmr)
      shift 1
      command docker compose run "$@"
      ;;

    # Compose up
    cmu)
      command docker compose up
      ;;

    # Execute command (bash, by default) in a container
    ex)
      shift 1
      command docker exec -u root -it $1 ${2:-bash}
      ;;

    # Set the Docker host socket, if needed
    host)
      _docker_host
      echo $DOCKER_HOST
      ;;

    # Docker images alias
    im)
      command docker images
      ;;

    # Docker inspect alias
    in)
      shift 1
      command docker inspect "$@"
      ;;

    # Show IP addresses of containers
    ip|ips)
      _docker_ips
      ;;

    # Attach to a container's logs
    l)
      command docker logs -f
      ;;

    # return the hash IDs of the containers running with the label "$1"
    #  in order to do things like dk ex $(dk label <label>) sh
    label)
      command docker ps --filter="label=$1" --format="{{.ID}}"
      ;;

    # Show names of containers
    names)
      _docker_names
      ;;

    # List stopped containers
    psa)
      command docker ps -a
      ;;

    # Remove stopped containers
    rmc)
      command docker rm $(command docker ps --all -q -f status=exited)
      ;;

    # Remove supplanted image builds
    rmb)
      command docker images | grep none | awk '{ print $3 }' | xargs -I {} sh -c 'command docker rmi {}'
      ;;

    # Remove all dangling images
    rmid)
      IMGS=$(command docker images -q -f dangling=true)
      [ ! -z "$IMGS" ] && command docker rmi "$IMGS" || echo "No dangling images to remove."
      ;;

    # Prune docker system
    sp)
      command docker system prune --all
      ;;

    # Forward request to docker proper
    *)
      command docker "$@"
      ;;
  esac
}

if type docker &>/dev/null
then
  export BUILDX_EXPERIMENTAL=1

  alias docker=dk

  # Complete `dk` like `docker`
  compdef dk=docker
fi

_docker_host
