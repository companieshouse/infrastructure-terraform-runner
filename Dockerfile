FROM centos:centos8

ARG TF_RELEASE=0.12.31

RUN yum install -y git zip unzip jq openssl

RUN curl http://wpad.internal.ch/websenseproxy_A.cer --output - 2>/dev/null | openssl x509 -inform der -outform pem -out /etc/pki/ca-trust/source/anchors/websense.internal.ch.pem && \
    update-ca-trust

RUN curl https://releases.hashicorp.com/terraform/${TF_RELEASE}/terraform_${TF_RELEASE}_linux_amd64.zip -o /tmp/terraform_${TF_RELEASE}_linux_amd64.zip && \
    unzip /tmp/terraform_${TF_RELEASE}_linux_amd64.zip -d /usr/local/bin && \
    rm -rf /tmp/terraform_${TF_RELEASE}_linux_amd64.zip

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws && \
    rm -f /tmp/awscliv2.zip

RUN rpm --import http://yum-repository.platform.aws.chdev.org/RPM-GPG-KEY-platform-noarch && \
    yum install -y yum-utils && \
    yum-config-manager --add-repo http://yum-repository.platform.aws.chdev.org/platform-noarch.repo && \
    yum install -y platform-tools-terraform-1.0.12 && \
    yum clean all

WORKDIR /terraform-code

ENTRYPOINT ["/usr/bin/run-terraform"]
