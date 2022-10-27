FROM amazonlinux:2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG PLATFORM_TOOLS_VERSION="1.0.12"
ARG TF_VERSIONS="0.12.31 0.13.7 0.15.5 1.0.11 1.1.9"
ARG TF_ARCHIVE_STORE="/opt"

RUN yum install -y \
    jq \
    openssl \
    sha256sum \
    unzip \
    wget \
    zip && \
    yum clean all

RUN echo | openssl s_client -showcerts -servername websenseproxy.internal.ch -connect websenseproxy.internal.ch:443 2>/dev/null | openssl x509 -inform pem -outform pem -out /etc/pki/ca-trust/source/anchors/websenseproxy.internal.ch.pem && \
    update-ca-trust

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws && \
    rm -f /tmp/awscliv2.zip

RUN rpm --import http://yum-repository.platform.aws.chdev.org/RPM-GPG-KEY-platform-noarch && \
    yum install -y yum-utils && \
    yum-config-manager --add-repo http://yum-repository.platform.aws.chdev.org/platform-noarch.repo && \
    yum install -y platform-tools-terraform-$PLATFORM_TOOLS_VERSION && \
    yum clean all

COPY /resources/tf_install.sh /tf_install.sh

RUN /tf_install.sh "${TF_VERSIONS}" "${TF_ARCHIVE_STORE}" && \
    rm -f /tf_install.sh

RUN yum -y erase \
    sha256sum \
    wget && \
    yum clean all

WORKDIR /terraform-code

ENTRYPOINT ["/usr/bin/run-terraform"]
