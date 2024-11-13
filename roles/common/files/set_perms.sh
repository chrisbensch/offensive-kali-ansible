#!/bin/bash

# Set ownership of /opt to kali:kali
chown -R kali:kali /opt

# Set ownership of /home/kali to kali:kali
chown -R kali:kali /home/kali

echo "Ownership of /opt and /home/kali set to kali:kali"
