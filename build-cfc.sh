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

###########################
# Needs DNS, expect package,
# libvirt package
###########################


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/environment.sh

ssh_command(){
  ssh -i ${KEY_DIR}/id_rsa root@$1 "$2"
}

wait_till_installed(){
  echo "====================="
  echo "Waiting until it is installed"
  COUNTER=0
  TIME=20
  while [ `ps -ef | grep "${1}" | wc -l` -gt 1  ]
  do
    echo -ne .
    sleep 1s
    if [ ${COUNTER} -eq 20 ]
    then
      echo " ${TIME} seconds"
      let TIME+=20
      let COUNTER=-1
    fi
    let COUNTER+=1
  done
}

generate_ubuntu_iso(){
  echo "====================="
  echo "Creating the Ubuntu ISO autoinstall image"
  if [ ! -f ${os_iso} ]
  then
    echo "The ${os_iso} was not found under $(pwd)."
    echo "Download the file ${os_iso} and place it under $(pwd)."
    exit 1
  fi
  ./createUbuntuImage.sh
}

start_vm(){
  virsh start $1
  ./finishVmCreation.exp $1 ${PASSWORD} ${LOG_FILE}
}

create_vms(){
  echo "====================="
  echo "Creating VMs"

  echo "Requires DNS for mac addressese"
  echo "${master_ip}=${master_mac_addr}"
  echo "${worker_ip}=${worker_mac_addr}"
  echo "${clone_ip}=${clone_mac_addr}"

  ./createKvmVm.sh &

  ./createKvmVm.sh worker &

  echo "Installing Ubuntu in the VMs"
  echo "This takes a long time!!!!!"
  sleep 60s
  wait_till_installed "${master_vm_name}"
  wait_till_installed "${worker_vm_name}"

  start_vm ${master_vm_name}

  start_vm ${worker_vm_name}
}

ssh_expect(){
  echo "====================="
  echo "Accepting the ssh hosts"

  rm -f /root/.ssh/known_hosts
  cd ${DIR}/vms
  ./ssh_expect.exp $1 ${LOG_FILE}
  ./ssh_expect.exp $2 ${LOG_FILE}
  cd -
}

install_docker(){
  echo "====================="
  echo "Installing Docker"
  scp -i ${KEY_DIR}/id_rsa installDocker.sh root@$1:${VM_WORKING_DIR}
  ssh_command $1 "${VM_WORKING_DIR}/installDocker.sh"
  ssh_command $1 "rm -f ${VM_WORKING_DIR}/installDocker.sh"
}

install_python(){
  echo "====================="
  echo "Installing Python"
  ssh_command $1 "apt -y update && sudo apt install -y python-minimal"
}

install_dockerpy(){
  echo "====================="
  echo "Installing docker_py"

  ssh_command $1 "apt-get install -y python-pip"
  ssh_command $1 "pip install docker-py"
}

update_env(){
  echo "#!/bin/bash" > ${DIR}/vms/runtime/environment.sh
  echo "PASSWORD=${PASSWORD}" >> ${DIR}/vms/runtime/environment.sh
  echo "INSTALLER_VERSION=${installer_version}" >> ${DIR}/vms/runtime/environment.sh
  chmod 700 ${DIR}/vms/runtime/environment.sh
}

load_installer(){
  echo "====================="
  echo "Loading the CfC installer"
  if [ -f ${INSTALLER_IMG_DIR}/${installer_img} ]
  then
    scp -i ${KEY_DIR}/id_rsa ${INSTALLER_IMG_DIR}/${installer_img} \
           root@$1:${VM_WORKING_DIR}
    ssh_command $1 "mkdir -p ${VM_WORKING_DIR}/cfc"
    ssh_command $1 "tar -xvf ${VM_WORKING_DIR}/${installer_img} -C ${VM_WORKING_DIR}/cfc"
    ssh_command $1 "for m in \$(ls ${VM_WORKING_DIR}/cfc) ; do echo \$m ; docker load -i ${VM_WORKING_DIR}/cfc/\$m ;done"
    ssh_command $1 "rm -f ${VM_WORKING_DIR}/${installer_img}"
    ssh_command $1 "rm -rf ${VM_WORKING_DIR}/cfc"
    scp -i ${KEY_DIR}/id_rsa ${DIR}/vms/runtime/setup-cfc.sh \
           root@$1:/home/k8s/
    update_env
    scp -i ${KEY_DIR}/id_rsa ${DIR}/vms/runtime/updateVm.sh \
                  root@$1:/home/k8s/
    scp -i ${KEY_DIR}/id_rsa ${DIR}/vms/runtime/environment.sh \
                  root@$1:/home/k8s/
    scp -i ${KEY_DIR}/id_rsa ${KEY_DIR}/id_rsa \
                  root@$1:/home/k8s/
  else
    ./getCfcContainers.sh

    start_vm ${master_vm_name}

    load_installer $1
  fi

}

install_packages(){
  install_python $1

  install_docker $1

  install_dockerpy $1

  load_installer $1
}

add_product_files() {
  echo "====================="
  echo "Adding product files to the Worker VM"
  if [ "${add}x" == "x"  ]
  then
    echo "No products will be added to Worker VM"
  else
    for script in `${DIR}/products/*.sh`
    do
      ${DIR}/products/${script}
    done
  fi

}

package_vms(){
  virsh dumpxml ${master_vm_name} > ${IMG_DIR}/${master_vm_name}.xml
  virsh dumpxml ${worker_vm_name} > ${IMG_DIR}/${worker_vm_name}.xml
}
#########################
# MAIN
#########################
mkdir -p ${LOG_DIR}
export LOG_FILE=${LOG_DIR}/build-cfc_$(date +%Y-%m-%d_%H_%M).log

if [ "$1x" == "x" ]
then
  echo "No products will be added to Worker VM"
  echo "To Add products use the argument 'add'"
else
  add=true
fi

cd ${DIR}/vms
generate_ubuntu_iso

create_vms

ssh_expect ${master_ip} ${worker_ip}

install_packages ${master_ip}

install_packages ${worker_ip}

add_product_files ${worker_ip}

cd -

exit 0
