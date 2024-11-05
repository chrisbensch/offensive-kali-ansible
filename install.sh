#!/bin/bash


#python3 -m venv ansible_env
#source ansible_env/bin/activate
#pip install ansible github3.py

#pip install github3.py
# git pulls the most current changes and begins playbook
clear && git pull && ansible-playbook -i ansible/local.ini site.yml -K