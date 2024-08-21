#!/bin/bash -
# Title         : ssh_authentication_cluster.sh
# Description   : This Script can do the automate setup of ssh-public/private-key authentication automatically for password-less between the clusters database servers and standby or remote servers for root and any users  
# Author        : Khamis Al Mamari
# Date          : 21/08/2024
# Version       : V1
# Account       : https://www.linkedin.com/in/khamis-almamari-7092a3215/
#============================================================================

generateSSH_Node1 () {

typeset ip_node2=$1

cd /root/.ssh/
rm -f authorized_keys* i*
rm -f /etc/ssh/authorized_keys* /etc/ssh/i* 

echo -e "\n\n\n" | ssh-keygen -t rsa -N "" &>/dev/null
echo -e "\n\n\n" | ssh-keygen -t rsa1 -N "" &>/dev/null 
echo -e "\n\n\n" | ssh-keygen -t dsa -N "" &>/dev/null

cat id_dsa.pub>> authorized_keys1
cat id_rsa.pub>> authorized_keys1
cat identity.pub>> authorized_keys1


cp authorized_keys1 /etc/ssh 


echo
echo -e "\033[1;92mCreating authorized_keys of Node 1 finish\033[0m"


echo ""
echo -e "\033[1;93mCopy authorized_keys of Node 1 to Node 2 -- Enter root password \033[0m"
echo ""

scp authorized_keys1  root@${ip_node2}:/etc/ssh

cp *.pub /etc/ssh/
cp id* /home/oracle/.ssh/
cd  /home/oracle/.ssh/
chown oracle.dba id*

}


generateSSH_Node2 () {

typeset ip_node1=`hostname -i`
typeset ip_node2=$1

echo ""
echo -e "\033[1;93mCreating authorized_keys of Node 2 -- Enter root password \033[0m"
echo "" 

ssh root@${ip_node2} /bin/bash << commands

cd /root/.ssh/
rm -f authorized_keys* i*
rm -f /etc/ssh/authorized_keys  /etc/ssh/authorized_keys2 /etc/ssh/i* 

echo -e "\n\n\n" | ssh-keygen -t rsa -N "" &>/dev/null
echo -e "\n\n\n" | ssh-keygen -t rsa1 -N "" &>/dev/null 
echo -e "\n\n\n" | ssh-keygen -t dsa -N "" &>/dev/null

cat id_dsa.pub>> authorized_keys 
cat id_rsa.pub>> authorized_keys
cat identity.pub>> authorized_keys 
cp authorized_keys authorized_keys2

echo ""
cp authorized_keys2 /etc/ssh/ 

cp *.pub /etc/ssh/
cp id* /home/oracle/.ssh/
cd  /home/oracle/.ssh/
chown oracle.dba id*
commands


echo ""
echo -e "\033[1;92mCreating authorized_keys of Node 2 finish\033[0m"
echo "" 

echo -e "\033[1;93mCopy authorized_keys of Node 2 back to Node 1 -- Enter root password for both Node sequential \033[0m"
echo "" 

scp root@$ip_node2:"/root/.ssh/authorized_keys2" root@$ip_node1:/etc/ssh/

}


swapSSH_Node1 () {


cd /etc/ssh/
cat authorized_keys1>>authorized_keys
cat authorized_keys2>>authorized_keys

#rm -f authorized_keys1
#rm -f authorized_keys2

}

swapSSH_Node2 () {

typeset ip_node2=$1

ssh root@${ip_node2} /bin/bash << commands

cd /etc/ssh/
cat authorized_keys1>>authorized_keys
cat authorized_keys2>>authorized_keys
#rm -f authorized_keys1
#rm -f authorized_keys2
commands
}


checkPath() {

cd /etc/ssh/

if grep  -R  "/etc/ssh/authorized_keys" /etc/ssh/sshd_config ; then
   echo ""
   echo -e "\033[1;92mThe Value is correct: No need to change\033[0m"

else
        sed -i -e "47d" /etc/ssh/sshd_config
        sed -i -e "47i AuthorizedKeysFile      /etc/ssh/authorized_keys" /etc/ssh/sshd_config

        if [ $? -ne 0 ]; then

        echo -e "\033[1;91mERROR: failed to modify the path of AuthorizedKeysFile of Node 1\033[0m"
        echo -e "\033[1;91mPlease change it manulay\033[0m"

        else
        echo -e "\033[1;92mThe Path of AuthorizedKeysFile is change it correctly\033[0m"

        echo ""
        grep  -R  "/etc/ssh/authorized_keys" /etc/ssh/sshd_config
   fi
fi

service sshd restart &>/dev/null 

}

checkStdPath() {

typeset standbyIp=$1
ssh root@${standbyIp} 'sed -i -e "47d" /etc/ssh/sshd_config; sed -i -e "47i AuthorizedKeysFile      /etc/ssh/authorized_keys" /etc/ssh/sshd_config; service sshd restart &>/dev/null'
}

swapSSH_Node6 () {

typeset ip_node6=$1

echo ""
echo -e "\033[1;93mCopy authorized_keys to Stanby server -- Enter root password \033[0m"
echo ""

scp /etc/ssh/authorized_keys  root@${ip_node6}:/etc/ssh/authorized_keys_temp

echo ""
echo -e "\033[1;93mEnter root password again\033[0m"

ssh root@${ip_node6} /bin/bash << commands

cd /etc/ssh/
cat authorized_keys_temp>>authorized_keys
rm -f authorized_keys_temp

commands
}

echo ""
echo "******************************************************************************"
echo -e "\033[1;93mScript Start Now \033[0m"
echo "******************************************************************************"

echo ""
echo -e "\033[1;93mKindly Input Node 2 IP \033[0m"
echo ""
read ip_node2 



generateSSH_Node1 "${ip_node2}"
generateSSH_Node2 "${ip_node2}"


echo ""
echo -e "\033[1;93mMerage both authorized_keys for both node -- Enter root password for Node 2 \033[0m"
echo ""

swapSSH_Node1
swapSSH_Node2 "${ip_node2}"

echo ""
echo -e "\033[1;92mMerage both authorized_keys for both node finish\033[0m"
echo ""

echo ""
echo -e "\033[1;93mCheck the current path of AuthorizedKeysFile \033[0m"
echo ""

checkPath 

echo ""
echo -e "\033[1;93mModify the path of Node 2 AuthorizedKeysFile -- Enter root password for Node 2\033[0m"
echo ""

if [ $? -ne 0 ]; then
      echo -e "\033[1;91mERROR: failed to modify the path of Node 2 AuthorizedKeysFile\033[0m"
      echo -e "\033[1;91mPlease change it manulay\033[0m"

      else
      echo -e "\033[1;92mVerify\033[0m"
      checkStdPath "${ip_node2}"
      echo ""
fi




echo ""
echo -e "\033[1;93mKindly Input Standby IP \033[0m"
echo ""
read ip_node6 

swapSSH_Node6 "${ip_node6}"

echo ""
echo -e "\033[1;93mCheck the current path of AuthorizedKeysFile of Standby server \033[0m"
echo ""

if [ $? -ne 0 ]; then
      echo -e "\033[1;91mERROR: failed to modify the path of Standby AuthorizedKeysFile\033[0m"
      echo -e "\033[1;91mPlease change it manulay\033[0m"

      else
      echo -e "\033[1;92mVerify\033[0m"
      checkStdPath "${ip_node6}"
      echo ""
fi

echo  ""
echo "******************************************************************************"
echo -e "\033[1;93mScript End: Check SSH connectivity \033[0m"
echo "******************************************************************************"
echo ""

