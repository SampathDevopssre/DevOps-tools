#!/bin/bash 

cd /tmp 
curl -L https://get.helm.sh/helm-v3.11.1-linux-amd64.tar.gz | tar -xz
mv linux-amd64/helm /usr/local/bin
