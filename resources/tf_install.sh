#!/usr/bin/env bash

set -e

VERSIONS=$1
TF_ROOT_PATH=$2
RELEASE_URL="https://releases.hashicorp.com/terraform"
RELEASE_HTML=$(echo | curl -s "${RELEASE_URL}" 2>/dev/null)

SYS_ARCH="$(arch)"
case ${SYS_ARCH} in
    x86_64)
        TF_ARCH="amd64"
        ;;
    aarch64)
        TF_ARCH="arm64"
        ;;
    *)
        echo "Error: Unknown architecture"
        exit 1
esac

pushd /tmp > /dev/null 2>&1

for VERSION in $VERSIONS; do
    echo "Processing version: $VERSION"
    TF_RELEASE_REGEX=".*terraform_($VERSION.[0-9]{1,})<.*$"
    TF_LATEST_RELEASE_HTML=$(echo "$RELEASE_HTML" | grep -E -m1 "terraform_$VERSION.[0-9]{1,}<.*")

    if [[ $TF_LATEST_RELEASE_HTML =~ $TF_RELEASE_REGEX ]]; then
        TF_RELEASE=${BASH_REMATCH[1]}
        echo "Found release: ${TF_RELEASE}"
        TF_ARCHIVE_FILE="terraform_${TF_RELEASE}_linux_${TF_ARCH}.zip"
        TF_SHASUMS_FILE="terraform_${TF_RELEASE}_SHA256SUMS"
    else
        echo "Unable to determine release for version $VERSION"
        exit 1
    fi

    wget -q ${RELEASE_URL}/${TF_RELEASE}/${TF_ARCHIVE_FILE} -O ${TF_ARCHIVE_FILE} 2>/dev/null
    wget -q ${RELEASE_URL}/${TF_RELEASE}/${TF_SHASUMS_FILE} -O ${TF_SHASUMS_FILE} 2>/dev/null

    if [[ $(grep ${TF_ARCHIVE_FILE} ${TF_SHASUMS_FILE}) != $(sha256sum ${TF_ARCHIVE_FILE}) ]]; then
        echo "SHA256 Mismatch: ${TF_ARCHIVE_FILE}"
        rm ${TF_ARCHIVE_FILE} ${TF_SHASUMS_FILE}
        exit 1
    fi

    mv ${TF_ARCHIVE_FILE} ${TF_ROOT_PATH}/
    rm ${TF_SHASUMS_FILE}
done
