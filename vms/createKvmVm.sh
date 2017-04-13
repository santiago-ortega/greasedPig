#!/bin/bash

#######################################################################
# INTERNATIONAL BUSINESS MACHINES CORPORATION PROVIDES THIS SOFTWARE ON
# AN "AS IS" BASIS AND IBM DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED,
# INCLUDING, BUT NOT LIMITED TO, THE WARRANTY OF NON-INFRINGEMENT AND THE
# IMPLIED WARRANTIES OF  MERCHANTABILITY OR FITNESS FOR A PARTICULAR
# PURPOSE.  IBM SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR OPERATION OF
# THIS SOFTWARE.  IBM HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT,
# UPDATES, ENHANCEMENTS OR MODIFICATIONS TO THE SOFTWARE.
#######################################################################


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ../environment.sh

LOG=${DEST_DIR}/$0_$(date +%Y-%m-%d_%H_%M).log

if [ "$1x" == "x" ]
then
  name=${master_vm_name}
  mac_address=${master_mac_addr}
else
  name=${worker_vm_name}
  mac_address=${worker_mac_addr}
fi

if [ ! -d ${IMG_DIR} ]
then
  mkdir -p ${IMG_DIR}
fi

qemu-img create -f qcow2 \
                  -o preallocation=metadata \
                  ${IMG_DIR}/${name}.qcow2 100G >>${LOG}
qemu-img create -f qcow2 \
                  -o preallocation=metadata \
                  ${IMG_DIR}/${name}.data.qcow2 200G >>${LOG}

virt-install \
 -n ${name} \
 --description "Ubuntu KVM VM ${name}" \
 --os-type=Linux \
 --os-variant=generic \
 --ram=10240 \
 --vcpus=4 \
 --disk path=${IMG_DIR}/${name}.qcow2,bus=virtio,size=100 \
 --disk path=${IMG_DIR}/${name}.data.qcow2,bus=virtio,size=200 \
 --video qxl  \
 --cdrom ${DEST_DIR}/autoinstall.iso \
 --network bridge:br0 \
 --mac ${mac_address} \
 --noautoconsole -v >>${LOG}

 #Provide the file system password and then type control+]
