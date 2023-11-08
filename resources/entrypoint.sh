#!/usr/bin/env bash

set -e

if [[ -z ${TF_RUNNER_VERSION} ]]; then
    TF_RUNNER_VERSION="0.12"
fi

log-output info "Installing terraform ${TF_RUNNER_VERSION}"
if tfenv use latest:^${TF_RUNNER_VERSION} > /dev/null 2>&1; then
  log-output info "Successfully installed terraform ${TF_RUNNER_VERSION}"
else
  log-output error "Failed to install terraform ${TF_RUNNER_VERSION}"
  exit 1
fi

if [[ $UID -ne 0 ]]; then
    log-output info "Preparing terraform environment"
    sudo rsync -qa /root/.aws /home/tfrunner/
    sudo rsync -qa /root/.ssh /home/tfrunner/
    sudo rsync -qa --exclude '.terraform' /src /home/tfrunner/
    sudo chown -R tfrunner:tfrunner /home/tfrunner/
    pushd /home/tfrunner/src > /dev/null
fi

/usr/bin/run-terraform "$@"
