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
source environment.sh

cd vms
${DIR}/vms/cleanClone.sh ${clone_vm_name}
cd -

sudo rm -rf ${DEST_DIR}
sudo rm -rf ${WORK_DIR}
sudo umount ${DEST_DIR}/iso
for name in `virsh list --all | awk '{ print $2}' | grep ubuntu16.04`
do
  echo "Name: ${name}"
  virsh destroy ${name}
  virsh undefine ${name}
done
