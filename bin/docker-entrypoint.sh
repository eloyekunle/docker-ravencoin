#!/bin/bash
set -x

USER=ravencoin

chown -R ${USER} .
exec gosu ${USER} "$@"
