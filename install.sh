#!/bin/bash
# real cruddy installer

REPO_URL="https://github.com/subtype-space/dutil"
INSTALL_DIR="/opt/dutil"
BIN_NAME="dutil"
BIN_PATH="/usr/local/bin/$BIN_NAME"

echo "Using $BIN_PATH as your install directory"
if [ "$EUID" -ne 0 ]; then
    echo "Please run this installer as root (e.g. sudo $0)"
    exit 1
fi

if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Updating dutil in $INSTALL_DIR..."
    git -C "$INSTALL_DIR" pull --ff-only
else
    echo "Cloning dutil into $INSTALL_DIR..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

echo "Installing $BIN_NAME to $BIN_PATH..."
install -m 755 "$INSTALL_DIR/dutil.sh" "$BIN_PATH"

COMPLETION_DIR="/usr/share/bash-completion/completions"
COMPLETION_PATH="$COMPLETION_DIR/dutil"

echo "Installing bash completion to $COMPLETION_PATH..."
mkdir -p "$COMPLETION_DIR"

cat > "$COMPLETION_PATH" <<'EOF'
# bash completion for dutil
_dutil() {
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"

  local cmds="down log logs net network networks ps psg pull rebuild reload shell up upd upgrade"

  if [[ $COMP_CWORD -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
    return
  fi

  case "${COMP_WORDS[1]}" in
    log|logs|shell|ps|psg)
      COMPREPLY=( $(compgen -W "$(docker ps -a --format '{{.Names}}' 2>/dev/null)" -- "$cur") )
      ;;
    down|up|upd|pull|rebuild|reload|upgrade)
      COMPREPLY=( $(compgen -G "docker-compose*.yml" -- "$cur") \
                  $(compgen -G "docker-compose*.yaml" -- "$cur") \
                  $(compgen -G "compose*.yml" -- "$cur") \
                  $(compgen -G "compose*.yaml" -- "$cur") )
      ;;
  esac
}

complete -F _dutil dutil
EOF

echo "🎉 dutil installed! Run it with: $BIN_NAME"