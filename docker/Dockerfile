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

### INSTALL PYENV AND PYTHON 3.7.4
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
RUN pyenv install 3.7.4 && pyenv global 3.7.4

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
ENV PACKAGE_NAME=E2E-RL-Navigation
COPY . /home/${USER}/${PACKAGE_NAME}

### DISABLE EOL NOETIC WARNINGS
ENV DISABLE_ROS1_EOL_WARNINGS=1

### CREATE AND ACTIVATE PYTHON VIRTUAL ENVIRONMENT
USER root
WORKDIR /home/${USER}/${PACKAGE_NAME}
RUN python3.7 -m venv loomo
ENV VIRTUAL_ENV=/home/${USER}/${PACKAGE_NAME}/loomo
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

### UPGRADE PIP AND INSTALL DEPENDENCIES
RUN python -m pip install -U pip wheel setuptools --no-cache-dir
RUN pip install "numpy==1.17.5" "Cython<0.29.22" "setuptools<60" "wheel<0.37"
# RUN pip install "numpy<1.18" Cython==0.29.35
WORKDIR /home/${USER}/${PACKAGE_NAME}
RUN sudo chmod +x dependencies_Autonomous_driving_pipeline.sh && \
    ./dependencies_Autonomous_driving_pipeline.sh && \
    pip install -r requirements.txt

### INSTALL TRAJNET-MMTRACKING-MMPOSE
WORKDIR /home/${USER}/${PACKAGE_NAME}
RUN sudo chmod +x trajnet.sh mmtracking.sh mmpose.sh
RUN ./trajnet.sh && \
    ./mmtracking.sh && \
    ./mmpose.sh

### BUILD CATKIN WORKSPACE
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    python3-empy \
    python3-catkin-tools \
    && rm -rf /var/lib/apt/lists/*
RUN /bin/bash -c "source loomo/bin/activate && pip uninstall -y em empy || true && pip install empy==3.3.4"
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin_make -DCMAKE_POLICY_VERSION_MINIMUM=3.5"

### DOWNLOAD PRETRAINED TRACKER WEIGHTS
RUN cd /home/tommaso/${PACKAGE_NAME}/src/perception/scripts/trackers && \
    mkdir -p weights && \
    cd weights && \
    wget https://download.openmmlab.com/mmtracking/sot/stark/stark_st2_r50_50e_lasot/stark_st2_r50_50e_lasot_20220416_170201-b1484149.pth

### SETUP ENTRYPOINT
USER ${USER}
COPY /docker/entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh ; sudo chown ${USER} /entrypoint.sh \
 && echo "cd "${PWDR} >> /entrypoint.sh \
 && echo 'exec bash -i -c $@' >> /entrypoint.sh \
 && cat /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["bash"]