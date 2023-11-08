FROM amazonlinux:2023

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG PLATFORM_TOOLS_VERSION="1.0.16"
ARG TFENV_VERSION="3.0.0"
ARG TFENV_BASE_PATH="/opt"
ARG TF_USER="tfrunner"

RUN dnf install -y \
    findutils \
    git \
    jq \
    openssl \
    rsync \
    sudo \
    unzip \
    wget \
    zip && \
    dnf clean all

RUN curl http://192.168.60.37/websenseproxy_A.cer --output - 2>/dev/null | openssl x509 -inform der -outform pem -out /etc/pki/ca-trust/source/anchors/websenseproxy.internal.ch.pem && \
    update-ca-trust

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install --bin-dir /usr/bin && \
    rm -rf /tmp/aws && \
    rm -f /tmp/awscliv2.zip

RUN wget https://github.com/tfutils/tfenv/archive/refs/tags/v${TFENV_VERSION}.zip -O /tmp/tfenv-${TFENV_VERSION}.zip && \
    unzip /tmp/tfenv-${TFENV_VERSION}.zip -d ${TFENV_BASE_PATH} && \
    rm /tmp/tfenv-${TFENV_VERSION}.zip

ENV PATH=${PATH}:${TFENV_BASE_PATH}/tfenv-${TFENV_VERSION}/bin

RUN rpm --import http://yum-repository.platform.aws.chdev.org/RPM-GPG-KEY-platform-noarch && \
    dnf install -y yum-utils && \
    yum-config-manager --add-repo http://yum-repository.platform.aws.chdev.org/platform-noarch.repo && \
    dnf install -y platform-tools-terraform-${PLATFORM_TOOLS_VERSION} && \
    dnf clean all

COPY /resources/entrypoint.sh /entrypoint.sh
COPY /resources/tfrunner.sudoers /etc/sudoers.d/tfrunner

RUN useradd --uid 1000 --create-home --shell /bin/bash ${TF_USER} && \
    chown -R ${TF_USER}:${TF_USER} ${TFENV_BASE_PATH}/tfenv-${TFENV_VERSION}/

RUN yum -y erase \
    wget && \
    yum clean all && \
    rm -f /tf_install.sh

WORKDIR /terraform-code

ENTRYPOINT ["/entrypoint.sh"]
