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

touch ~/.bashrc
echo ARCH="$(dpkg --print-architecture)" >>~/.bashrc
echo 'export PATH="$HOME/.local/bin:$HOME:$HOME/.ops/linux-$ARCH/bin:$PATH"' >>~/.bashrc

if [ -n "$OPS_PASSWORD" ] && [ -n "$OPS_USER" ] && [ -n "$OPS_APIHOST" ]
then
    cd $HOME
    echo -e "OPS_USER=$OPS_USER\nOPS_PASSWORD=$OPS_PASSWORD\nOPS_APIHOST=$OPS_APIHOST\n" >.env
    ops ide login
fi

# fix permissions
chmod 0755 $HOME
chown -Rf "$USERID" /home

# start supervisor
supervisord -c /etc/supervisord.ini
