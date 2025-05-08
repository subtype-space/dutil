#/bin/bash
# real cruddy installer

REPO_URL="https://github.com/subtype-space/dutil"
BIN_NAME="dutil"
BIN_PATH="/usr/local/bin/$BIN_NAME"


echo "Installing dutil..."
echo "Updating dutil..." && git pull

chmod 775 ./dutil.sh
sudo cp dutil.sh "$BIN_PATH"

echo "🎉 dutil installed! Run it with: dutil"