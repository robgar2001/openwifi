<!--
Author: Robbe Gaeremynck
SPDX-FileCopyrightText: 2019 UGent
SPDX-License-Identifier: AGPL-3.0-or-later
-->
✅
❌
⚠️

# Using openwifi with OpenWrt
| Board | Tested | Comments |
|-------|--------|----------|
| zc706_fmcs2 |  | |
| zed_fmcs2 | | |
| adrv9364z7020 | | |
| adrv9361z7035 |  | |
| zc702_fmcs2 | | |
| antsdr | | |
| e310v2 | | |
| antsdr_e200 | | |
| sdrpi | | |
| zcu102_fmcs2 |  | Fails on some boards, see [here](../../known_issue/notter.md#no-uart-output-on-zcu102). |
| neptunesdr | | |

# Creating an OpenWrt image with openwifi installed for a supported board
The instructions are given as if you were to build everything in this directory.

## Cloning the OpenWrt source code
The OpenWrt v24.10 (Linux kernel v6.6, mac80211 v6.12) source with openwifi support is found [here](https://github.com/open-sdr/openwrt-openwifi).
```
git clone https://github.com/open-sdr/openwrt-openwifi.git
```

## Building the container
Instructions on how to set up this container are found [here](https://openwrt.org/docs/guide-user/virtualization/obtain.firmware.docker).

```
docker build --rm --tag openwrt:debian_12 --file ./Dockerfile ./openwrt
```

## Starting the container
```
./start_docker_openwrt_build.sh
```

## Update package feeds
Running this command will retrieve the openwrt-openwifi-packages-feed found [here](https://github.com/open-sdr/openwrt-openwifi-packages-feed).
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
- Openwifi kernel module under:
    - Kernel Modules -> Wireless Drivers -> openwifi (compilation of user space tools is optional). Note that selecting openwifi will by default also select LuCi (OpenWrt its web interface). 
- Other packages you may want to use with openwifi/OpenWrt. Recommendations:
    - Network -> SSH -> openssh-sftp-server (Allows use of scp command to board)

Save config.

## Build
```
make -j$(PKG_JOBS) V=sc
```
We recommend to keep the number of jobs low (~3) works fine.
Increasing number of jobs decreases build time put risks error due to dependencies.
If it throws an error, try to resume the build with fewer jobs.

## Usage example: Create openwifi AP via LuCi
This is the equivalent of the ./fosdem.sh demo used for kuiper but via OpenWrt its web interface LuCi. 

The board should automatically boot with IP address assignment via DHCP. Hence, you can plug it into your home network and surf to the following url:
```
http://openwrt.lan
```
It can be that openwrt.lan should be replaced by its actual IP address.

In case this would fail or you prefer to set a static IP, you can connect via UART and change the network config under */etc/config/network*. Changes are applied after */etc/init.d/network restart*.

The following webpage should appear (first login, by default there is no password set, I advice to change this for use in actual deployment):





# Tips 

## SSH to the board
The board automatically starts with IP assignment via DHCP.
```
ssh root@openwrt.lan
```
(No password required)

## Debugging
Easiest way to debug using this workflow is to mount extra volumes into the container on start. For example, to debug openwifi package add to start_docker_openwrt_build.sh command:
```
--volume "$(pwd)/openwifi:/openwifi" \
```
Edit the openwifi packages to use the locally provided source at /openwifi.\
Tip: You can mount --bind the openwrt source under /workdir, making it possible to copy and paste paths shown in the docker container.

# Known issues
There are some known issues that are OpenWrt specific, these can be consulted [here](../../known_issue/notter.md#known-issues-specific-to-openwrt).