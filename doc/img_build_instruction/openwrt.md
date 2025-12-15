<!--
Author: Robbe Gaeremynck
SPDX-FileCopyrightText: 2019 UGent
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Using openwifi with OpenWrt
To build OpenWrt and use it with openwifi, we strongly recommend to use a Docker container.

## Building the container
Instructions on how to set up this container are found [here](https://openwrt.org/docs/guide-user/virtualization/obtain.firmware.docker).
The Dockerfile is provided in this directory.

## Starting the container
```
docker run --interactive --rm --tty --ulimit 'nofile=1024:262144' \
--volume "$(pwd)/openwrt:/workdir" \
--workdir '/workdir' openwrt:debian_12 /bin/bash
<hostname>:/workdir$
```

## Update package feeds
```
./scripts/feeds update
./scripts/feeds install -a
```

## Configure build
```
make menuconfig
```
Select:
- Architecture (zynq or zynqmp)
- Board
- Openwifi kernel module under: Kernel Modules -> Wireless Drivers -> openwifi (compilation of user space tools is optional).
- Other packages you may want to use with openwifi/OpenWrt.

## Build
```
make -j$(PKG_JOBS) V=sc
```
We recommend to keep the number of jobs low (~3) works fine.
Increasing number of jobs decreases build time put risks error due to dependencies.
If it throws an error, try to restart the build with fewer jobs.

### Debugging
Easiest way to debug using this workflow is to mount extra volumes into the container. For example, to debug openwifi package add:
```
--volume "$(pwd)/openwifi:/openwifi" \
```
Edit the openwifi packages to use the locally provided source at /openwifi. \
Tip: You can mount the openwrt source under /workdir, making it possible to copy and paste paths shown in the docker container.