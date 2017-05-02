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

Work in progress

    1  pwd
    2  sudo lsblk
    3  sudo fdisk /dev/sdb
    4  sudo apt-get install lvm2
    5  sudo fdisk /dev/sdc
    6  modprobe dm-mod
    7  sudo vi /etc/modules
    8  sudo vi /etc/lvm/lvm.conf
    9  sudo vgscan
   10  sudo vgchange -a y
   11  sudo vgscan
   12  sudo pvcreate /dev/sda1
   13  df -h
   14  sudo pvcreate /dev/sda3
   15  sudo vgcreate data /dev/sdb1
   16  sudo lvcreate -l100%FREE -nvdata data
   17  sudo mke2fs -t ext4 /dev/data/vdata
   18  sudo mkdir /mnt/data
   19  sudo mount /dev/data/vdata /mnt/data
   20  sudo vi /etc/fstab
   21  df -h
   22  ls /
   23  ls /mnt/
   24  ls /mnt/data/
   25  lsvg
   26  sudo vgscan
   27  history
   28  lsblk
   29  sudo pvscan
   30  umount /mnt/data
   31  sudo umount /mnt/data
   32  rm -rf /mnt/data
   33  sudo rm -rf /mnt/data
   34  sudo mkdir /data
   35  sudo mount /dev/data/vdata /data
   36  sudo vi /etc/fstab
   37  sudo vgextend data /dev/sdc1
   38  sudo umount /dev/data/vdata
   39  sudo vgdisplay
   40  sudo lvextend -L+1.82T /dev/data/vdata
   41  sudo lvextend -l +100%FREE /dev/data/vdata
   42  sudo e2fsck -f /dev/data/vdata
   43  sudo resize2fs /dev/data/vdata
   44  sudo vgdisplay
   45  sudo mount /dev/data/vdata /data
   46  history
