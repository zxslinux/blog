#!/bin/bash
SSH_PRIVATE_KEY=$1
REMOTE_HOST=$2

if [ -z ${SSH_PRIVATE_KEY} ];then
    echo "var SSH_PRIVATE_KEY cannot be null!"
    exit 1
fi

if [ -z ${REMOTE_HOST} ];then
    echo "var REMOTE_HOST cannot be null!"
    exit 2
fi

mkdir $HOME/.ssh
chmod 700 $HOME/.ssh

echo ${SSH_PRIVATE_KEY} > $HOME/.ssh/id_rsa
chmod 600 $HOME/.ssh/id_rsa

ssh-keyscan -t rsa $REMOTE_HOST >> $HOME/.SSH/known_hosts
chmod 600 $HOME/.ssh/known_hosts

rsync -avz -delete public/ root@zxslinux.world:/usr/local/html/