#!/bin/bash
sudo mkdir -p /run/sshd
sudo ssh-keygen -A
mkdir -p ~/.ssh
PORT=${SSH_PORT:-2222} d
if test -n "$AUTHORIZED_KEY"
then echo "$AUTHORIZED_KEY" >>~/.ssh/authorized_keys
     chmod 600 ~/.ssh/authorized_keys
fi
if test -d /workspace
then
    ln -sf /workspace ~/workspace
    sudo chown -R 1000:1000 /workspace
fi
echo Starting ssh in port $PORT
sudo /usr/sbin/sshd -p $PORT -D