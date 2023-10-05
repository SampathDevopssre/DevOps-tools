#!/bin/bash 

if [ $(id -u) -ne 0 ]; then 
  echo "Run as root user"
  exit 1
fi 

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-ce-cli containerd.io -y

## Group add 
id centos &>/dev/null
if [ $? -eq 0 ]; then 
  groupadd docker &>/dev/null
  usermod -a -G docker thecloudcareers
fi

systemctl enable docker 
systemctl start docker

echo -e "\e[33m \n\t --> Please relogin and run the following command to verify for the client server status <-- \e[0m"
echo -e "    docker ps    "