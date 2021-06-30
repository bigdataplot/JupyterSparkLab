#  Copyright (c) bigdataplot LLC
#  Distributed Under GNU GENERAL PUBLIC LICENSE

## ========== Begin-Of-Dockerfile ==========
## Build Base
FROM ubuntu:20.04

## Base Update
RUN umask 022
RUN apt-get update -y
RUN apt-get upgrade -y

## Package preinstall
RUN apt install -y curl build-essential libpq-dev libssl-dev libffi-dev zlib1g-dev

## Tag
MAINTAINER Yongjian(Ken) Ouyang <yongjian.ouyang@outlook.com>

## Setup Working and Volumne Directories
RUN mkdir -p /dockerlocal/jupyterhub/log
RUN chmod -R 744 /dockerlocal/jupyterhub
RUN chown -R root:root /dockerlocal/jupyterhub

## Change Working Directory
WORKDIR /dockerlocal/jupyterhub

## Environment Set1
ENV DEBIAN_FRONTEND noninteractive

## Install miniconda to
RUN curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -p /miniconda -b
RUN rm Miniconda3-latest-Linux-x86_64.sh
#RUN echo "export PATH=/miniconda/bin:${PATH}" >> /root/.bashrc
ENV PATH "/miniconda/bin:${PATH}"
RUN conda update -y conda

# Install python3 and packages from conda
COPY requirements.txt  requirements.txt
RUN conda install -y --file requirements.txt
RUN conda install -y tensorflow numpy scipy pandas matplotlib seaborn lightgbm
RUN conda install -y -c huggingface transformers
RUN conda install -y -c plotly plotly
RUN conda install -y -c intel scikit-learn
RUN conda install -y -c anaconda cython pyhive cx_oracle
RUN conda install -y -c conda-forge pytorch catboost shap sentence-transformers spacy pyreadstat
RUN python -m pip install ipinfo pytorch-tabnet

## Jupyterhub
RUN apt install -y nodejs npm
RUN npm install -g configurable-http-proxy
RUN conda install -y wheel jupyterhub jupyterlab ipywidgets

## Install Spark
RUN mkdir -p /usr/share/man/man1
RUN apt install --no-install-recommends -y openjdk-11-jre-headless ca-certificates-java
RUN conda install -c conda-forge -y pyspark

## Additional Linux Packages
RUN apt install -y libsasl2-dev libsasl2-modules-gssapi-mit
RUN apt install -y git nano supervisor rsync unzip
#RUN apt install -y krb5-user

## Kerberos Config
#COPY krb5.conf  krb5.conf
#RUN mv krb5.conf /etc/krb5.conf

## Run Jupyterhub
RUN conda install -c conda-forge -y oauthenticator
RUN jupyterhub --generate-config
RUN sed -i "s|# c.Spawner.default_url = ''|c.Spawner.default_url = '/lab'|g" jupyterhub_config.py

## Cleaning
RUN apt --purge autoremove -y
RUN apt clean -y

## Environment Set2
ENV DEBIAN_FRONTEND teletype
## ========== End-Of-Dockerfile ==========
