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

if [ "${LOG_FILE}x" == "x" ]
then
  LOG=${LOG_DIR}/$0_$(date +%Y-%m-%d_%H_%M).log
else
  LOG=${LOG_FILE}
fi

if [ "$1x" == "x" ]
then
  name=${master_vm_name}
  mac_address=${master_mac_addr}
  size=${master_size}
  data_size=${master_data_size}
else
  name=${worker_vm_name}
  mac_address=${worker_mac_addr}
  size=${worker_size}
  data_size=${worker_data_size}
fi

if [ ! -d ${IMG_DIR} ]
then
  mkdir -p ${IMG_DIR}
fi

qemu-img create -f qcow2 \
                  -o preallocation=metadata \
                  ${IMG_DIR}/${name}.qcow2 ${size} >>${LOG}
qemu-img create -f qcow2 \
                  -o preallocation=metadata \
                  ${IMG_DIR}/${name}.data.qcow2 ${data_size} >>${LOG}

virt-install \
 -n ${name} \
 --description "Ubuntu KVM VM ${name}" \
 --os-type=Linux \
 --os-variant=generic \
 --ram=${RAM} \
 --vcpus=${VCPU} \
 --disk path=${IMG_DIR}/${name}.qcow2,bus=virtio \
 --disk path=${IMG_DIR}/${name}.data.qcow2,bus=virtio \
 --video qxl  \
 --cdrom ${DEST_DIR}/autoinstall.iso \
 --network bridge:br0 \
 --mac ${mac_address} \
 --noautoconsole -v >>${LOG}

 #Provide the file system password and then type control+]
