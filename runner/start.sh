#!/bin/bash

# Set default i386 runner helper image, but available to be overriden
GITLAB_DEFAULT_I386_RUNNER_HELPER_IMAGE="imrehg/gitlab-runner-helper:i386-\${CI_RUNNER_VERSION}"
GITLAB_I386_RUNNER_HELPER_IMAGE="${GITLAB_I386_RUNNER_HELPER_IMAGE:-${GITLAB_DEFAULT_I386_RUNNER_HELPER_IMAGE}}"

function gitlab-runner-register-and-run() {
  local REGISTER_ARGS=()

  # Default 'gitlab-runner register' flags for the balena runner
  REGISTER_ARGS+=(--non-interactive)
  REGISTER_ARGS+=(--executor "docker")
  REGISTER_ARGS+=(--registration-token "$GITLAB_TOKEN")
  REGISTER_ARGS+=(--url "${GITLAB_URL:-https://gitlab.com/}")
  if [ -n "$GITLAB_DESCRIPTION" ]; then
    REGISTER_ARGS+=(--description "$GITLAB_DESCRIPTION")
  else
    # By default, use the short UUID of the device to descripe it
    REGISTER_ARGS+=(--description "${BALENA_DEVICE_UUID:0:7}")
  fi

  if [ -n "$GITLAB_DEFAULT_IMAGE" ]; then
    REGISTER_ARGS+=(--docker-image "${GITLAB_DEFAULT_IMAGE}")
  else
    # If no default image is supplied, use the device type's Debian image
    REGISTER_ARGS+=(--docker-image "balenalib/${BALENA_DEVICE_TYPE}-debian")
  fi

  if [ -n "$GITLAB_RUNNER_HELPER_IMAGE" ]; then
    REGISTER_ARGS+=(--docker-helper-image "${GITLAB_RUNNER_HELPER_IMAGE}")
  else
    # If no image supplied, check if we are on x86 (32-bit), as it needs custom image,
    # as GitLab doesn't provide their own for this architecture at the moment
    local arch
    arch=$(uname -m)
    case "${arch}" in
      i?86)
        REGISTER_ARGS+=(--docker-helper-image "${GITLAB_I386_RUNNER_HELPER_IMAGE}")
        ;;
    esac
  fi


  # Collecting all the tags, tagging `docker` first, as that's the executor
  local tags='docker,'
  if [ "${TAG_ARCHITECTURE:-yes}" = "yes" ]; then
    # Architecture tag, such as aarch64, armv7l, x86_64, ...
    local arch
    arch=$(uname -m)
    tags="${tags}${arch},"
  fi
  if [ "${TAG_DEVICE_TYPE:-yes}" = "yes" ]; then
    # The balena device type, such as raspberrypi3, intel-nuc, ...
    tags="${tags}${BALENA_DEVICE_TYPE},"
  fi
  if [ "${TAG_BALENA:-yes}" = "yes" ]; then
    # Apply tag to signify that this device is a balena device
    tags="${tags}balena,"
  fi
  if [ -n "$GITLAB_TAGS" ]; then
    # Any other set tag, a string with comma separation
    tags="${tags}${GITLAB_TAGS}"
  fi
  REGISTER_ARGS+=(--tag-list "${tags}")

  if [ "${GITLAB_RUN_UNTAGGED:-yes}" = "yes" ]; then
    REGISTER_ARGS+=(--run-untagged=true)
  else
    REGISTER_ARGS+=(--run-untagged=false)
  fi

  if [ "${GITLAB_LOCKED:-yes}" = "yes" ]; then
    REGISTER_ARGS+=(--locked=true)
  else
    REGISTER_ARGS+=(--locked=false)
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
  elif [ -n "$GITLAB_TOKEN" ]; then
    gitlab-runner-register-and-run
  else
    echo "Configuration not found, nor GITLAB_TOKEN set for automatic registration."
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
