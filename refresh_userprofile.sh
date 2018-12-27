

adding new users
su $NUSER -c "ln -s /apps/datahub /home/$NUSER/datahub"



## Backup User Profile Backups
rm -rf /apps/prfsync/ || true
mkdir -p /apps/prfsync/

## Setup UID filter limit (Ubuntu from 1000/CentOS from 500):
export UGIDLIMIT=1000

## Copy /etc/passwd accounts to /apps/prfsync/passwd.mig using awk to filter out system account (i.e. only copy user accounts)
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/passwd > /apps/prfsync/passwd.mig
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/group > /apps/prfsync/group.mig
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534) {print $1}' /etc/passwd | tee - |egrep -f - /etc/shadow > /apps/prfsync/shadow.mig

## Copy /etc/gshadow (rarely used):
cp /etc/gshadow /apps/prfsync/gshadow.mig

## Fix permission
chmod -R 640 /apps/prfsync
chown -R root:$DGNM /apps/prfsync

exit

## Only for builds with prefix 's'

## ======================================== ##
##              Pull and Run
## ======================================== ##
sudo docker run --name data-lab \
    --detach \
    --restart always\
    --publish 8888:8888 \
    --volume /apps/datahub:/apps/datahub \
    --volume /apps/prfsync:/apps/prfsync \
    --volume /home:/home \
    bigdataplot/jupyter-spark-lab:s2.01

## ======================================== ##
##               On Host
## ======================================== ##
sudo su

## Setup Admin Account
export DGNM='docker'
export DGID='2048'
export ADMN='your_user_name'

## Setup Docker Group
delgroup $DGNM || true
addgroup $DGNM
groupmod -g $DGID $DGNM
newgrp $DGNM
exit

## Setup Host Directory
mkdir -p /apps/datahub
chmod -R 770 /apps/datahub
chown -R root:$DGNM /apps/datahub

su $ADMN -c "ln -s /apps/datahub /home/$ADMN/datahub"

## ======================================== ##
## Backup User Profile Backups
rm -rf /apps/prfsync/ || true
mkdir -p /apps/prfsync/

## Setup UID filter limit (Ubuntu from 1000/CentOS from 500):
export UGIDLIMIT=1000

## Now copy /etc/passwd accounts to /apps/prfsync/passwd.mig using awk to filter out system account (i.e. only copy user accounts)
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/passwd > /apps/prfsync/passwd.mig

## Copy /etc/group file:
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/group > /apps/prfsync/group.mig

## Copy /etc/shadow file:
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534) {print $1}' /etc/passwd | tee - |egrep -f - /etc/shadow > /apps/prfsync/shadow.mig

## Copy /etc/gshadow (rarely used):
cp /etc/gshadow /apps/prfsync/gshadow.mig

chmod -R 755 /apps/prfsync
chown -R root:$DGNM /apps/prfsync

exit

## Link profile folder to Home directory
ln -s /apps/prfsync /home/$USER/prfsync


## ======================================== ##
##           On Docker Container
## ======================================== ##
sudo docker exec -it data-lab bash

export ADMN='youyang'

rm /etc/passwd
cat /home/$ADMN/prfsync/passwd.mig >> /etc/passwd

sudo rm /etc/group
sudo cat /home/$ADMN/prfsync/group.mig >> /etc/group

sudo rm /etc/shadow
sudo cat /home/$ADMN/prfsync/shadow.mig >> /etc/shadow

sudo rm /etc/gshadow
sudo cat /home/$ADMN/prfsync/gshadow.mig >> /etc/gshadow