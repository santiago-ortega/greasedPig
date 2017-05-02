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

original=$1
name=$2

wait_till_running(){
  echo "====================="
  echo "Waiting until it is running"
  COUNTER=0
  TIME=20
  while [ "`virsh list --all | grep $1 | awk '{ print $3 }'`x" !=  "runningx"  ]
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

wait_till_shutdown(){
  echo "====================="
  echo "Waiting until it is shutdown"
  COUNTER=0
  TIME=20
  while [ "`virsh list --all | grep $1 | awk '{ print $3 }'`x" ==  "runningx"  ]
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

virsh shutdown ${original}

wait_till_shutdown ${original}

virt-clone -o ${original} --name ${name} \
           --file ${IMG_DIR}/${name}.qcow2 \
           --file ${IMG_DIR}/${name}.data.qcow2 \
           --mac ${clone_mac_addr}

virsh start ${name}

wait_till_running ${name}

./finishCloneVm.exp ${name} ${PASSWORD} ${LOG_FILE}

./ssh_expect.exp ${clone_ip} ${LOG_FILE}
