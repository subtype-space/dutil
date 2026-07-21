#!/bin/bash
# dutil installer

REPO="subtype-space/dutil"
BIN_NAME="dutil"
BIN_PATH="/usr/local/bin/$BIN_NAME"

if [ "$EUID" -ne 0 ]; then
    echo "Please run this installer as root (e.g. sudo $0)"
    exit 1
fi

# Detect OS and arch
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

ASSET="${BIN_NAME}-${OS}-${ARCH}"
URL="https://github.com/${REPO}/releases/latest/download/${ASSET}"

echo "Downloading $ASSET from $URL..."
if ! curl -fsSL "$URL" -o "$BIN_PATH"; then
    echo "Download failed — check that a release exists for ${OS}/${ARCH}"
    exit 1
fi

chmod +x "$BIN_PATH"
echo "Installed $BIN_NAME to $BIN_PATH"

# Bash completion
COMPLETION_DIR="/usr/share/bash-completion/completions"
COMPLETION_PATH="$COMPLETION_DIR/dutil"

echo "Installing bash completion to $COMPLETION_PATH..."
mkdir -p "$COMPLETION_DIR"

cat > "$COMPLETION_PATH" <<'EOF'
# bash completion for dutil
_dutil() {
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"

  local cmds="down log logs net network networks ps pull rebuild reload shell up upd upgrade"

  if [[ $COMP_CWORD -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
    return
  fi

  case "${COMP_WORDS[1]}" in
    log|logs|cmd|command|shell|ps)
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

echo "dutil installed! Run it with: $BIN_NAME"
