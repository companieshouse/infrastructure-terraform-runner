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
  sudo -E unzip -q ${TF_ARCHIVE} -d ${TF_BIN_PATH}/
  sudo -E /usr/bin/run-terraform "$@"
else
  unzip -q ${TF_ARCHIVE} -d ${TF_BIN_PATH}/
  /usr/bin/run-terraform "$@"
fi
