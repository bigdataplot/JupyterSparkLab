#  Copyright (c) bigdataplot LLC
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


## Setup Working and Volumne Directories
RUN mkdir -p /apps/jupyterhub/log && \
    chmod -R 744 /apps/jupyterhub && \
    chown -R root:root /apps/jupyterhub


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


## Spark Installation
RUN apt-get install --no-install-recommends -y openjdk-8-jre-headless ca-certificates-java && \
    python3 -m pip install --upgrade pyspark


## Additional Linux Packages
RUN apt-get install -y git


## Additional Python Packages
COPY requirements.txt  requirements.txt
RUN python3 -m pip install -r requirements.txt


## Cleaning
RUN apt-get remove -y wget software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean -y


## Environment Set2
ENV DEBIAN_FRONTEND teletype


## Run Jupyterhub
ENV PYSPARK_PYTHON=/usr/bin/python3

RUN jupyterhub --generate-config && \
    sed -i "s|#c.Spawner.default_url = ''|c.Spawner.default_url = '/lab'|g" jupyterhub_config.py && \
    sed -i "s|#c.JupyterHub.bind_url = 'http://:8000'|c.JupyterHub.bind_url = 'http://:8000/jupyterhub'|g" jupyterhub_config.py

CMD jupyterhub -f /apps/jupyterhub/jupyterhub_config.py

## ========== End-Of-Dockerfile ==========