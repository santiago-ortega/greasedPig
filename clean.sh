#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source environment.sh

${DIR}/vms/cleanClone.sh ${clone_vm_name}

sudo rm -rf ${DEST_DIR}
sudo rm -rf ${WORK_DIR}
sudo umount ${DEST_DIR}/iso
for name in `virsh list --all | awk '{ print $2}' | grep ubuntu16.04`
do
  echo "Name: ${name}"
  virsh destroy ${name}
  virsh undefine ${name}
done
