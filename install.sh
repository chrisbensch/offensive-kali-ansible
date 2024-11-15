#!/bin/bash


# Qterminal seems to overwrite it's settings when closed so I do the install
# from Xterm to ensure there are no issues.
sudo apt update > /dev/null 2>&1 && sudo apt -y install ansible-core xterm > /dev/null 2>&1

# This installs the two external roles I need.
ansible-galaxy install -r requirements.yml

# git pulls the most current changes and begins playbook
clear && git pull && ansible-playbook -i ansible/local.ini site.yml