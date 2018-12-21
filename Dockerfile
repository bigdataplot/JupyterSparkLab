#  Copyright (c) BigDataPlot LLC
#  Distributed Under GNU GENERAL PUBLIC LICENSE

## ========== Begin-Of-Dockerfile ==========
## Build Base
FROM ubuntu:16.04


## Base Update
RUN umask 022
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y sudo wget software-properties-common


## Tag
MAINTAINER Yongjian(Ken) Ouyang <yongjian.ouyang@outlook.com>
ARG NB_USER="bigdataplot"
ARG NB_UID="1000"
ARG NB_GID="100"


## Docker Group + User/Group Permission (bigdataplot)
RUN addgroup docker && \
    newgrp docker

RUN adduser bigdataplot --gecos "BigDataPlot LLC,r001,w001,h001" --disabled-password && \
    echo "bigdataplot:bigpass" | chpasswd && \
    echo 'bigdataplot ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    su bigdataplot -c 'ln -s /apps/datahub/ /home/bigdataplot/' && \
    usermod -a -G docker bigdataplot


## Setup Working and Volumne Directories
RUN mkdir -p /apps/jupyterhub/log && \
    chmod -R 775 /apps/jupyterhub && \
    chown -R root:docker /apps/jupyterhub

RUN mkdir -p /apps/datahub && \
    chmod -R 770 /apps/datahub && \
    chown -R root:docker /apps/datahub


## Change Working Directory
WORKDIR /apps/jupyterhub


## Environment Set1
ENV DEBIAN_FRONTEND noninteractive


## Get Python 3.5
RUN apt-get install -y build-essential libpq-dev libssl-dev openssl libffi-dev zlib1g-dev && \
    apt-get install -y python3-pip python3-dev  && \
    python3 -m pip install --upgrade pip


## Jupyterhub
RUN apt-get install -y npm nodejs && \
    npm cache clean -f && \
    npm init -y && \
    npm install -g n && \
    n stable && \
    ln -sf /usr/local/n/versions/node/11.0.0/bin/node /usr/bin/node && \
    npm install -g configurable-http-proxy

RUN python3 -m pip install --upgrade jupyterhub notebook jupyterlab

RUN jupyterhub --generate-config && \
    sed -i "s|#c.Spawner.default_url = ''|c.Spawner.default_url = '/lab'|g" jupyterhub_config.py && \
    sed -i "s|#c.JupyterHub.bind_url = 'http://:8000'|c.JupyterHub.bind_url = 'http://0.0.0.0:8888'|g" jupyterhub_config.py


## Spark Installation
RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    python3 -m pip install --upgrade pyspark


## Additional Python Packages
COPY requirements.txt requirements.txt
RUN python3 -m pip install -r requirements.txt


## Cleaning
RUN apt-get remove -y wget software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean -y


## Environment Set2
ENV DEBIAN_FRONTEND teletype


## Run Jupyterhub
USER $NB_USER
CMD sudo jupyterhub -f /apps/jupyterhub/jupyterhub_config.py

## ========== End-Of-Dockerfile ==========