# JupyterSparkLab
### A multiple-user big data analytics platform on Docker. Comes with Jupyterhub (Jupyterlab), Spark and more.

Jupyterhub             |  Plot
:-------------------------:|:-------------------------:
![](https://github.com/bigdataplot/JupyterSparkLab/blob/master/pic/screenshot/top.png)  |  ![](https://github.com/bigdataplot/JupyterSparkLab/blob/master/pic/screenshot/matplotlib.png)
GitHub             |  DockerHub
![](https://github.com/bigdataplot/JupyterSparkLab/blob/master/pic/screenshot/github.png)  |  ![](https://github.com/bigdataplot/JupyterSparkLab/blob/master/pic/screenshot/dockerhub.png)


### To bring up your Jupyter-Spark-Lab environment, do the following steps:

- ### Setup Host
```shell
sudo addgroup docker && \
sudo newgrp docker
sudo mkdir -p /apps/datahub && \
sudo chmod -R 770 /apps/datahub && \
sudo chown -R root:docker /apps/datahub
```

- ### Bring up the Jupyter-Spark-Lab (Modify ports if necessary)
```shell
sudo docker run --name data-lab \
    --detach \
    --restart always\
    --publish 8888:8888 \
    --volume /apps/datahub:/apps/datahub \
    bigdataplot/jupyter-spark-lab
```

- ### Stop/Remove Container
```shell
sudo docker stop data-lab
sudo docker rm data-lab
```

- ### Remove Image
```shell
sudo docker rmi bigdataplot/jupyter-spark-lab:tagxxx
```

- ### Check Docker Logs
```shell
sudo docker logs data-lab
```