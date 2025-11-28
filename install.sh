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

echo "🎉 dutil installed! Run it with: $BIN_NAME"