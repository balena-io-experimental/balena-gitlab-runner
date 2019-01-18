#!/bin/bash

echo "Setting up docker garbage collection job."
crontab docker-gc.cron
service cron start

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
