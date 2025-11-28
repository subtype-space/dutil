#!/bin/bash
# Author: Andrew Subowo
# docker compose based utils -- these can be translated into aliases. It's not that fancy.
# These are things that I somewhat do on a more frequent basis.
# There's a LOT of things that could be added, but this utility is really done for my workflow
# @_subtype / subtype / 2024


function usage() {
  echo "usage: dutil [COMMAND] [container name|compose file]"
  echo -e "  down\n\t\t Stops a stack"
  echo -e "  log\n\t\t Connects to container and follows container logs"
  echo -e "  net|network|networks\n\t\t Returns the list of docker networks"
  echo -e "  ps|psg\n\t\t If given a container name, perform a search for it. psg performs a grep instead against docker ps -a"
  echo -e "  pull\n\t\t Performs a docker compose pull"
  echo -e "  rebuild\n\t\t Performs a docker compose down, build, and up, detatched"
  echo -e "  reload\n\t\t Performs a docker compose down and up, detatched. Specify the file name to use a specific compose file."
  echo -e "  shell\n\t\t Runs docker exec -it against a given container name and opens a bash shell (as fallback, use /bin/sh)."
  echo -e "  up\n\t\t Starts a stack, detatched"
  echo -e "  upgrade\n\t\t Stops a given stack, performs a pull, then starts it."
  exit 2
}

function ok() { echo "✅ $1"; }
function warn() { echo "⚠️ $1"; }
function error() { echo "❌ $1"; }

# Main utility function
# Wrap it all into a function in case someone somehow partially downloads the file
function dutil() {
  # Get current pwd  
  if [ -z $1 ]; then
    usage
  fi

  # TODO: Add v1 support, maybe.
  if ! docker compose version &> /dev/null; then
    error "Docker compose v2 is not installed"
    return 1
  fi

  case $1 in
    down)
      if [ -z "$2" ]; then
        docker compose down
      else
        docker compose -f $2 down
      fi
      ;;
    log|logs)
      if [ -z "$2" ]; then
        error "No container specified"
      else
        docker logs -f "$2"
      fi
      ;;
    net|network|networks)
      docker network ls
      ;;
    ps)
      if [ -z "$2" ]; then
        docker ps -a
      else
        docker ps -a -f name="$2"
      fi
      ;;
    psg)
      if [ -z "$2" ]; then
        docker ps -a
      else
        docker ps -a | grep "$2"
      fi
      ;; 
    pull)
      if [ -z "$2" ]; then
        docker compose pull
      else
        docker compose -f $2 pull
      fi
      ;;  
    rebuild)
      #TODO: See if compose file has a build context?
      if [ ! -z "$2" ]; then
        ok "Using $2 as compose context"
        docker compose -f $2 down && docker compose -f $2 build && docker compose -f $2 up -d
      else
        docker compose down && docker compose build && docker compose up -d
      fi
      ;;
    reload)
      if [ ! -z $2 ]; then #docker compose up and down a given service
        docker compose -f $2 down && docker compose -f $2 up -d
      else
        docker compose down && docker compose up -d
      fi
      ;;
    shell)
      if [ -z $2 ]; then
        usage
        error "Missing container name"
      else
        if docker exec $2 /bin/bash > /dev/null 2>&1; then
          ok "Starting /bin/bash in $2"
          docker exec -it $2 /bin/bash
        elif docker exec $2 /bin/sh > /dev/null 2>&1; then
          warn "$2 does not support /bin/bash, using /bin/sh"
          docker exec -it $2 /bin/sh
        else
          error "Unable to spawn shell session for $2"
          return 1
        fi
      fi
      ;;
    up)
      if [ -z "$2" ]; then
        docker compose up
      else
        docker compose -f $2 up -d
      fi
      ;;
    upgrade)
      if [ -z "$2" ]; then
        dutil down && dutil pull && dutil up -d && ok "Complete"
      else
        dutil down $2 && dutil pull $2 && dutil up $2 && ok "Complete"
      fi
      ;;
    *)
      usage
      ;;
  esac
}

dutil "$@"