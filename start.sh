#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

export HOME=/home/openserverless

#setup sshd
mkdir -p /run/sshd
ssh-keygen -A

# setup user workspace
if test -z "$USERID"
then USERID=1000
fi
/usr/sbin/useradd -u "$USERID" -d $HOME -o -U -s /bin/bash openserverless

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

/usr/bin/ops -t

touch $HOME/.bashrc
echo ARCH="$(dpkg --print-architecture)" >>~/.bashrc
echo 'export PATH="$HOME/.local/bin:$HOME:$HOME/.ops/linux-$ARCH/bin:$PATH"' >>~/.bashrc

# fix permissions
chmod 0755 $HOME
chown -Rf "$USERID" $HOME

# start supervisor
supervisord -c /etc/supervisord.ini
