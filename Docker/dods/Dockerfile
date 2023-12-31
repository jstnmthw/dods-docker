#
# LinuxGSM Base Dockerfile
#
# https://github.com/GameServerManagers/docker-linuxgsm
#
FROM gameservermanagers/steamcmd:ubuntu-22.04

LABEL maintainer="LinuxGSM <me@danielgibbs.co.uk>"
ENV DEBIAN_FRONTEND noninteractive
ENV TERM=xterm
ENV LGSM_GITHUBUSER=GameServerManagers
ENV LGSM_GITHUBREPO=LinuxGSM
ENV LGSM_GITHUBBRANCH=master
ENV LGSM_LOGDIR=/data/log
ENV LGSM_SERVERFILES=/data/serverfiles
ENV LGSM_DATADIR=/data/data
ENV LGSM_CONFIG=/data/config-lgsm
ENV UPDATE_CHECK=1800
ENV USER=linuxgsm
ENV UID=1000
ENV GID=1000
ENV CONFIG_GITHUB_USERNAME=${GITHUB_USERNAME}
ENV CONFIG_GITHUB_TOKEN=${GITHUB_TOKEN}
ENV CONFIG_GITHUB_REPO=${GITHUB_REPO}
ENV CONFIG_GITHUB_BRANCH=${GITHUB_BRANCH:-"main"}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

## Install Base LinuxGSM Requirements
RUN dpkg --add-architecture i386 \
  && apt-get update \
  && apt-get install -y software-properties-common \
  && add-apt-repository multiverse \
  && add-apt-repository ppa:git-core/ppa \
  && apt-get update \
  && apt-get install -y \
  bc \
  binutils \
  bsdmainutils \
  bzip2 \
  ca-certificates \
  cpio \
  cron \
  curl \
  distro-info \
  file \
  git \
  gnupg \
  gosu \
  gzip \
  hostname \
  jq \
  lib32gcc-s1 \
  lib32stdc++6 \
  netcat \
  python3 \
  sudo \
  tar \
  tmux \
  unzip \
  util-linux \
  uuid-runtime \
  wget \
  xz-utils \
  iproute2 \
  iputils-ping \
  nano \
  vim \
  expect \
  libc6:i386 \
  libncurses5:i386 \
  libstdc++6:i386 \
  libtinfo5:i386 \
  rsync \
  && apt-get -y autoremove \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && rm -rf /var/tmp/*

# Install Node.js
RUN set -uex \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && NODE_MAJOR=20 \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
  && apt-get update \
  && apt-get install nodejs -y \
  && apt-get -y autoremove \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && rm -rf /var/tmp/*

# Install GameDig https://docs.linuxgsm.com/requirements/gamedig
RUN npm install -g gamedig

WORKDIR /app

## Add linuxgsm user
RUN mkdir /data \
  # Create the user
  && groupadd --gid $GID $USER \
  && useradd --uid $UID --gid $GID -m $USER \
  #
  # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
  && echo $USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER \
  && chmod 0440 /etc/sudoers.d/$USER \
  && chown $USER:$USER /data \
  && chown $USER:$USER /app

## Download linuxgsm.sh
RUN set -ex \
  && curl -Lo linuxgsm.sh "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/${LGSM_GITHUBBRANCH}/linuxgsm.sh" \
  && chmod +x linuxgsm.sh

RUN git clone --filter=blob:none --no-checkout --sparse https://github.com/GameServerManagers/LinuxGSM.git \
  && cd LinuxGSM \
  && git sparse-checkout set --cone \
  && git sparse-checkout set lgsm/modules \
  && git checkout ${LGSM_GITHUBBRANCH} \
  && mkdir -p /app/lgsm/modules \
  && mv lgsm/modules/* /app/lgsm/modules \
  && chmod +x /app/lgsm/modules/* \
  && cd ../ \
  && rm -rf LinuxGSM \
  && chown -R $USER:$USER /app

ARG CACHEBUST=1
RUN echo "$CACHEBUST"

COPY entrypoint.sh /app/entrypoint.sh
COPY entrypoint-user.sh /app/entrypoint-user.sh
COPY entrypoint-healthcheck.sh /app/entrypoint-healthcheck.sh
COPY mods.expect /app/mods-expect.sh
COPY install-mods.txt /app/install-mods.txt
COPY install-config.sh /app/install-config.sh

ARG SHORTNAME=dods
ENV GAMESERVER=dodsserver
ENV FOLDERNAME=dod

## Auto install game server requirements
RUN depshortname=$(curl --connect-timeout 10 -s https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/lgsm/data/ubuntu-22.04.csv |awk -v shortname="dods" -F, '$1==shortname {$1=""; print $0}') \
  && if [ -n "${depshortname}" ]; then \
  echo "**** Install ${depshortname} ****" \
  && apt-get update \
  && apt-get install -y ${depshortname} \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
  fi

HEALTHCHECK --interval=1m --timeout=1m --start-period=2m --retries=1 CMD /app/entrypoint-healthcheck.sh || exit 1

RUN date > /build-time.txt

ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]