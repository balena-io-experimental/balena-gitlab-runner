#!/bin/bash

function gitlab-runner-register-and-run() {
  local REGISTER_ARGS=()

  # Default 'gitlab-runner register' flags for the balena runner
  REGISTER_ARGS+=(--non-interactive)
  REGISTER_ARGS+=(--executor "docker")
  REGISTER_ARGS+=(--url "$GITLAB_URL")
  REGISTER_ARGS+=(--registration-token "$GITLAB_TOKEN")
  if [ -n "$GITLAB_DESCRIPTION" ]; then
    REGISTER_ARGS+=(--description "$GITLAB_DESCRIPTION")
  else
    REGISTER_ARGS+=(--description "${BALENA_DEVICE_UUID:0:7}")
  fi

  if [ -n "$GITLAB_DEFAULT_IMAGE" ]; then
    REGISTER_ARGS+=(--docker-image "${GITLAB_DEFAULT_IMAGE}")
  else
    REGISTER_ARGS+=(--docker-image "balenalib/${BALENA_DEVICE_TYPE}-debian")
  fi

  local tags=''
  if [ "${TAG_DEVICE_TYPE:-yes}" = "yes" ]; then
    tags="${tags}${BALENA_DEVICE_TYPE},"
  fi
  if [ "${TAG_BALENA:-yes}" = "yes" ]; then
    tags="${tags}balena,"
  fi
  if [ -n "$GITLAB_TAGS" ]; then
    tags="${tags}${GITLAB_TAGS}"
  fi
  REGISTER_ARGS+=(--tag-list "${tags}")

  if [ "${GITLAB_RUN_UNTAGGED:-yes}" = "yes" ]; then
    REGISTER_ARGS+=(--run-untagged)
  fi

  if [ "${GITLAB_RUN_LOCKED:-true}" = "true" ]; then
    REGISTER_ARGS+=(--locked true)
  else
    REGISTER_ARGS+=(--locked false)
  fi

  echo "Registering runner with these arguments:" "${REGISTER_ARGS[@]}"
  gitlab-runner register "${REGISTER_ARGS[@]}" && gitlab-runner run
}


function main() {
  echo "Setting up docker garbage collection job."
  crontab docker-gc.cron
  service cron start

  if [ -f "/etc/gitlab-runner/config.toml" ]; then
    echo "Configuration found, starting runner"
    gitlab-runner run
  elif [ -n "$GITLAB_URL" ] && [ -n "$GITLAB_TOKEN" ]; then
    gitlab-runner-register-and-run
  else
    echo "Configuration not found, nor GITLAB_URL/GITLAB_TOKEN set for automatic registration."
    echo "Please run 'gitlab-runner register' from the container!"
  fi

  while : ; do
    echo "Idling..."
    sleep 180
  done
}


#################
# Start things up
#################
main
