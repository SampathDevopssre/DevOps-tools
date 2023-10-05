#!/bin/bash 

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /bin

curl https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-tools/terraform/k8-stack/install.sh | bash
