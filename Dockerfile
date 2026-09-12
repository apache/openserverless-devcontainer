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

FROM golang:1.25 AS builder
RUN go install github.com/apache/openserverless-cli/cmd/ops@0.9.0

FROM node:22
COPY --from=builder /go/bin/ops /usr/local/bin/ops

ARG DEVCONTAINER_IMAGE_DEFAULT=docker.io/apache/openserverless-devcontainer
ARG DEVCONTAINER_TAG_DEFAULT=latest
# Install basic development tools
RUN \
    echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt update && \
    apt install -y less sudo jq nano python-is-python3 python3-virtualenv \
    locales postgresql-client-16 openssh-server tini supervisor && \
    rm  -rf /var/lib/apt/lists/*

# setup env
RUN \
    touch /.bestiaenv && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale ANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

ENV HOME=/home/openserverless
ENV PATH=/home/.local/bin:/usr/local/bin:/usr/bin:/bin
RUN /usr/local/bin/ops -t

ADD supervisord.ini /etc/supervisord.ini
ADD start.sh /usr/local/bin/start.sh

RUN mkdir -p /home/openserverless
WORKDIR /home/openserverless
# Apache release metadata (see DISCLAIMER, LICENSE, NOTICE, WARN)
COPY DISCLAIMER LICENSE NOTICE /

ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/start.sh"]
