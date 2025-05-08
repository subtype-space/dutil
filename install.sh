#/bin/bash

REPO_URL="https://github.com/subtype-space/dutil"
BIN_NAME="dutil"
SYMLINK_PATH="/usr/local/bin/$BIN_NAME"


echo "Installing dutil..."
echo "Updating dutil..." && git pull

chmod +x ./dutil.sh

if [ -L $SYMLINK_PATH ]; then
    rm "$SYMLINK_PATH"
fi

ln -s "./dutil.sh" "$SYMLINK_PATH" && echo "Created symlink at $SYMLINK_PATH" || echo "Failed to create symlink!"

echo "🎉 dutil installed! Run it with: dutil"