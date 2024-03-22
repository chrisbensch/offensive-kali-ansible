#!/bin/bash

# git pulls the most current changes and begins playbook
clear && git pull && ansible-playbook -i ansible/local.ini site-wsl.yml -K