#!/bin/sh
set -x

USER=ravencoin

chown -R ${USER} .
exec su-exec ${USER} "$@"
