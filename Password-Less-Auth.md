### Linux Authentication Procudre using password less. 

1) Install GitBash for windows if you're a windows user ( mac users don't have to do this ) 
```
https://git-scm.com/downloads
```

2) Open your GitBash  and create a folder named batch49, let's organize all our learnings here 
```
$ mkdir batch49 
$ cd bacth49 
```

3) Now generate the key pair using the below command 
```
$ ssh-keygen -f keyNameOfYourChoice       ( Just enter enter enter : Do not enter anything )

You can see two files in the folder, when you do a ls 

$ ls 
keyNameOfYourChoice keyNameOfYourChoice.pub 
```

4) Now open your AWS Cloud ---> EC2 ---> On the left pane you've `Key Pair ` option, click that and import key, now select the keyNameOfYourChoice.pub key  and import that 

5) As shown in the session, create a CentOS 7 Linux Machine and while launching chose the keyNameOfYourChoice.pub key and start the machine 

6) Once the machine comes to    `RUNNING`   State, you can connect from the GitBash  

```
ssh -i keyNameOfYourChoice centos@publinIPAddress
```

That's all you're connected to the linux machine without password. But with a file.


### Miro Board Link :
```
https://miro.com/welcomeonboard/UmlWdDdIS0NKYnlPeUlRcHZoZzB2TnBQSWh4U015WDhyaDdiRXMxaDZ6ZHViNUhzVGdWTWZjQ2NER0NISUZkdXwzMDc0NDU3MzU2NDQwNzQ5ODg3?share_link_id=77683639116
```

### Sessions Playlist: ( You can find all the sessions here )
```
https://www.youtube.com/playlist?list=PLPWyJYiAyYNsw-d1v4fJi57aqBVpWVE17
```
