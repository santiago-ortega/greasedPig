#!/bin/bash

#######################################################################
# Copyright 2017 IBM Corp. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#######################################################################


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ../environment.sh

WORK_DIR=${DEST_DIR}/ubuntuiso

if [ "${LOG_FILE}x" == "x" ]
then
  LOG=${LOG_DIR}/$0_$(date +%Y-%m-%d_%H_%M).log
else
  LOG=${LOG_FILE}
fi

if [ ! -d ${DEST_DIR} ]
then
mkdir -p ${DEST_DIR}
fi

# Remaster a CD, ie, download a non graphical ubuntu installation ISO
#(server or alternate installation CD), mount it

#$ sudo su -
if [ ! -d ${DEST_DIR}/iso ]
then
mkdir -p ${DEST_DIR}/iso
fi

mount -o loop ${DIR}/${os_iso} ${DEST_DIR}/iso >> ${LOG} 2>&1

#Copy the relevant files to a different directory
if [ ! -d ${WORK_DIR} ]
then
mkdir -p ${WORK_DIR}
fi

cp -rT ${DEST_DIR}/iso ${WORK_DIR}

umount ${DEST_DIR}/iso

cp ks.cfg ${WORK_DIR}/
cp ks.preseed ${WORK_DIR}/
cp txt.cfg ${WORK_DIR}/isolinux/txt.cfg

#This next line is a workaround for a bug
#http://askubuntu.com/questions/809062/error-couldnt-find-hvm-kernel-during-kvm-guest-install-of-ubuntu-server-16-04
#cp -r ${DEST_DIR}/ubuntuiso/install/netboot/ubuntu-installer/amd64 ${DEST_DIR}/ubuntuiso/install/netboot/ubuntu-installer/i386

if [ -d ${KEY_DIR} ]
then
  rm -rf ${KEY_DIR}
fi

mkdir ${KEY_DIR}/
ssh-keygen -t rsa -f ${KEY_DIR}/id_rsa -P ''  >> ${LOG}
cp ${KEY_DIR}/id_rsa.pub ${WORK_DIR}/authorized_keys

#Prevent the language selection menu from appearing
sed -i "s/timeout 0/timeout 10/" ${WORK_DIR}/isolinux/isolinux.cfg
cd ${WORK_DIR}
echo en >isolinux/lang

mkisofs -D -r -V "ATTENDLESS_UBUNTU" -cache-inodes \
        -J -l -b isolinux/isolinux.bin \
        -c isolinux/boot.cat -log-file ${LOG} \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        -o ${DEST_DIR}/autoinstall.iso ${WORK_DIR}

cd -

rm -rf ${WORK_DIR}
