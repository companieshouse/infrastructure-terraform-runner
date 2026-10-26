FROM amazonlinux:2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG JQ_VERSION="1.8.2"
ARG PLATFORM_TOOLS_VERSION="1.1.3"
ARG TARGETARCH
ARG TF_VERSIONS="0.12 0.13 1.3 1.9 1.14"
ARG TF_ROOT_PATH="/terraform"
ARG TF_BIN_PATH="/usr/bin"
ARG TF_USER="tfrunner"

ENV TF_ROOT_PATH=${TF_ROOT_PATH}
ENV TF_BIN_PATH=${TF_BIN_PATH}

RUN d=/etc/pki/ca-trust/source/blocklist; \
    if [ ! -d "$d" ]; then d=/etc/pki/ca-trust/source/blacklist; fi && \
    trust extract --overwrite --format=pem-bundle \
    --filter='pkcs11:object=Comodo%20AAA%20Services%20root;type=cert' \
    "$d/Comodo_AAA_Services_root.pem" && \
    trust extract --overwrite --format=pem-bundle \
    --filter='pkcs11:object=emSign%20ECC%20Root%20CA%20-%20G3;type=cert' \
    "$d/emSign_ECC_Root_CA_-_G3.pem" && \
    update-ca-trust

RUN yum update -y && \
    yum install -y \
        git-2.47.3 \
        openssl-1.0.2k \
        rsync-3.1.2 \
        sudo-1.8.23 \
        unzip-6.0 \
        wget-1.14 \
        yum-utils-1.1.31 \
        zip-3.0 && \
    yum clean all

WORKDIR /tmp

RUN curl -sL "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-${TARGETARCH}" -o "jq-linux-${TARGETARCH}" && \
    curl -sL "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/sha256sum.txt" -o sha256sum.txt && \
    grep "jq-linux-${TARGETARCH}" sha256sum.txt | sha256sum --check --status && \
    chmod +x "jq-linux-${TARGETARCH}" && \
    mv "jq-linux-${TARGETARCH}" "/usr/bin/jq" && \
    rm sha256sum.txt

RUN curl -s "https://awscli.amazonaws.com/awscli-exe-linux-$(arch).zip" -o "awscliv2.zip" && \
    unzip -q awscliv2.zip && \
    /tmp/aws/install --bin-dir /usr/bin && \
    rm -rf aws/ awscliv2.zip

RUN rpm --import http://yum-repository.platform.aws.chdev.org/RPM-GPG-KEY-platform-noarch && \
    yum-config-manager --add-repo http://yum-repository.platform.aws.chdev.org/platform-noarch.repo && \
    yum install -y \
        platform-tools-terraform-${PLATFORM_TOOLS_VERSION} && \
    yum clean all

WORKDIR /

COPY /resources/tf_install.sh /tf_install.sh
COPY /resources/entrypoint.sh /entrypoint.sh
COPY /resources/tfrunner.sudoers /etc/sudoers.d/tfrunner

RUN useradd --uid 1000 --create-home --shell /bin/bash ${TF_USER} && \
    mkdir -p ${TF_ROOT_PATH} && \
    /tf_install.sh "${TF_VERSIONS}" "${TF_ROOT_PATH}"

RUN yum -y erase \
        wget && \
    yum clean all && \
    rm -f /tf_install.sh

WORKDIR /terraform-code

ENTRYPOINT ["/entrypoint.sh"]
