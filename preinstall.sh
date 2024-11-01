#!/bin/bash

# For whatever reason, I cannot seem to get ansible to correctly recognize
# the github3.py module if installed during a playbook.  The below should
# be temporary.

pipx install github3.py --include-deps && pipx ensurepath

# Qterminal seems to overwrite it's settings when closed so I do the install
# from Xterm to ensure there are no issues.
sudo apt update && sudo apt -y install ansible-core xterm

# This installs the two external roles I need.
ansible-galaxy install -r requirements.yml

