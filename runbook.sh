## Stop/Remove Container
sudo docker stop data-lab
sudo docker rm data-lab

## Remove Image
sudo docker rmi bigdataplot/jupyter-spark-lab:1.31

## Build from Dockerfile
sudo docker build -t bigdataplot/jupyter-spark-lab:1.33 .

## Check Docker Logs
sudo docker logs data-lab

## Login and Push a Image
sudo docker login --username bigdataplot
sudo docker push bigdataplot/jupyter-spark-lab:1.33


## Setup Host Environments
sudo addgroup docker && \
sudo newgrp docker

sudo mkdir -p /apps/datahub && \
sudo chmod -R 770 /apps/datahub && \
sudo chown -R root:docker /apps/datahub

## Bring up the Jupyter-Spark-Lab (Modify ports if necessary)
sudo docker run --name data-lab \
    --detach \
    --restart always\
    --publish 8888:8888 \
    --volume /apps/datahub:/apps/datahub \
    bigdataplot/jupyter-spark-lab