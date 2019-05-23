#!/usr/bin/env bash

set -o errexit

if command -v docker > /dev/null 2>&1 ; then
   export DOCKER=docker
else
   export DOCKER=balena-engine
fi

export DOCKER_HOST=unix:///var/run/balena-engine.sock
LOGFILE="/var/log/docker-gc.log"
if [ -n "$DEBUG" ]; then
   LOGFILE="/var/log/docker-gc.$(date +%Y%d%m_%H%M%S).log"
fi

touch "${LOGFILE}"
{
   echo "Pre Garbage Collection Status:"
   $DOCKER images
   $DOCKER ps -a
   echo "Garbage Collection Log:"
   # See the meaning of the different settings at https://github.com/spotify/docker-gc/blob/master/README.md#manual-usage
   REMOVE_VOLUMES=1 FORCE_IMAGE_REMOVAL=1 /usr/bin/docker-gc
} >> "${LOGFILE}" 2>&1
