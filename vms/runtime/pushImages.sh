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


docker login master.cfc:8500 -u admin -p admin

for m in `docker images -f 'reference=zmanaged*' | awk '{print $1":"$2}'`;
do
  echo $m
  docker tag $m master.cfc:8500/admin/$m
  docker push master.cfc:8500/admin/$m
done

docker tag registry.ng.bluemix.net/zoi_dev/ibm-spark:1.6.3.0 \
           master.cfc:8500/admin/registry.ng.bluemix.net/zoi_dev/ibm-spark:1.6.3.0
docker push master.cfc:8500/admin/registry.ng.bluemix.net/zoi_dev/ibm-spark:1.6.3.0
