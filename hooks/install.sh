#!/usr/bin/env bash

if [ -n "${HELM_S3_PLUGIN_NO_INSTALL_HOOK}" ]; then
    echo "Development mode: not downloading versioned release."
    exit 0
fi

version="$(cat plugin.yaml | grep "version" | cut -d '"' -f 2)"
echo "Downloading and installing helm-gs v${version} ..."

url="https://github.com/ausov/helm-gs/releases/download/v${version}/package.zip"

mkdir -p "releases/v${version}"
# Download with curl if possible.
if [ -x "$(which curl 2>/dev/null)" ]; then
    curl -sSL "${url}" -o "releases/v${version}.tar.gz"
else
    wget -q "${url}" -O "releases/v${version}.tar.gz"
fi
tar xzf "releases/v${version}.tar.gz" -C "releases/v${version}"

# Moving files
rm -rf "bin"
mv "releases/v${version}/bin" "."
