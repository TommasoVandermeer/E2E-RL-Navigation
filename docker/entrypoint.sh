#!/bin/bash
set -e

# Setup environment
source $HOME/.bashrc
source /opt/ros/noetic/setup.bash

# Change owner of file
# sudo chown $USER: /home/.bash_history
sudo chown $USER: -R /home/$USER

# Start in home directory
cd $HOME