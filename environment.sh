#!/bin/bash

####################
# Operating system
####################
os_name=ubuntu
os_version=16.04
os_iso=${os_name}-${os_version}-server-amd64.iso

####################
# Conductor for Containers
####################
installer_version=1.1.0
installer_img=cfc-installer-docker-images-${installer_version}.tar

####################
# VMs data
####################
PASSWORD=temp4Now
VM_WORKING_DIR=/tmp/
RAM=10240
VCPU=4

####################
# Master VM data
####################
master_vm_name=${os_name}${os_version}.master
master_ip=10.10.0.31
master_mac_addr=5c:f3:fc:00:00:00
master_size=100G
master_data_size=200G

####################
# Worker VM data
####################
worker_vm_name=${os_name}${os_version}.worker
worker_ip=10.10.0.32
worker_mac_addr=5c:f3:fc:00:00:11
worker_size=100G
worker_data_size=200G

####################
# Clone VM data
####################
clone_vm_name=${os_name}${os_version}.clone
clone_ip=10.10.0.33
clone_mac_addr=5c:f3:fc:00:00:33

####################
# Build locations
####################
DEST_DIR=/images/build
LOG_DIR=${DEST_DIR}/log
IMG_DIR=${DEST_DIR}/img
INSTALLER_IMG_DIR=${DEST_DIR}/installer
KEY_DIR=${DEST_DIR}/keys
