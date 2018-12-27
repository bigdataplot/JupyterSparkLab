#!/bin/bash

## ======================================== ##
## Create User Profile Backups (Host)
## ======================================== ##
## First create a backup folder
rm -rf /apps/datahub/prfmve/ || true
mkdir -p /apps/datahub/prfmve/

## Setup UID filter limit (Ubuntu from 1000/CentOS from 500):
export UGIDLIMIT=1000

## Now copy /etc/passwd accounts to /apps/datahub/prfmve/passwd.mig using awk to filter out system account (i.e. only copy user accounts)
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/passwd > /apps/datahub/prfmve/passwd.mig

## Copy /etc/group file:
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534)' /etc/group > /apps/datahub/prfmve/group.mig

## Copy /etc/shadow file:
awk -v LIMIT=$UGIDLIMIT -F: '($3>=LIMIT) && ($3!=65534) {print $1}' /etc/passwd | tee - |egrep -f - /etc/shadow > /apps/datahub/prfmve/shadow.mig

## Copy /etc/gshadow (rarely used):
cp /etc/gshadow /apps/datahub/prfmve/gshadow.mig