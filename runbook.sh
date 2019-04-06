## ======================================== ##
##  User Setup / User Profile Backup (Host)
## ======================================== ##
sudo su

## Setup Admin Account
export DGNM='docker'
export DGID='2048'


## Only if no exist or different uid/gid
## Setup Docker Group
groupdel $DGNM || true
groupadd $DGNM
groupmod -g $DGID $DGNM
newgrp $DGNM
exit

## !!------------------------------------- ##
## If you want to use your local profiles, no need to run the following
## Run this part only if necessary (to create admin account)
## Setup  Admin Permission (dockeradm)
export NUSER='dockeradm'
export NUID='2046'
userdel -r $NUSER || true
adduser $NUSER --gecos "Docker Admin,,," --disabled-password --uid $NUID
groupmod -g $NUID $NUSER
echo "$NUSER:bigpass" | chpasswd
echo "$NUSER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
#adduser $NUSER sudo
su $NUSER -c "ln -s /apps/datahub /home/$NUSER/datahub"
usermod -a -G $DGNM $NUSER

rm /home/$NUSER/datahub || true
su $NUSER -c "ln -s /apps/datahub /home/$NUSER/datahub"

## --------------------------------------!! ##
## Setup Host Directory
mkdir -p /apps/datahub
chmod 770 /apps/datahub
chown root:$DGNM /apps/datahub


## Backup User Profile Backups
rm -rf /tmp/prfsync/ || true
mkdir -p /tmp/prfsync/

## Setup UID filter limit (Ubuntu from 1000/CentOS from 500):
export UGIDLIMIT=1000

## Now copy /etc/passwd accounts to /tmp/prfsync/passwd.mig using awk to filter out system account (i.e. only copy user accounts)
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/passwd > /tmp/prfsync/passwd.mig
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/group > /tmp/prfsync/group.mig
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534) {print $1}' /etc/passwd | tee - |egrep -f - /etc/shadow > /tmp/prfsync/shadow.mig

## Copy /etc/gshadow (rarely used):
cp /etc/gshadow /tmp/prfsync/gshadow.mig

## Fix permission
chmod -R 640 /tmp/prfsync
chown -R root:root /tmp/prfsync

ls -al /tmp/prfsync

exit

## Move to current work directory
#sudo sh -c 'cp /apps/prfsync/*.mig ./'


## ======================================== ##
##             Docker Build (Host)
## ======================================== ##
sudo docker build -t bigdataplot/jupyter-spark-lab:s2.12 .

sudo docker login --username bigdataplot
sudo docker push bigdataplot/jupyter-spark-lab:s2.12

# Or just run if build exists
sudo docker run -itd\
    --name jupyterhub \
    --hostname jupyterhub \
    --restart always\
    --publish 8888:8000 \
    --publish 8889:4040 \
    --volume /apps/datahub:/apps/datahub \
    --volume /home:/home \
    --volume /tmp:/tmp \
    --volume /etc/localtime:/etc/localtime:ro \
    bigdataplot/jupyter-spark-lab:s2.12 bash


## ======================================== ##
##  Update User Profile (Docker Container)
## ======================================== ##
sudo docker exec -it jupyterhub bash

export UGIDLIMIT=1000
awk -v LIMIT=$UGIDLIMIT -F: '$3<LIMIT' /etc/passwd > /tmp/prfsync/passwd0.mig
awk -v LIMIT=$UGIDLIMIT -F: '$3<LIMIT' /etc/group > /tmp/prfsync/group0.mig
awk -v LIMIT=$UGIDLIMIT -F: '$3<LIMIT {print $1}' /etc/passwd | tee - |egrep -f - /etc/shadow > /tmp/prfsync/shadow0.mig


rm /etc/passwd
cat /tmp/prfsync/passwd0.mig >> /etc/passwd
cat /tmp/prfsync/passwd.mig >> /etc/passwd

rm /etc/group
cat /tmp/prfsync/group0.mig >> /etc/group
cat /tmp/prfsync/group.mig >> /etc/group

rm /etc/shadow
cat /tmp/prfsync/shadow0.mig >> /etc/shadow
cat /tmp/prfsync/shadow.mig >> /etc/shadow

rm /etc/gshadow
cat /tmp/prfsync/gshadow.mig >> /etc/gshadow

exit

# Then return
sudo docker exec -it jupyterhub bash


## ======================================== ##
##         Modify Jupyterhub Config
## ======================================== ##
Modify ip and subdirectory

c.JupyterHub.bind_url = 'http://:8000/jupyterhub'

exit
sudo docker exec -itd jupyterhub jupyterhub -f /apps/jupyterhub/jupyterhub_config.py

## ======================================== ##
##           Docker Operation (Host)
## ======================================== ##
## Stop/Reprfsync Container
sudo docker stop data-lab
sudo docker rm data-lab

## Reprfsync Image
sudo docker rmi bigdataplot/jupyter-spark-lab:s2.12

## Build from Dockerfile
sudo docker build -t bigdataplot/jupyter-spark-lab:s2.12 .

## Check Docker Logs
sudo docker logs data-lab

## Login and Push a Image
sudo docker login --username bigdataplot
sudo docker push bigdataplot/jupyter-spark-lab:s2.12

## Bring up the Jupyter-Spark-Lab (Modify ports if necessary)
sudo docker run -itd\
    --name jupyterhub \
    --hostname jupyterhub \
    --restart always\
    --publish 8888:8000 \
    --publish 8889:4040 \
    --volume /apps/datahub:/apps/datahub \
    --volume /home:/home \
    --volume /tmp:/tmp \
    --volume /etc/localtime:/etc/localtime:ro \
    bigdataplot/jupyter-spark-lab:s2.12 bash