#!/bin/bash
jupyterhub -f /apps/jupyterhub/jupyterhub_config.py > /apps/log/jupyterhub.log 2>&1 &
