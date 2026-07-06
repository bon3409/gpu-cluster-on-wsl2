#!/bin/sh
# Download the helper installation script
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o opentofu.sh

# Grant execution rights and launch the deb installer
chmod +x opentofu.sh
./opentofu.sh --install-method deb

# Clean up installer script
rm -f opentofu.sh
