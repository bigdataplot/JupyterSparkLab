BOX:    bdp-gdufe29
IP:     172.28.2.29


## ----->> Build container
sudo docker build -t jupyter-spark-lab:v3.01 .

## ======================================================== ##
##                      verint-dpo
## ======================================================== ##
sudo docker stop verint-dpo
sudo docker rm verint-dpo

sudo docker run -itd \
    --name verint-dpo \
    --hostname verint-dpo \
    --restart always \
    --memory="250g" \
    --publish 8888:8000 \
    --volume /apps/home:/apps/home \
    --volume /data:/data \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /etc/group:/etc/group:ro \
    --volume /etc/passwd:/etc/passwd:ro \
    --volume /etc/shadow:/etc/shadow:ro \
    --volume /etc/gshadow:/etc/gshadow:ro \
    --volume /apps/datahub:/apps/datahub \
    --volume /apps/datadev:/apps/datadev \
    --volume /apps/tmp/dpo:/tmp \
    --env GITLAB_HOST=http://10.140.160.15/gitlab \
    jupyter-spark-lab:v3.01



#--env GITLAB_HOST=http://txlinhdpneop1.retail.nrgenergy.com/gitlab \
#--env GITLAB_HOST=http://10.140.160.15/gitlab \

sudo docker exec -it verint-dpo bash

## ----->> Fix pyspark localhost
#echo "127.0.0.1 $(hostname)" >> /etc/hosts
#nano /etc/hosts
#Use pyspark config as follow
.config('spark.driver.host','localhost')\

# Make sure added to command line
# >>> export GITLAB_HOST=http://txlinhdpneop1.retail.nrgenergy.com/gitlab
# #export GITLAB_PORT=80
# #export OAUTH_CALLBACK_URL=http://10.140.148.149:8888/verint-dpo/hub/oauth_callback
# #export OAUTH_CLIENT_ID=284d9851a4a2a9c5ec5fe82f17606032d69414fd75534bdb2deab4678c0cf43f
# #export OAUTH_CLIENT_SECRET=70d41a89ed578747aea24cb152df7965776b3f59acad28011f0d0e5419d266a2

## ----->> Configure jupyterhub_config.py
# !! Makesure to change gitlab server config too: http://txlinhdpneop1.retail.nrgenergy.com/gitlab/admin/applications
cd /dockerlocal/jupyterhub
sed -i "s|# c.JupyterHub.bind_url = 'http://:8000'|c.JupyterHub.bind_url = 'http://:8000/verint-dpo'|g" jupyterhub_config.py
# Makesure nginx is up and running, and updated before making the following changes
#sed -i "s|# c.JupyterHub.authenticator_class = 'jupyterhub.auth.PAMAuthenticator'|from oauthenticator.gitlab import LocalGitLabOAuthenticator\nc.JupyterHub.authenticator_class = LocalGitLabOAuthenticator\nc.LocalGitLabOAuthenticator.oauth_callback_url = 'http://txlinpciadmsp01.nrgenergy.com/verint-dpo/hub/oauth_callback'\nc.LocalGitLabOAuthenticator.client_id = '4486c18827c226ef26e690ab111ae2ed921884eea0beb91c2ec6240dc1bde2c8'\nc.LocalGitLabOAuthenticator.client_secret = '5a8cd0d6582a1c37d06da80c9635fbc75f16f632a7ca37eb4023de585a6dfd25'|g" jupyterhub_config.py
nano jupyterhub_config.py

>> Add the following lines in jupyterhub_config.py (under PAMAuthenticator):
from oauthenticator.gitlab import LocalGitLabOAuthenticator
c.JupyterHub.authenticator_class = LocalGitLabOAuthenticator
c.LocalGitLabOAuthenticator.oauth_callback_url = 'http://txlinpciadmsp01.nrgenergy.com/verint-dpo/hub/oauth_callback'
c.LocalGitLabOAuthenticator.client_id = '5dd1a26de68ccd351f0607662482faa019840e81be4d51caa4f6eaf9752205b4'
c.LocalGitLabOAuthenticator.client_secret = 'ea9720fd0441a0b630da91930d64e910597aa4d3437dcaf3e0586dc53c13699b'



# initial test
nano jupyterhub_config.py
/miniconda/bin/jupyterhub -f /dockerlocal/jupyterhub/jupyterhub_config.py

sudo docker exec -d verint-dpo /miniconda/bin/jupyterhub -f /dockerlocal/jupyterhub/jupyterhub_config.py





## ======================================================== ##
##                      verint-analytics
## ======================================================== ##
sudo docker stop verint-analytics
sudo docker rm verint-analytics

sudo docker run -itd \
    --name verint-analytics \
    --hostname verint-analytics \
    --restart always \
    --memory="120g" \
    --memory-swap="128g" \
    --cpus="20" \
    --publish 8988:8000 \
    --volume /apps/home:/apps/home \
    --volume /data:/data \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /etc/group:/etc/group:ro \
    --volume /etc/passwd:/etc/passwd:ro \
    --volume /etc/shadow:/etc/shadow:ro \
    --volume /etc/gshadow:/etc/gshadow:ro \
    --volume /apps/tmp/analytics:/tmp \
    --volume /apps/datadev:/apps/datadev \
    --env GITLAB_HOST=http://10.140.160.15/gitlab \
    jupyter-spark-lab:v3.01

sudo docker exec -it verint-analytics bash

# memory-swap: The total amount of memory+sway


## ----->> Fix pyspark localhost
#echo "127.0.0.1 $(hostname)" >> /etc/hosts
#nano /etc/hosts
#Use pyspark config as follow
.config('spark.driver.host','localhost')\

# Make sure added to command line
# >>> export GITLAB_HOST=http://txlinhdpneop1.retail.nrgenergy.com/gitlab
# #export GITLAB_PORT=80
# #export OAUTH_CALLBACK_URL=http://10.140.148.149:8888/verint-analytics/hub/oauth_callback
# #export OAUTH_CLIENT_ID=284d9851a4a2a9c5ec5fe82f17606032d69414fd75534bdb2deab4678c0cf43f
# #export OAUTH_CLIENT_SECRET=70d41a89ed578747aea24cb152df7965776b3f59acad28011f0d0e5419d266a2

## ----->> Configure jupyterhub_config.py
cd /dockerlocal/jupyterhub
sed -i "s|# c.JupyterHub.bind_url = 'http://:8000'|c.JupyterHub.bind_url = 'http://:8000/verint-analytics'|g" jupyterhub_config.py
# Makesure nginx is up and running, and updated before making the following changes
#sed -i "s|# c.JupyterHub.authenticator_class = 'jupyterhub.auth.PAMAuthenticator'|from oauthenticator.gitlab import LocalGitLabOAuthenticator\nc.JupyterHub.authenticator_class = LocalGitLabOAuthenticator\nc.LocalGitLabOAuthenticator.oauth_callback_url = 'http://txlinpciadmsp01.nrgenergy.com/verint-dpo/hub/oauth_callback'\nc.LocalGitLabOAuthenticator.client_id = '4486c18827c226ef26e690ab111ae2ed921884eea0beb91c2ec6240dc1bde2c8'\nc.LocalGitLabOAuthenticator.client_secret = '5a8cd0d6582a1c37d06da80c9635fbc75f16f632a7ca37eb4023de585a6dfd25'|g" jupyterhub_config.py
nano jupyterhub_config.py

>> Add the following lines in jupyterhub_config.py (under PAMAuthenticator):
from oauthenticator.gitlab import LocalGitLabOAuthenticator
c.JupyterHub.authenticator_class = LocalGitLabOAuthenticator
c.LocalGitLabOAuthenticator.oauth_callback_url = 'http://txlinpciadmsp01.nrgenergy.com/verint-analytics/hub/oauth_callback'
c.LocalGitLabOAuthenticator.client_id = 'a04298b3680569adb6d6b69883afc34e5c6dabb96f7e75b1c1029b3f926eb43a'
c.LocalGitLabOAuthenticator.client_secret = 'e3dec2723b0257c1d0c0ab5d4d3e3f45bf9a85d2ddac376576c551f9ddae62ed'

#nano jupyterhub_config.py
#/miniconda/bin/jupyterhub -f /dockerlocal/jupyterhub/jupyterhub_config.py

sudo docker exec -d verint-analytics /miniconda/bin/jupyterhub -f /dockerlocal/jupyterhub/jupyterhub_config.py



## ============================================= ##
###  Transfer and Load Docker image from Neo
## ============================================= ##
> Neo under: youyang
docker save -o ./nrg_spark_lab.tar dc5e8d722172

> Verint: dpoadm
 scp youyang@10.140.160.15:/apps/home/cvt/youyang/dockerImageFiles/nrg_spark_lab.tar ./


sudo docker load -i ./nrg_spark_lab.tar
sudo docker tag 27e87fbf55e2 nrg_spark_lab:neo201904


## ============================================= ##
###  Transfer and Load Docker image from Neo
## ============================================= ##
sudo yum install -y cifs-utils

\\wntvtsapp01\SpeechExportData
mkdir /data/raw/wntvtsapp01/SpeechExportData
sudo mount -t cifs -o username=svcclbadm,uid=dpoadm,gid=datadepot //10.138.44.67/SpeechExportData /data/raw/wntvtsapp01/SpeechExportData
#  Computer2019

sudo umount --verbose /data/raw/wntvtsapp01

chmod 750 /data/raw/wntvtsapp01/

cp -a /source/. /dest/


## ======================================================== ##
##                      Systme Admin
## ======================================================== ##

http://txlinpciadmsp01.nrgenergy.com
http://txlinpciadmsp01.nrgenergy.com/verint-dpo
http://txlinpciadmsp01.nrgenergy.com/verint-analytics


ssh -v -NR 40408:localhost:22 youyang@10.140.160.15 -p 22
ssh -v -p 40408 dpoadm@localhost


Things need to be done:
1. Oracle access 1531 port (Ticket submitted - CHG0057649)
    1) RTLDMP01 - TXAIXMPRP02 - 10.140.115.250
    2) TCSP1N -                 10.140.115.148

2. Shared connection available. Schedule file transfer jobs for Gregs box
    How to move file in win-shared owned by root. (fixed)
    Work with Greg, when to drop/move/archive (Writing script)

    change current => verint_speech
    change archive => verint_speech_archive


3. Docker backup file (working on)
    save in /apps/docker/verint-dpo/ ( including scripts start/stop/backup test schedule )
            /apps/docker/verint-analytics/ ( including scripts start/stop/backup test schedule )

4. (Just notes) Process flow for package upgrade ( request>test>transfer>production )
    **PCI environment restrition, only install necessary packages, speech PII removal related

5. Check with Chris for "/apps/docker" permission (system)

6. Folder under /data/raw should be owned by dpoadm:datadepot (fixed)

7. Storage data file by day. current folder only for past 60 days
    over 60 day, move to archive by year (Writing script)

8. Set memroy limit for container (done)

New Neo: Dockerfile => Docker image
=scp=> PCI

9. add a line for symbolic link. (add to document). Including /data/raw/
10. make containers/folder be consistent
11.
    1) relation between files, between days, cross weeks/months/year?
    2) Contact Greg possible gap/overlap between calls(json)?
    3) how to dedup speech file (if exists).
    4) possible to go back? how many days
    5) Reliant only? or MB

12. change extension name. sh to ""


Next step:
1. Go over admin management for Verint box (document)
2.


Notes:
1. Update/upgrade will be done on new Neo box and Docker image will be transfer to Verint through scp
2. Crontab will be run under account "dpoadm"
3. Main web portal page?
4. Connection to Hadoop necessary (pull data)? (No)
5. GitLab needs to be upgrade in New neo box (current version too old, but cannot be upgraded due to kernel too old)
6. DNS in PCI zone not working well, using IP instead

7. Followup with Greg for data (3 month)
8. Xueming: how to identify call, build bridge between new json file and call logs
9. Usage data. Corp usage. Usage document
10. Main + contact



Rhonda list
1. Jeffs request (web improvement helps callcenter) by Wednesday
2. Report improvement ()
3. Survey collection (web scrapping)
4. Brand health (quarterly)
5. Northeast SQL final info, maintenance








## ----->> Test run pyspark
#import os
from pyspark.sql import SparkSession
#os.environ['PYSPARK_PYTHON'] = '/usr/bin/python3'
spark = SparkSession\
    .builder\
    .master('local[2]')\
    .appName('test')\
    .config('spark.diver.memroy', '8g')\
    .config('spark.executor.cores','4')\
    .config('spark.executor.memory', '8g')\
    .config('spark.driver.maxResultSize','4g')\
    .config('spark.driver.host','localhost')\
    .getOrCreate()

spark.read.format('parquet').load('/apps/home/youyang/parquet/test')\
    .registerTempTable('test')

spark.sql("""
    SELECT ESIID
        ,COUNT(1) AS CNT
    FROM test
    GROUP BY ESIID
""").show()




request jump box existing one(neo)?
cert?

how to configure jump box

TIDY_pwd_$$77!!!


use “sudoedit filename”.




## Windows Shared Drive:

\\wntrtlclbp01\DataDropZone\CVT_ACQ_CHNNL_MB

sudo mkdir /data/stg/test

sudo mount -t cifs -o username=youyang //10.141.223.123/DataDropZone/CVT_ACQ_CHNNL_MB /data/stg/test







sudo yum install epel-release
sudo yum install nginx
sudo systemctl start nginx
sudo systemctl enable nginx




















###  TEST

sudo docker run --name test_box \
    --detach \
    --restart no \
    --publish 18888:8888 \
    jupyter-spark-lab:s2.10

sudo docker exec -it test_box bash


sed -i "s|# c.JupyterHub.authenticator_class = 'jupyterhub.auth.PAMAuthenticator'|from oauthenticator.gitlab import LocalGitLabOAuthenticator\nc.JupyterHub.authenticator_class = LocalGitLabOAuthenticator\nc.LocalGitLabOAuthenticator.oauth_callback_url = 'http://txlinpciadmsp01.nrgenergy.com/verint-dpo/hub/oauth_callback'\nc.LocalGitLabOAuthenticator.client_id = '284d9851a4a2a9c5ec5fe82f17606032d69414fd75534bdb2deab4678c0cf43f'\nc.LocalGitLabOAuthenticator.client_secret = '70d41a89ed578747aea24cb152df7965776b3f59acad28011f0d0e5419d266a2'|g" jupyterhub_config.py

jupyterhub -f jupyterhub_config.py
























###  Transfer and Load Docker image from Neo
> Neo under: youyang
docker save -o ./gitlab-ce.tar f1cd4962f48c

> Verint: dpoadm
 scp youyang@10.140.160.15:/apps/home/cvt/youyang/dockerImageFiles/gitlab-ce.tar ./


sudo docker load -i ./gitlab-ce.tar
sudo docker tag 9d692934cb44 gitlab-ce:neo202103


sudo docker run --detach \
    --name gitlab \
    --hostname gitlab \
    --restart no \
    --publish 5143:443 \
    --publish 5180:80 \
    --publish 5122:22 \
    9d692934cb44

    --volume /apps/gitlab_test/config:/etc/gitlab \
    --volume /apps/gitlab_test/logs:/var/log/gitlab \
    --volume /apps/gitlab_test/data:/var/opt/gitlab \


----------------------------------------------
Change URL:
https://docs.gitlab.com/omnibus/settings/configuration.html
sudo docker exec -it gitlab bash

gitlab-ctl start
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq

nano /etc/gitlab/gitlab.rb
>>>
external_url 'http://txlinpciadmsp01.nrgenergy.com/gitlab'

gitlab-ctl reconfigure
gitlab-ctl restart






sudo docker run -itd \
    --name verint-dpo \
    --hostname verint-dpo \
    --restart always \
    --publish 8888:8000 \
    --volume /apps/home:/apps/home \
    --volume /data:/data \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /etc/group:/etc/group:ro \
    --volume /etc/passwd:/etc/passwd:ro \
    --volume /etc/shadow:/etc/shadow:ro \
    --volume /etc/gshadow:/etc/gshadow:ro \
    --volume /apps/tmp/dpo:/tmp \
    --env GITLAB_HOST=http://txlinhdpneop1.retail.nrgenergy.com/gitlab \
    27e87fbf55e2


sudo docker exec -it verint-dpo bash

## ----->> Fix pyspark localhost
#echo "127.0.0.1 $(hostname)" >> /etc/hosts
#nano /etc/hosts
#Use pyspark config as follow
.config('spark.driver.host','localhost')\

# Make sure added to command line
# >>> export GITLAB_HOST=http://txlinhdpneop1.retail.nrgenergy.com/gitlab
# #export GITLAB_PORT=80
# #export OAUTH_CALLBACK_URL=http://10.140.148.149:8888/verint-dpo/hub/oauth_callback
# #export OAUTH_CLIENT_ID=284d9851a4a2a9c5ec5fe82f17606032d69414fd75534bdb2deab4678c0cf43f
# #export OAUTH_CLIENT_SECRET=70d41a89ed578747aea24cb152df7965776b3f59acad28011f0d0e5419d266a2

## ----->> Configure jupyterhub_config.py
# !! Makesure to change gitlab server config too: http://txlinhdpneop1.retail.nrgenergy.com/gitlab/admin/applications
cd /dockerlocal/jupyterhub
sed -i "s|# c.JupyterHub.bind_url = 'http://:8000'|c.JupyterHub.bind_url = 'http://:8000/verint-dpo'|g" jupyterhub_config.py
# Makesure nginx is up and running, and updated before making the following changes
sed -i "s|# c.JupyterHub.authenticator_class = 'jupyterhub.auth.PAMAuthenticator'|from oauthenticator.gitlab import LocalGitLabOAuthenticator\nc.JupyterHub.authenticator_class = LocalGitLabOAuthenticator\nc.LocalGitLabOAuthenticator.oauth_callback_url = 'http://txlinpciadmsp01.nrgenergy.com/verint-dpo/hub/oauth_callback'\nc.LocalGitLabOAuthenticator.client_id = '4486c18827c226ef26e690ab111ae2ed921884eea0beb91c2ec6240dc1bde2c8'\nc.LocalGitLabOAuthenticator.client_secret = '5a8cd0d6582a1c37d06da80c9635fbc75f16f632a7ca37eb4023de585a6dfd25'|g" jupyterhub_config.py

from oauthenticator.gitlab import LocalGitLabOAuthenticator
c.JupyterHub.authenticator_class = LocalGitLabOAuthenticator
c.LocalGitLabOAuthenticator.oauth_callback_url = 'http://txlinpciadmsp01.nrgenergy.com/verint-dpo/hub/oauth_callback'
c.LocalGitLabOAuthenticator.client_id = '5dd1a26de68ccd351f0607662482faa019840e81be4d51caa4f6eaf9752205b4'
c.LocalGitLabOAuthenticator.client_secret = 'ea9720fd0441a0b630da91930d64e910597aa4d3437dcaf3e0586dc53c13699b'


# initial test
nano jupyterhub_config.py
/miniconda/bin/jupyterhub -f /dockerlocal/jupyterhub/jupyterhub_config.py

sudo docker exec -d verint-dpo /miniconda/bin/jupyterhub -f /dockerlocal/jupyterhub/jupyterhub_config.py







ln -s /data/raw/callcenter/SpeechExportData_current ~/speech_data



ln -s /apps/datahub/ ~/datahub
ln -s /apps/datadev/ ~/datadev



15 7-19 * * * docker exec -itd verint-dpo  /miniconda/bin/python /apps/home/dpoadm/projects/dp_verint_speech/workflow/wf_speech_etl_hourly.py



unzip -j TranscribeCallsV15_fff164bc-c6d5-4f0e-a101-5d9c8fb02b3e.zip







drwx------ 13 dpoadm  datadepot       4096 Mar 27 00:09 dpoadm
drwx------  7 rhu     datadepot       4096 Mar 17 16:53 rhu
drwx------ 11 xxu     datadepot       4096 Mar 27 10:29 xxu
drwx------ 13 youyang datadepot       4096 Mar 26 15:09 youyang


corp_analytics abushra  bushra12341234
corp_analytics rmadala  madala12341234
home_analytics ddecker  decker12341234
home_analytics nford    ford12341234
home_analytics xsui     sui12341234

drwx------  2 wyuan   home_callcenter 4096 Feb  3 15:02 wyuan









1. Describe received data schedule and folder structures
Do not open Windows shared drive.
Initially daily update.
Later 1 hour windows.
later ...


current - 90 days => 90 days zip files (Zip by date )
**** Only this path user can access

7-day: only working directory
archive - all data including 90 days (not open to user )

Ping Greg for Feb and Jan data.




2. Instruction documents are ready
3. User accounts are ready
4. Performance issue?
5. cx_oracle might have issue. Spark <=> Oracle works fine
    (tell user not open, Performance concern)
6. Provide machine names for file transfer. We help submit request


Next step (15min ~ 30min):
1. Friday open to user. Schedule meeting for existing users.
    Walk through how to log on
2. How to request PCI zone () how to submit Ticket
3. Which is their development box (one or less per group)





ls -al /data/raw/callcenter/ETL/SpeechExportData_7day/
ls -al /data/raw/callcenter/ETL/SpeechExportData_archive/
ls -al /data/raw/callcenter/ETL/SpeechExportData_90day_json/





## Link: http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/
gpg --full-gen-key
(1) RSA and RSA (default)
0 = key does not expire
Real name: verint_speech
Email address: cvtsupport@nrg.com
Comment: This key is for Verint Speech data encryption/decryption ONLY.
no passwd


gpg -e -u "Sender User Name" -r "Receiver User Name" somefile

gpg -e -u verint_speech -r verint_speech test.zip

gpg --export-secret-key -a verint_speech > verint_speech_pv.key

gpg --export -a verint_speech > verint_speech_pu.key

#gpg -e -u verint_speech -r verint_speech test.zip -o ./temp/test.zip.gpg



--------------------------

gpg --allow-secret-key-import --import verint_speech_pv.key


gpg -d -r verint_speech test.zip.gpg >> test.zip


gpg -d -r verint_speech ~/speech_data/2021-04-01.tgz.gpg >> ~/2021-04-01.tgz

#gpg -d test.zip.gpg >> test.zip



--------------------------------------
tar gz

tar vczf ./tarTest.tgz ./TestSpeech_1617137654938419/

tar -xvf ~/2021-04-01.tgz -C ./




tar vczf ./tempdata.tgz ./tempdata/








datediff() {
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    echo $(( (d1 - d2) / 86400 )) days
}

datediff '2021-03-01' '2021-04-01'


TGT_PATH="/data/raw/callcenter/SpeechExportData_current/"

dtcut90() {
    chkdt=$(date -d "$1" +%s)
    cutdt=$(date  --date="90 days ago" +%s)
    echo $(( (chkdt - cutdt) / 86400 )) days
    #echo $chkdt
}

dtcut90 '2021-04-01'






for di in "$TGT_PATH"*;
do
    if [ -f "$di" ]; then
        dirdtstr=$(basename "$di" | cut -c1-10)
        dirdt=$(date -d $dirdtstr)
        #echo "$cutdt"
        if [[ $cutdt > $dirdt ]]; then
            echo "$dirdtstr"
        fi
    fi
done








if [[ "2014-12-01T21:34:03+02:00" -lt "2014-12-01T21:35:03+02:00" ]]; then
    echo "yeah"
fi

if [[ $cutdt -lt $dirdt ]]; then
    echo $cutdt > $dirdt
fi



date -d '2012-12-12' > date +%Y-%m-%d -d "$DATE - 90 day"



todate=$(date -d 2013-07-18 +%s)
cond=$(date -d 2014-08-19 +%s)

if $cutdt -ge $dirdt;
then
    echo 'Yeah'
fi


if [ $cutdt < $dirdt ];
then
    echo 'Yeah'
fi









Meeting 2021-04-02
1. Add storage limit in instruction (100GB per user)
2. Decrypt and process data by day.
3. Clear temporary, remove decrypted file once process is complete.
4. encryption shared drive
5. all scripts start with decryption end with encryption (add to instruction doc)












