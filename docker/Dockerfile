### BASE IMAGE
ARG BASE_IMAGE=osrf/ros
ARG BASE_TAG=noetic-desktop-full-focal
FROM ${BASE_IMAGE}:${BASE_TAG}

### INSTALL BASIC UBUNTU TOOLS
# Prevent bash to ask for user input which may break the building process
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    sudo \
    wget \
    gedit \
    bash-completion \
    build-essential \
    python3-pip \
    python3-rosdep \
    python3-argcomplete \
    && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

### Install Python3.7
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*
ENV PYENV_ROOT=/opt/pyenv
ENV PATH=$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN curl https://pyenv.run | bash
RUN pyenv install 3.7 && pyenv global 3.7

### CREATE USER AND SETUP HOME DIRECTORY
ARG UID=1000
ARG GID=1000
ARG USER=ros
ARG PWDR=/
RUN addgroup --gid ${GID} ${USER} \
 && adduser --disabled-password --uid ${UID} --gid ${GID} ${USER} \
 && usermod -a -G dialout ${USER} \
 && echo ${USER}" ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/99_aptget \
 && chmod 0440 /etc/sudoers.d/99_aptget && chown root:root /etc/sudoers.d/99_aptget
ENV USER=${USER}
USER ${USER}
ENV HOME=/home/${USER}

### COPY CODE INTO THE IMAGE
COPY . /home/${USER}/E2E-RL-Navigation

### DISABLE EOL NOETIC WARNINGS
ENV DISABLE_ROS1_EOL_WARNINGS=1

### SETUP ENTRYPOINT
COPY /docker/entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh ; sudo chown ${USER} /entrypoint.sh \
 && echo "cd "${PWDR} >> /entrypoint.sh \
 && echo 'exec bash -i -c $@' >> /entrypoint.sh \
 && cat /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["bash"]