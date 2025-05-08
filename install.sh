#/bin/bash

REPO_URL="https://github.com/subtype-space/dutil"
BIN_NAME="dutil"
BIN_PATH="/usr/local/bin/$BIN_NAME"


echo "Installing dutil..."
echo "Updating dutil..." && git pull

chmod 775 ./dutil.sh

if [ -f $BIN_PATH ]; then
    rm "$BIN_PATH"
fi

sudo cp dutil.sh "$BIN_PATH"

echo "🎉 dutil installed! Run it with: dutil"