#!/usr/bin/env bash

set -e

VERSIONS=$1
TF_ARCHIVE_STORE=$2
RELEASE_URL="https://releases.hashicorp.com/terraform"

pushd /tmp > /dev/null 2>&1

for VERSION in $VERSIONS; do
    echo "Processing version: $VERSION"
    FILENAME="terraform_${VERSION}_linux_amd64.zip"
    wget -q ${RELEASE_URL}/${VERSION}/${FILENAME} -O ${FILENAME} 2>/dev/null
    wget -q ${RELEASE_URL}/${VERSION}/terraform_${VERSION}_SHA256SUMS -O terraform_${VERSION}_SHA256SUMS 2>/dev/null

    if [[ $(grep ${FILENAME} terraform_${VERSION}_SHA256SUMS) != $(sha256sum ${FILENAME}) ]]; then
        echo "SHA256 Mismatch: ${FILENAME}"
        rm ${FILENAME} terraform_${VERSION}_SHA256SUMS
        exit 1
    fi
    mv ${FILENAME} ${TF_ARCHIVE_STORE}/
    rm terraform_${VERSION}_SHA256SUMS
done
