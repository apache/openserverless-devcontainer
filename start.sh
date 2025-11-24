#!/bin/bash

#setup sshd
mkdir -p /run/sshd
ssh-keygen -A

# update ops
export HOME=/home
export OPS_HOME=/home
ops -update

# setup user workspace
if test -z "$USERID"
then USERID=1000
fi
/usr/sbin/useradd -u "$USERID" -d $HOME -o -U -s /bin/bash devel

# add ssh key
if test -n "$SSHKEY"
then
    mkdir -p $HOME/.ssh
    touch $HOME/.ssh/authorized_keys
    if ! grep "$SSHKEY" $HOME/.ssh/authorized_keys >/dev/null
    then echo "$SSHKEY" >>$HOME/.ssh/authorized_keys
    fi
    chmod 600 $HOME/.ssh/authorized_keys
    chmod 700 $HOME/.ssh
fi

# fix permissions
chmod 0755 $HOME
chown -Rf "$USERID" /home

# start supervisor
supervisord -c /etc/supervisord.ini
