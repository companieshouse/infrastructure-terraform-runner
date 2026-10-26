#!/usr/bin/env bash

set -e

if [[ -z ${TF_RUNNER_VERSION} ]]; then
    TF_RUNNER_VERSION="0.12"
fi

install_terraform_binary() {
    log-output debug "Installing terraform binary"
    TF_ARCHIVE=$(find ${TF_ROOT_PATH} -name "terraform_${TF_RUNNER_VERSION}*.zip" -print)
    if [[ ${TF_ARCHIVE} == "" ]]; then
        log-output error "Unsupported terraform version: ${TF_RUNNER_VERSION}"
        exit 1
    fi

    unzip_command="sudo unzip -q ${TF_ARCHIVE} -d ${TF_BIN_PATH}/ terraform"
    log-output debug "Running unzip command: ${unzip_command}"
    eval "${unzip_command}"
}

prepare_terraform_environment() {
    log-output info "Preparing terraform environment"
    rsync_ignore_lock_opts=""
    if [[ -n "${TF_RUNNER_IGNORE_DEPENDENCY_LOCK_FILE}" ]] && [[ "${TF_RUNNER_IGNORE_DEPENDENCY_LOCK_FILE}" != "false" ]]; then
        log-output debug "Excluding dependency lock file from rsync"
        rsync_ignore_lock_opts="--exclude '.terraform.lock.hcl'"
    fi

    rsync_aws_command="sudo rsync -qa /root/.aws /home/tfrunner/"
    log-output debug "Running rsync command: ${rsync_aws_command}"
    eval "${rsync_aws_command}"

    rsync_ssh_command="sudo rsync -qa /root/.ssh /home/tfrunner/ --exclude '/*/agent'"
    log-output debug "Running rsync command: ${rsync_ssh_command}"
    eval "${rsync_ssh_command}"

    rsync_src_command="sudo rsync -qa --exclude '.terraform' ${rsync_ignore_lock_opts} /src /home/tfrunner/"
    log-output debug "Running rsync command: ${rsync_src_command}"
    eval "${rsync_src_command}"

    sudo chown -R tfrunner:tfrunner /home/tfrunner/
    pushd /home/tfrunner/src > /dev/null
}

install_proxy_certificates() {
    log-output debug "Installing local proxy certificates"
    local certs_installed; certs_installed=0
    if [[ $(curl -s "https://node-cluster158354-swg.ibosscloud.com/certdirect" -o /dev/null -w "%{http_code}") -eq 200 ]]; then
        log-output debug "Installing iBoss proxy certificate"
        sudo curl -s "https://node-cluster158354-swg.ibosscloud.com/certdirect" -o /etc/pki/ca-trust/source/anchors/iboss.pem
        certs_installed=1
    fi

    if [[ $certs_installed -eq 1 ]]; then
        log-output debug "Updating CA trust stores"
        sudo update-ca-trust
    fi
}

sync_changes() {
    if [[ -z $TF_RUNNER_IGNORE_DEPENDENCY_LOCK_FILE ]] || [[ "${TF_RUNNER_IGNORE_DEPENDENCY_LOCK_FILE}" == "false" ]]; then
        if [[ -n "${USER_UID}" ]] && [[ -n "${USER_GID}" ]]; then
            rsync_sync_back_command="sudo rsync -qa --chown=${USER_UID}:${USER_GID} --exclude '.git/' --exclude '.terraform/'  ./ /src"
            log-output info "Syncing pending changes back to user"
            eval "${rsync_sync_back_command}"
        fi
    fi
}

# Main
install_terraform_binary
prepare_terraform_environment
install_proxy_certificates

log-output debug "Passing operation to run-terraform"
/usr/bin/run-terraform "$@" || true

sync_changes
