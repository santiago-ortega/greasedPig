#!/bin/bash

####################
# Upate the hostname
####################
echo "What is the hostname?"
read hostname

hostname ${hostname}
echo "${hostname}" > /etc/hostname


####################
# Upate the hosts file
####################
echo "What is the IP Address?"
read ip

sed -i "1 i ${ip} ${hostname}" /etc/hosts
