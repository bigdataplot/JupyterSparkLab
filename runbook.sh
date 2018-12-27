
## ======================================== ##
##                 Host
## ======================================== ##
sudo su

## Setup Admin Account
export NUSER='bigdataplot'
export DGNM='docker'
export NUID='2046'
export NGID='2047'
export DGID='2048'

## Setup Docker Group
delgroup $DGNM
addgroup $DGNM
groupmod -g $DGID $DGNM
newgrp $DGNM

## Setup  Admin Permission (bigdataplot)
adduser $NUSER --gecos "BigDataPlot LLC,r001,w001,h001" --disabled-password
echo "$NUSER:bigpass" | chpasswd
usermod -u $NUID $NUSER
groupmod -g $NGID $NUSER
echo '$NUSER ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
su $NUSER -c 'ln -s /apps/datahub /home/$NUSER/datahub'
usermod -a -G $DGNM $NUSER

## Setup Host Directory
mkdir -p /apps/datahub
chmod -R 770 /apps/datahub
chown -R root:$DGNM /apps/datahub

## Backup User Profile Backups
chmod 500 host_profile_bk.sh
./host_profile_bk.sh


## ======================================== ##
##             Docker Container
## ======================================== ##

rm /etc/passwd
cat /apps/datahub/prfmve/passwd.mig >> /etc/passwd

rm /etc/group
cat /apps/datahub/prfmve/group.mig >> /etc/group

rm /etc/shadow
cat /apps/datahub/prfmve/shadow.mig >> /etc/shadow

rm /etc/gshadow
cat /apps/datahub/prfmve/gshadow.mig >> /etc/gshadow


## ======================================== ##
##              Operation
## ======================================== ##

## Stop/Reprfmve Container
sudo docker stop data-lab
sudo docker rm data-lab

## Reprfmve Image
sudo docker rmi bigdataplot/jupyter-spark-lab:1.31

## Build from Dockerfile
sudo docker build -t bigdataplot/jupyter-spark-lab:1.33 .

## Check Docker Logs
sudo docker logs data-lab

## Login and Push a Image
sudo docker login --username bigdataplot
sudo docker push bigdataplot/jupyter-spark-lab:1.33




## Bring up the Jupyter-Spark-Lab (Modify ports if necessary)
sudo docker run --name data-lab \
    --detach \
    --restart always\
    --publish 8888:8888 \
    --volume /apps/datahub:/apps/datahub \
    bigdataplot/jupyter-spark-lab