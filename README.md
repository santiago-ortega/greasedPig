# greasedPig
Deployment of Kubernetes using the [IBM Spectrum Conductor for Containers](https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/W1559b1be149d_43b0_881e_9783f38faaff)

![alt text][https://github.com/santiago-ortega/greasedPig/architecture.png]


## Purpose
The purpose of this project are:
1.  Automate the offline installation of CfC to 2 Virtual Machines (VMs): a Master and a Worker
2. Use CfC to install and manage products.

## Instructions

Uses the ubuntu 16.04 server image from (http://releases.ubuntu.com/16.04/).

* ubuntu-16.04-server-amd64.iso

It should be palce under the ```vms``` directory.

To create the VMs you need a ubuntu 16.04 server with the following packages:

* ```expect```
* ```qemu-kvm```
* ```libvirt-bin```
* ```openssh-server```

You need to be able to resolve using dhcp the following ip/mac address convinations:

* ```master_ip=10.10.0.31```
* ```master_mac_addr=5c:f3:fc:00:00:00```

* ```worker_ip=10.10.0.32```
* ```worker_mac_addr=5c:f3:fc:00:00:11```

* ```clone_ip=10.10.0.33```
* ```clone_mac_addr=5c:f3:fc:00:00:33```

If you need to change them, look at the environment.sh file.

## WARNING
The **build-cfc.sh** script will delete the file **/root/.ssh/known_hosts**  
The **clean.sh** script will delete multiple directories as well.

Run the script:

```
sudo ./build-cfc.sh
```

That will produce 3 KVM VMs.
1. The Master VM: ```ubuntu16.04.master```
2. The Worker VM: ```ubuntu16.04.worker```
3. The Clone VM: ```ubuntu16.04.clone```

The clone VM is use to test the CfC installer.
The Master and Worker VMs are the VMs that can be packaged and use to install on prem.

TODOs:
1. Secure the VMs
2. What to do about storage?
3. Find a way to automatically deploy products
