#!/bin/bash

# For whatever reason, I cannot seem to get ansible to correctly recognize
# the github3.py module if installed during a playbook.  The below should
# be temporary.

sudo apt update && sudo apt install -y python3 python3-pip ansible-core

sudo pip3 install github3.py

# This installs the two external roles I need.
ansible-galaxy install -r requirements-wsl.yml

