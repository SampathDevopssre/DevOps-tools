#!/bin/bash

## Following code can help in setting up AMI in AWS for practice of DevOps Tools 
export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/.local/bin:/root/bin"
## Checking Internet 
ping -c 2 google.com &>/dev/null 
if [ $? -ne 0 ]; then 
    echo "Internet connection is now working.. Check it .. !!"
    exit 1
fi
## Common Functions 
curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/common-functions.sh -o /tmp/common.sh &>/dev/null 
source /tmp/common.sh
EPEL=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm


## Check ROOT USER 
if [ $(id -u) -ne 0 ]; then 
    error "You should be a root/sudo user to perform this script"
    exit 1
fi

## Disabling SELINUX
sed -i -e '/^SELINUX/ c SELINUX=disabled' /etc/selinux/config
Stat $? "Disabling SELINUX"


## Disable firewall 
systemctl disable firewalld &>/dev/null
Stat 0 "Disabling Firewall"

## Updating System Updates
#info "Updating System Updates"
#yum update -y #&>/dev/null 
#Stat $? "Updating System Updates"

## Install Base Packages
yum install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm -y
PACK_LIST="wget zip unzip gzip vim make net-tools git $EPEL bind-utils python2-pip jq nc telnet bc sshpass python3"
info "Installing Base Packages"
for package in $PACK_LIST ; do 
    [ "$package" = "$EPEL" ] && rpm -qa | grep epel &>/dev/null && Statt 0 "Installed EPEL" && continue
    yum install $package -y &>/dev/null  
    Statt $? "Installed $package"
done

yum remove mariadb-libs -y &>/dev/null
yum clean all &>/dev/null 

## Fixing SSH timeouts
sed -i -e '/TCPKeepAlive/ c TCPKeepAlive no' -e '/ClientAliveInterval/ c ClientAliveInterval 10' -e '/ClientAliveCountMax/ c ClientAliveCountMax 240'  /etc/ssh/sshd_config
Stat $? "Fixing SSH timeouts"

## Enable color prompt
curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/ps1.sh -o /etc/profile.d/ps1.sh
chmod +x /etc/profile.d/ps1.sh
Stat $? "Enable Color Prompt"

## Enable idle shutdown
curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/idle.sh -o /boot/idle.sh
chmod +x /boot/idle.sh
STAT1=$?

## Setup Sudoers
curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/sudoers >/etc/sudoers

## Uptime
curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/tuptime >/bin/tuptime
chmod +x /bin/tuptime

sed -i -e '/idle/ d' /var/spool/cron/root &>/dev/null
echo "*/10 * * * * sh -x /boot/idle.sh &>/tmp/idle.out" >/var/spool/cron/root
echo "@reboot passwd -u centos" >>/var/spool/cron/root
chmod 600 /var/spool/cron/root
STAT2=$?
if [ $STAT1 -eq 0 -a $STAT2 -eq 0 ]; then 
    STAT=0
else
    STAT=1
fi 
Stat $? "Enable idle shutdown"

## MISC
echo -e "LANG=en_US.utf-8\nLC_ALL=en_US.utf-8" >/etc/environment
echo -e "ANSIBLE_FORCE_COLOR=1" >>/etc/environment

## Enable Password Logins
sed -i -e '/^PasswordAuthentication/ c PasswordAuthentication yes' -e '/^PermitRootLogin/ c PermitRootLogin yes' /etc/ssh/sshd_config
chattr +i /etc/ssh/sshd_config
Stat $? "Enable Password Login"

## Setup user passwords
ROOT_PASS="DevOps321"
CENTOS_PASS="DevOps321"
#usermod -a -G google-sudoers centos &>/dev/null
echo "echo $ROOT_PASS | passwd --stdin root"   >>/etc/rc.d/rc.local 
echo "echo $CENTOS_PASS | passwd --stdin centos"   >>/etc/rc.d/rc.local 
echo "sed -i -e 's/^centos:!!/centos:/' /etc/shadow" >>/etc/rc.d/rc.local
Stat $? "Setup Password for Users"
info "   Following are the Usernames and Passwords"
Infot "centos / $CENTOS_PASS"
Infot "  root / $ROOT_PASS"
echo
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUmaRUE7wDo9knK/UtzeWJQMKh7mP4dc6ZzJnnZkM50BnISt3pIJmAkI/gbThs+CiZKsM+TCT6jgS8/xAbQdhDIrUdyaIyataBBH+x7kmt3i+pzM9ua6R+eqFeiG8YiQhwa81B24axXlPxzD0i6XxxAtzBqyjWhq75CYUIdC6YLB9XiEEGG/J78D/T2IuYvwueLHBi1MHScZVxDTeRHPJYRDS6oAqro/63lzuMQsDdwRNWGo3yRB4aB0DsR8/muj+SVhGgCSFsOyZRHUa5ABJMnBBMawXvDLEKPqcZdJRqfK/4HHSJwK5Uv5WjBYJqnxqjdpkDaTm1UojiNcRNOIveACRIOCMHEXXR68vATeGC4Fez5LWlgLgBvwzXVpF1uh3SY7L5X89PeDfjCFpnWvH33WJ9ymIpJRZvISD+mzHpPyFbV4AN7NOHfC+Uz/+HHA3ANAJ5pkdwHOeNW9LgLhkCpchLdEtnFsoqYI3LenE6EM+T4PmkNV95JkIM3/MMbUc= centos' >/root/.ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUmaRUE7wDo9knK/UtzeWJQMKh7mP4dc6ZzJnnZkM50BnISt3pIJmAkI/gbThs+CiZKsM+TCT6jgS8/xAbQdhDIrUdyaIyataBBH+x7kmt3i+pzM9ua6R+eqFeiG8YiQhwa81B24axXlPxzD0i6XxxAtzBqyjWhq75CYUIdC6YLB9XiEEGG/J78D/T2IuYvwueLHBi1MHScZVxDTeRHPJYRDS6oAqro/63lzuMQsDdwRNWGo3yRB4aB0DsR8/muj+SVhGgCSFsOyZRHUa5ABJMnBBMawXvDLEKPqcZdJRqfK/4HHSJwK5Uv5WjBYJqnxqjdpkDaTm1UojiNcRNOIveACRIOCMHEXXR68vATeGC4Fez5LWlgLgBvwzXVpF1uh3SY7L5X89PeDfjCFpnWvH33WJ9ymIpJRZvISD+mzHpPyFbV4AN7NOHfC+Uz/+HHA3ANAJ5pkdwHOeNW9LgLhkCpchLdEtnFsoqYI3LenE6EM+T4PmkNV95JkIM3/MMbUc= centos' >>/root/.ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUmaRUE7wDo9knK/UtzeWJQMKh7mP4dc6ZzJnnZkM50BnISt3pIJmAkI/gbThs+CiZKsM+TCT6jgS8/xAbQdhDIrUdyaIyataBBH+x7kmt3i+pzM9ua6R+eqFeiG8YiQhwa81B24axXlPxzD0i6XxxAtzBqyjWhq75CYUIdC6YLB9XiEEGG/J78D/T2IuYvwueLHBi1MHScZVxDTeRHPJYRDS6oAqro/63lzuMQsDdwRNWGo3yRB4aB0DsR8/muj+SVhGgCSFsOyZRHUa5ABJMnBBMawXvDLEKPqcZdJRqfK/4HHSJwK5Uv5WjBYJqnxqjdpkDaTm1UojiNcRNOIveACRIOCMHEXXR68vATeGC4Fez5LWlgLgBvwzXVpF1uh3SY7L5X89PeDfjCFpnWvH33WJ9ymIpJRZvISD+mzHpPyFbV4AN7NOHfC+Uz/+HHA3ANAJ5pkdwHOeNW9LgLhkCpchLdEtnFsoqYI3LenE6EM+T4PmkNV95JkIM3/MMbUc= centos' >/home/centos/.ssh/authorized_keys
sed -i -e 's/showfailed//' /etc/pam.d/postlogin
chmod +x /etc/rc.d/rc.local 
systemctl enable rc-local

## Make local keys 
#cat /dev/zero | ssh-keygen -q -N ""
#cat /root/.ssh/id_rsa.pub >>/root/.ssh/authorized_key
## Moved from generting ssh keys to using the ones from repo.
curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/id_rsa >/root/.ssh/id_rsa
curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/id_rsa.pub >/root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa
chmod 644 /root/.ssh/id_rsa.pub
chattr +i /root/.ssh/authorized_keys
echo 'Host *
    User root
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no' >/root/.ssh/config
echo 'Host *
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no' >/home/centos/.ssh/config
chmod 600 /root/.ssh/config /home/centos/.ssh/config
chown centos:centos /home/centos/.ssh/config

# Auto Pull the things while creating the server
curl -L -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/bootstraps.sh -o /boot/bootstrap.sh
chmod +x /boot/bootstrap.sh
echo '@reboot /boot/bootstrap.sh' >>/var/spool/cron/root

# Install AWS CLI 
cd /tmp 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 
unzip awscliv2.zip &>/dev/null
/tmp/aws/install
/usr/local/bin/aws --version || true

rm -rf /var/lib/yum/*  /tmp/*
sed -i -e '/aws-hostname/ d' -e '$ a r /tmp/aws-hostname' /usr/lib/tmpfiles.d/tmp.conf

curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/disable-auto-shutdown >/bin/disable-auto-shutdown
chmod +x /bin/disable-auto-shutdown

curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/enable-auto-shutdown >/bin/enable-auto-shutdown
chmod +x /bin/enable-auto-shutdown

curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/set-hostname >/bin/set-hostname
chmod +x /bin/set-hostname

curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/motd >/etc/motd

curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/.gitconfig >/root/.gitconfig
curl -s https://gitlab.com/thecloudcareers/opensource/-/raw/master/lab-ami-centos7/.gitconfig >/home/centos/.gitconfig
chown centos:centos /home/centos/.gitconfig; chmod 644 /home/centos/.gitconfig

echo "System is going to shutdown now.. Make a note of the above passwords and save them to use with all your servers .."
#echo
#echo -e " \e[32m Shutting Down the Server \e[0m"
#echo;echo
#sudo init 0 &>/dev/null 
