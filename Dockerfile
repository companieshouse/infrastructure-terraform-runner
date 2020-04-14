FROM centos:centos8

RUN yum install -y git unzip

RUN curl https://releases.hashicorp.com/terraform/0.12.9/terraform_0.12.9_linux_amd64.zip -o /tmp/terraform_0.12.9_linux_amd64.zip && \
    unzip /tmp/terraform_0.12.9_linux_amd64.zip -d /usr/local/bin && \
    rm -rf /tmp/terraform_0.12.9_linux_amd64.zip

RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws && \
    rm -f /tmp/awscliv2.zip

COPY run-terraform /usr/local/bin/run-terraform

RUN chmod 0755 /usr/local/bin/run-terraform

WORKDIR /terraform-code

ENTRYPOINT ["/usr/local/bin/run-terraform"]
