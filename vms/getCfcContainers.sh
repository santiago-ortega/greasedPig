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
