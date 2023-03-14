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
    clang \
    binaryen \
    nodejs \
    npm

RUN apt-get clean && rm -rf /var/lib/apt/lists/* tmp/*

### Yarn ###
RUN npm install --global yarn

## Docker ##
#RUN apt-get install -yq --no-install-recommends \
#    ca-certificates \
#    gnupg \
#    lsb-release
#RUN mkdir -m 0755 -p /etc/apt/keyrings
#RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

#RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

#RUN apt-get update

#RUN apt-get install -yq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
