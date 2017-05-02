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

ssh_command(){
  ssh -i ${KEY_DIR}/id_rsa \
                  root@$1 "$2"
}

run_installer(){
  echo "====================="
  echo "Running the CfC installer"
  ssh -i ${KEY_DIR}/id_rsa \
       root@$1 "docker pull  ibmcom/cfc-installer:${installer_version}"
  ssh -i ${KEY_DIR}/id_rsa \
       root@$1 "docker run -e LICENSE=accept --net=host --rm --entrypoint=cp \
             -v /root/:/data ibmcom/cfc-installer:${installer_version} -r cluster /data"
  ssh_command $1 "echo '[master]' >/root/cluster/hosts"
  ssh_command $1 "echo $1 >> /root/cluster/hosts"
  ssh_command $1 "echo '[worker]' >>/root/cluster/hosts"
  ssh_command $1 "echo $1 >> /root/cluster/hosts"
  ssh_command $1 "echo '[proxy]' >>/root/cluster/hosts"
  ssh_command $1 "echo $1 >> /root/cluster/hosts"
  ssh_command $1 "hostname ${clone_vm_name}"
  ssh_command $1 "echo ${clone_vm_name} > /etc/hostname"
  ssh_command $1 "echo \"$1 ${clone_vm_name}\" >> /etc/hosts"

  ssh -i ${KEY_DIR}/id_rsa \
       root@$1 "sed -i 's/network_type: flannel/network_type: calico/' /root/cluster/config.yaml"
  scp -i ${KEY_DIR}/id_rsa ${KEY_DIR}/id_rsa root@$1:/root/cluster/ssh_key
  ssh_command $1 "docker run -e LICENSE=accept --net=host --rm -t -v /root/cluster:/installer/cluster ibmcom/cfc-installer:${installer_version} install"

}

extract_images(){
  ssh_command $1 "for m in \$(docker images | grep -v REPOSITORY | awk '{print \$1\":\"\$2}') ; do echo \$m; docker save -o \${m//\//-}.tar \${m}  ;done"
  ssh_command $1 "gzip *.tar; tar -cvf ${installer_img} ./*.tar.gz"
  if [ ! -d ${INSTALLER_IMG_DIR} ]
  then
    mkdir -p ${INSTALLER_IMG_DIR}
  fi
  scp -i ${KEY_DIR}/id_rsa root@$1:/root/${installer_img} ${INSTALLER_IMG_DIR}
}

./cloneVm.sh ${master_vm_name} ${clone_vm_name}

run_installer ${clone_ip}
extract_images ${clone_ip}

./cleanClone.sh
