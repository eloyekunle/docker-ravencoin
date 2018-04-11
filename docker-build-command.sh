#!/bin/sh

# exit script on any error
set -e

# version number argument
VERSION="$1"

docker build --build-arg VERSION="${VERSION}" -t fuzzle/ravencoin:"${VERSION}" -t fuzzle/ravencoin:latest .
