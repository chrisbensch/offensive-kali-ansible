#!/bin/bash

pip install github3.py
# git pulls the most current changes and begins playbook
clear && git pull && ansible-playbook -i ansible/local.ini site.yml -K