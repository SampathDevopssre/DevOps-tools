#!/bin/bash

#check whether the user executing is a root user or not
ID=$(id -u)
if [ $ID -ne 0 ]; then
     echo -e "\e[31m You shoould be running this script as root user or with the sudo command \e[0m"
     exit 1
fi 

stat() {
    if [ $1 -eq 0 ] ; then 
        echo -e  "\e[32m Success \e[0m"
    else 
        echo -e "\e[31m Failure \e[0m"
    fi
}

LOG=/tmp/stack.log
FUSER=student 
VERSION="8.5.75"
APACHE_URL="https://dlcdn.apache.org/tomcat/tomcat-8/v$VERSION/bin/apache-tomcat-$VERSION.tar.gz"
WAR_URL="https://devops-cloudcareers.s3.ap-south-1.amazonaws.com/student.war"
JDBC_URL="https://devops-cloudcareers.s3.ap-south-1.amazonaws.com/mysql-connector.jar "

#WebServer

echo -n "Installing Apache Webserver : " 
yum install httpd -y &> $LOG 
stat $?

echo -n "Creating Proxy Config : "
echo 'ProxyPass "/student" "http://localhost:8080/student"
ProxyPassReverse "/student"  "http://localhost:8080/student" ' > /etc/httpd/conf.d/proxy.conf  
stat $? 

echo -n  "Setup Default Index File : "
curl -s https://devops-cloudcareers.s3.ap-south-1.amazonaws.com/index.html > /var/www/html/index.html 
stat $? 

echo -n "Starting the webservice : "
systemctl enable httpd &> $LOG 
systemctl start httpd &> $LOG 
stat $?


# AppServer 
echo -n "Installing Java : "
yum install java -y  &> $LOG
stat $? 


echo -n "Creating the $FUSER functional user : "
id $FUSER &> $LOG
if [ $? -eq 0 ]; then 
    echo -e "\e[33m Skipping, $FUSER already exists \e[0m"
else 
    useradd $FUSER &> $LOG
    stat $?
fi

echo -n "Downloading the Tomcat : "
cd /home/$FUSER 
wget $APACHE_URL  &> $LOG 
tar -xf apache-tomcat-$VERSION.tar.gz  &> $LOG 
stat $?

echo -n "Downloading the $FUSER War file : "
wget $WAR_URL -P apache-tomcat-$VERSION/webapps  &> $LOG 
stat $? 

echo -n "Downloading the JDBC : "
wget $JDBC_URL -P apache-tomcat-$VERSION/lib  &> $LOG 
chown -R $FUSER:$FUSER apache-tomcat-$VERSION  &> $LOG  
stat $?

echo -n "Starting the TOMCAT"
sh apache-tomcat-$VERSION/bin/startup.sh   &> $LOG 
sleep 5 &> $LOG
stat $? 

echo -n "Checking App's Availability : " 
curl localhost:8080/$FUSER 
if [ $? -eq 0 ]; then 
    echo -e "\e[32m Application is UP and Ready to serve the traffic \e[0m"
else 
    echo -e "\e[31m App is having issues. Refer to the logs in /home/$FUSER/apache-tomcat-$VERSION/logs/catalina.out \e[0m"
fi
