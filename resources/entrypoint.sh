#!/usr/bin/env bash

set -e

if [[ -z ${TF_RUNNER_VERSION} ]]; then
    TF_RUNNER_VERSION="0.12"
fi

TF_ARCHIVE=$(find ${TF_ROOT_PATH} -name "terraform_${TF_RUNNER_VERSION}*.zip" -print)
if [[ ${TF_ARCHIVE} == "" ]]; then
    log-output error "Unsupported terraform version: ${TF_RUNNER_VERSION}"
    exit 1
fi

if [[ $UID -ne 0 ]]; then
    log-output info "Preparing terraform environment"
    sudo unzip -q ${TF_ARCHIVE} -d ${TF_BIN_PATH}/
    sudo rsync -qa /root/.aws /home/tfrunner/
    sudo rsync -qa /root/.ssh /home/tfrunner/
    sudo rsync -qa --exclude '.terraform' /src /home/tfrunner/
    sudo chown -R tfrunner:tfrunner /home/tfrunner/
    pushd /home/tfrunner/src > /dev/null
else
    unzip -q ${TF_ARCHIVE} -d ${TF_BIN_PATH}/
fi
/usr/bin/run-terraform "$@"
