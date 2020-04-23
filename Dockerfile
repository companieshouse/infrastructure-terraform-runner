FROM centos:centos8

ARG PLATFORM_TOOLS_VERSION=1.1.0

RUN yum install -y git unzip

RUN curl https://releases.hashicorp.com/terraform/0.12.9/terraform_0.12.9_linux_amd64.zip -o /tmp/terraform_0.12.9_linux_amd64.zip && \
    unzip /tmp/terraform_0.12.9_linux_amd64.zip -d /usr/local/bin && \
    rm -rf /tmp/terraform_0.12.9_linux_amd64.zip

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws && \
    rm -f /tmp/awscliv2.zip

COPY create-profile /usr/local/bin/create-profile
RUN chmod 0755 /usr/local/bin/create-profile

RUN rpm --import http://yum-repository.platform.aws.chdev.org/RPM-GPG-KEY-platform-noarch && \
    yum install -y yum-utils && \
    yum-config-manager --add-repo http://yum-repository.platform.aws.chdev.org/platform-noarch.repo && \
    yum install -y platform-tools-${PLATFORM_TOOLS_VERSION} && \
    yum clean all

WORKDIR /terraform-code

ENTRYPOINT ["/usr/bin/run-terraform"]
