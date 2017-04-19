# greasedPig
Deployment of Kubernetes using the [IBM Spectrum Conductor for Containers](https://www.ibm.com/developerworks/community/wikis/home?lang=en#!/wiki/W1559b1be149d_43b0_881e_9783f38faaff)

![](architecture.png?raw=true)


## Purpose
The purpose of this project are:
1.  Automate the offline installation of CfC to 2 Virtual Machines (VMs): a Master and a Worker
2. Use CfC to install and manage products.

## Instructions To Build the Master and Worker VMs

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

Resources needed per VM:  
1.  100GB for base install and 200GB for data.  
2. 10240 MB for RAM (10GB)  
3. 4 VCPUs  


If you need to change them, look at the environment.sh file.

## WARNING
The **build-cfc.sh** script will delete the file **/root/.ssh/known_hosts**  
The **clean.sh** script will delete multiple directories as well.

***
#### TODO

### Adding the product to be installed

***

Run the script:

```
sudo ./build-cfc.sh
```

That will produce 3 KVM VMs.
1. The Master VM: ```ubuntu16.04.master```
2. The Worker VM: ```ubuntu16.04.worker```
3. The Clone VM: ```ubuntu16.04.clone```

The clone VM is use to test the CfC installer and will be deleted during the install process.

The Master and Worker VMs are the VMs that can be packaged and use to install on prem. All needed files are under the ```img``` directory.

## Moving VMs to their final destination  

When moving this VMs and xml files to a different host you might need to update the xml file to map to the new host. I moved one of my MVs from Ubuntu 16.04 to Redhat 7.3 and I had to update the following:   

1. Machine type
From:
```
<type arch='x86_64' machine='pc-i440fx-xenial'>hvm</type>
```
To:
```
<type arch='x86_64' machine='pc-i440fx-rhel7.0.0'>hvm</type>
```

2. Emulator type:
From:
```
<emulator>/usr/bin/kvm-spice</emulator>
```
To:
```
<emulator>/usr/libexec/qemu-kvm</emulator>
```

3. Disk location
From:
```
<source file='<your path>/build/img/ubuntu16.04.clone.qcow2'/>
```
To:
```
<source file='<your new path>/ubuntu16.04.clone.qcow2'/>
```
From:
```
<source file='<your path>/build/img/ubuntu16.04.clone.data.qcow2'/>
```
To:
```
<source file='<your new path>/ubuntu16.04.clone.data.qcow2'/>
```
3. Mac Address
From:
```
<mac address='5c:f3:fc:00:00:33'/>
```
To:
```
<mac address='<new mac address>'/>
```
4. Security driver
From:
```
<seclabel type='dynamic' model='apparmor' relabel='yes'>  
<label>libvirt-19f241e5-5b4b-4c5d-aa1a-a708d96b4fad</label>  
<imagelabel>libvirt-19f241e5-5b4b-4c5d-aa1a-a708d96b4fad</imagelabel>  
```
To:
```
<seclabel type='dynamic' model='selinux' relabel='yes'>  
<label>system_u:system_r:svirt_t:s0:c377,c521</label>  
<imagelabel>system_u:object_r:svirt_image_t:s0:c377,c521</imagelabel>  
</seclabel>  
<seclabel type='dynamic' model='dac' relabel='yes'>  
<label>+107:+107</label>  
<imagelabel>+107:+107</imagelabel>  
```

Once the VM has started make sure you update:
1. The hostname
```
hostname <my new hostname>

echo <my new hostname> > /etc/hostname
```
2. The /etc/hosts file to reflect the new IP configuration  

```
echo \"$1 ${clone_vm_name}\" >> /etc/hosts
```
***
# TODOs:
1. Secure the VMs
2. What to do about storage?
3. Find a way to automatically deploy products
***
