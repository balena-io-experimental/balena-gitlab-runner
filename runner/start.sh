#!/bin/bash

if [ -f "/etc/gitlab-runner/config.toml" ]; then
  echo "Configuration found, starting runner"
  gitlab-runner run
else
  echo "Configuration not found, please run 'gitlab-runner register' from the container."
fi

while : ; do
  echo "Idling..."
  sleep 180
done
