sudo docker stop data-lab
sudo docker rm data-lab

sudo docker rmi bigdataplot/jupyter-spark-lab:1.31

sudo docker build -t bigdataplot/jupyter-spark-lab:1.31 .

sudo docker logs data-lab

sudo push bigdataplot/jupyter-spark-lab:1.31



sudo docker run --name data-lab \
    --detach \
    --publish 8888:8888 \
    --volume /apps/datahub:/apps/datahub \
    bigdataplot/jupyter-spark-lab:1.31

sudo docker run --name data-lab \
    -it \
    --publish 8888:8888 \
    --volume /apps/datahub:/apps/datahub \
    bigdataplot/jupyter-spark-lab:1.31 bash


    --restart \


