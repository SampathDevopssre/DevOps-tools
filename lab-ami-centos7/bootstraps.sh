#!/bin/bash

curl -s -L https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/boot-env.sh -o /etc/profile.d/boot-env.sh
chmod +x /etc/profile.d/boot-env.sh
