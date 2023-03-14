FROM ubuntu:jammy

### Install base commands and dependencies ###

RUN apt-get update && \
    apt-get install -yq \
    git \
    git-lfs \
    sudo \
    wget \
    curl \
    vim \
    nano \
    less \
    jq \
    clang

RUN apt-get clean && rm -rf /var/lib/apt/lists/* tmp/*

# Install Nodejs and NPM
RUN dpkg --remove --force-remove-reinstreq libnode-dev
RUN dpkg --remove --force-remove-reinstreq libnode72:amd64
RUN curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
RUN apt-get install -yq nodejs

### Yarn ###
RUN npm install --global yarn

### Gitpod user ###

# '-l': see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    # passwordless sudo for users in the 'sudo' group
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
ENV HOME=/home/gitpod
WORKDIR $HOME

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=gitpod
ARG USER_UID=33333
ARG USER_GID=$USER_UID

ENV USER_HOME=/home/${USERNAME}

USER gitpod
