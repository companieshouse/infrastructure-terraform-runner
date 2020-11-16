FROM centos:centos8

RUN yum install -y git zip unzip jq

RUN curl https://releases.hashicorp.com/terraform/0.12.9/terraform_0.12.9_linux_amd64.zip -o /tmp/terraform_0.12.9_linux_amd64.zip && \
    unzip /tmp/terraform_0.12.9_linux_amd64.zip -d /usr/local/bin && \
    rm -rf /tmp/terraform_0.12.9_linux_amd64.zip

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws && \
    rm -f /tmp/awscliv2.zip

RUN rpm --import http://yum-repository.platform.aws.chdev.org/RPM-GPG-KEY-platform-noarch && \
    yum install -y yum-utils && \
    yum-config-manager --add-repo http://yum-repository.platform.aws.chdev.org/platform-noarch.repo && \
    yum install -y platform-tools-terraform-1.0.10 && \
    yum clean all

WORKDIR /terraform-code

ENTRYPOINT ["/usr/bin/run-terraform"]
