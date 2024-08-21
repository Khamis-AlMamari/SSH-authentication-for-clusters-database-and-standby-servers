# SSH-public-private-keys-authentication-for-clusters-database-and-standby-or-remote-servers
This Script can do the automate setup of ssh-public/private-key authentication automatically for password-less between the clusters database servers and standby or remote servers for root and any users 

## Why Should You Set Up SSH Keys?
You can connect to your application using the username and password, which is the traditional and commonly used method. 
Alternatively, you can also connect to your application using the SSH keys, also known as Password-less SSH.
SSH key pairs offer a more secure way of logging into your server than a password that can easily be cracked with a dictionary and brute force attacks. 
SSH keys are very hard to decipher with these attacks.

## Steps 
Creating authorized_keys of Node 1\
Copy authorized_keys of Node 1 to Node 2\
Creating authorized_keys of Node 2\
Copy authorized_keys of Node 2 back to Node 1\
Merage both authorized_keys for both node\
Copy authorized_keys to Stanby server\
Check the current path of AuthorizedKeysFile for all Node\
Script End: Check SSH connectivity


## Usage

```bash
git clone SSH-public-private-keys-authentication-for-clusters-database-and-standby-or-remote-servers 
cd SSH-public-private-keys-authentication-for-clusters-database-and-standby-or-remote-servers 
chmod +x ssh_authentication_cluster.sh
./ssh_authentication_cluster.sh 
```
You need to run the script by the root user

It will prompt you to enter the root password for cluster and standby servers several times, just write it. 



## Enjoy
Now you should be able to connect to the cluster servers via ssh without a password.\
Try ssh between the cluster server ands check SSH connectivity
##### From Node 1
```bash
ssh Node2_IP 
ssh Standby_IP 

```
##### From Node 2
```bash
ssh Node1_IP 
ssh Standby_IP 

```

## Notes
In my example-code I have used oracle user and dba group.

You can modify them according to your server requirements 


## Authors

- [@Khamis Al Mamari](https://www.linkedin.com/in/khamis-almamari-7092a3215/)
