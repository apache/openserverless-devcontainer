FROM node:22
# Install basic development tools
RUN \
    echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc |  apt-key add - && \
    apt update && \
    apt install -y less man-db sudo vim jq python-is-python3 python3-virtualenv \
    locales postgresql-client-16 openssh-server tini supervisor

# setup env
RUN \
    touch /.bestiaenv && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale ANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN userdel node ; rm -Rvf /home/node
ENV HOME=/home
ENV OPS_HOME=/home
ENV OPS_BRANCH=main
ENV PATH=/home/.local/bin:/usr/local/bin:/usr/bin:/bin
RUN printf "OPS_HOME=$OPS_HOME\nOPS_BRANCH=$OPS_BRANCH\nPATH=$PATH\n" >/etc/environment
RUN \
    curl -sL https://raw.githubusercontent.com/apache/openserverless-cli/refs/heads/main/install.sh | bash ;\
    ops -t

ADD supervisord.ini /etc/supervisord.ini
ADD start.sh /usr/local/bin/start.sh

RUN mkdir /home/workspace
WORKDIR /home/workspace
ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/start.sh"]
