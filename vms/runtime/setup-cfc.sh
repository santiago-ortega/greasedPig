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
source ./environment.sh
KEY_DIR=${DIR}/keys_dir

remove_locks(){
  echo "====================="
  echo "Removing the locks"
  rm -f /var/lib/dpkg/lock
  rm -f /var/lib/apt/lists/lock
  rm -f /var/cache/apt/archives/lock
}

generate_ssh(){
  echo "====================="
  echo "Generating ssh keys"
  mkdir -p ${KEY_DIR}

  ssh-keygen -t rsa -f ${KEY_DIR}/ssh_key -P ''

}

copy_sshkey(){
  if [ ! -f ${KEY_DIR}/ssh_key.pub ]
  then
    generate_ssh
  fi
  cat ${KEY_DIR}/ssh_key.pub | ssh -i ./id_rsa root@$1 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
  ssh -i ./id_rsa root@$1 "echo $2 | sudo -S cp -r ~/.ssh /root/"
}

run_installer(){
  echo "====================="
  echo "Running the CfC installer"
  docker run -e LICENSE=accept --net=host --rm --entrypoint=cp \
             -v ${DIR}:/data ibmcom/cfc-installer:${INSTALLER_VERSION} -r cluster /data
  cp ${DIR}/hosts ${DIR}/cluster/
  sed -i "s/network_type: flannel/network_type: calico/" ${DIR}/cluster/config.yaml
  echo "always_pull_images: false" >> ${DIR}/cluster/config.yaml
  cp ${KEY_DIR}/ssh_key ${DIR}/cluster/
  docker run -e LICENSE=accept --net=host --rm -t -v "$(pwd)/cluster":/installer/cluster ibmcom/cfc-installer:${INSTALLER_VERSION} install
  mv ./kubectl /usr/local/bin/kubectl
}

#########################
# MAIN
#########################

LOCAL_IP=$(ip -o -4 addr list $(ip -o -4 route show to default | awk '{print $5}' | head -1) | awk '{print $4}' | cut -d/ -f1 | head -1)
PASSWORD=temp4Now

remove_locks
generate_ssh
##########
#TODO
#Key exchange should be done between the VMs so that
#a new key is used only to scramble the original key.

#$1 ip address
#$2 password
copy_sshkey ${LOCAL_IP} ${PASSWORD}
echo "[master]" > ${DIR}/hosts
echo "${LOCAL_IP}" >> ${DIR}/hosts
echo "" >> ${DIR}/hosts
echo "[worker]" >> ${DIR}/hosts
for ip in $(echo $1 | sed "s/,/ /g");
do
  copy_sshkey ${ip} ${PASSWORD}
  echo "${ip}" >> ${DIR}/hosts
done
echo "" >> ${DIR}/hosts
echo "[proxy]" >> ${DIR}/hosts
echo "${LOCAL_IP}" >> ${DIR}/hosts

run_installer
