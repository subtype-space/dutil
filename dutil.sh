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

  cmd="${1:-}"
  arg="${2:-}"          # container name OR compose file depending on command

  # Build compose args once
  local -a compose_args=()
  [[ -n "$arg" ]] && compose_args=(-f "$arg")

  case "$cmd" in
    down)
      docker compose "${compose_args[@]}" down
      ;;

    up)
      docker compose "${compose_args[@]}" up
      ;;

    upd)
      docker compose "${compose_args[@]}" up -d
      ;;

    pull)
      docker compose "${compose_args[@]}" pull
      ;;

    reload)
      docker compose "${compose_args[@]}" down
      docker compose "${compose_args[@]}" up -d
      ;;

    rebuild)
      [[ -n "$arg" ]] && ok "Using $arg as compose context"
      docker compose "${compose_args[@]}" down
      docker compose "${compose_args[@]}" build
      docker compose "${compose_args[@]}" up -d
      ;;

    upgrade)
      docker compose "${compose_args[@]}" down
      docker compose "${compose_args[@]}" pull
      docker compose "${compose_args[@]}" up -d
      ok "Complete"
      ;;

    log|logs)
      [[ -n "$arg" ]] || { error "No container specified"; return 1; }
      docker logs "$arg"
      ;;

    net|network|networks)
      docker network ls
      ;;

    ps)
      if [[ -z "$arg" ]]; then
        docker ps -a
      else
        docker ps -a -f "name=$arg"
      fi
      ;;

    psg)
      if [[ -z "$arg" ]]; then
        docker ps -a
      else
        docker ps -a | grep -F -- "$arg"
      fi
      ;;

    shell)
      [[ -n "$arg" ]] || { error "Missing container name"; usage; }
      if docker exec "$arg" /bin/bash >/dev/null 2>&1; then
        ok "Starting /bin/bash in $arg"
        docker exec -it "$arg" /bin/bash
      elif docker exec "$arg" /bin/sh >/dev/null 2>&1; then
        warn "$arg does not support /bin/bash, using /bin/sh"
        docker exec -it "$arg" /bin/sh
      else
        error "Unable to spawn shell session for $arg"
        return 1
      fi
      ;;

    *)
      usage
      ;;
  esac
}

dutil "$@"