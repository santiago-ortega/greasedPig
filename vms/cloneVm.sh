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
