#!/usr/bin/env bash

set -e

if [[ -z $TF_RUNNER_VERSION ]]; then
    TF_RUNNER_VERSION="0.12"
fi

TF_ARCHIVE=$(find /opt -name "terraform_${TF_RUNNER_VERSION}*.zip" -print)
if [[ ${TF_ARCHIVE} == "" ]]; then
  echo "No suitable archive found for Terraform ${TF_VERSION}"
  exit 1
fi

echo "Extracting Terraform ${TF_RUNNER_VERSION}"
unzip ${TF_ARCHIVE} -d /usr/local/bin/

/usr/bin/run-terraform
