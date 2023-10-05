#!/bin/bash 

if [ $(id -u) -ne 0 ]; then 
  echo "Run as root user"
  exit 1
fi 

curl -s https://get.docker.com | bash

## Creataing group user docker and adding user centos to the group docker
id centos &>/dev/null
if [ $? -eq 0 ]; then 
  groupadd docker &>/dev/null
  usermod -a -G docker centos
fi

systemctl enable docker 
systemctl start docker

echo -e "\e[33m \n\t --> You need to relogin and run the following command <-- \e[0m"
echo -e "    docker ps    "
