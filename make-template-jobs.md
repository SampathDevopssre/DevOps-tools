## Make the initial seed job template.

1. Create a sample pipeline job with proper repos and Jenkinsfile locations.
2. Use the following commands to make the seed job which is already a job in jenkins. 

```shell
$ git clone https://github.com/rsacramento18/jenkinsxml2jobdsl.git
$ sudo yum install java-1.8.0-openjdk-devel -y 
$ cd jenkinsxml2jobdsl
$ ./gradlew build
$ java -jar build/libs/jenkinsxml2jobdsl.jar -u admin -a admin -j <jenkins server> -p 8080 sample
