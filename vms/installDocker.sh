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

addDocker2Repo (){
echo "Update apt-get"
apt-get update
apt-get install -y software-properties-common python-software-properties acpid

echo "Add docker key to repository"
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "Add repository url to repository"
apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'

echo "Update apt-get"
apt-get update
}

verifyRepo (){
echo "Install docker from the docker repo"
apt-cache policy docker-engine | grep "Installed: (none)"

if [ $? -eq 0 ]
then
	echo "Correct repot"
else
	exit 1
fi

apt-cache policy docker-engine | grep "Candidate:" | grep "xenial"
if [ $? -eq 0 ]
then
        echo "Correct repot"
else
        exit 1
fi

apt-cache policy docker-engine | grep "dockerproject.org"
if [ $? -eq 0 ]
then
        echo "Correct repot"
else
        exit 1
fi
}

#if [ "$1x" == "x" ]
#then
#	echo "Docker needs the repository address."
#	exit 1
#fi

addDocker2Repo

verifyRepo

apt-get install -y docker-engine

systemctl status docker | grep active
if [ $? -eq 0 ]
then
        echo "Docker is running"
else
        exit 1
fi

usermod -aG docker $(whoami)

#Give access to docker apis and $1 registry
#Where $1 is the ip address of the master
#DOCKER_CONF=$(systemctl cat docker | head -1 | awk '{print $2}')
#sed -i "s_ExecStart=/usr/bin/dockerd -H fd://_ExecStart=/usr/bin/dockerd -H fd:// -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375 --insecure-registry $1:5000_" ${DOCKER_CONF}
#systemctl daemon-reload
#systemctl restart docker
