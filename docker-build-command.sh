#!/bin/sh

# exit script on any error
set -e

# version number argument
VERSION="$1"

docker build --build-arg VERSION="${VERSION}" -t playmice/ravencoin:"${VERSION}" -t playmice/ravencoin:latest .
