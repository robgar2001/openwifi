#!/bin/bash

echo "---Generating the default board device tree---"
cpp -nostdinc -x assembler-with-cpp -I./include -o devicetree.tmp zynq-adrv9361.dts
dtc -@ -O dtb -o devicetree.dtb devicetree.tmp

# echo "Compiling the openwifi dts for sake of comparing"
# dtc -O dtb -I dts -o openwifi.dtb devicetree.dts

echo "---Compiling the device tree overlays---"
echo "---Compiling openwifi overlay---"
dtc -@ -I dts -O dtb -o openwifi_overlay.dtbo openwifi_overlay.dtso
echo "---Compiling adrv9361 overlay---"
dtc -@ -I dts -O dtb -o adrv9361z7035.dtbo adrv9361z7035.dtso

echo "---Applying the overlays---"
fdtoverlay -i devicetree.dtb -o openwifi.dtb -v openwifi_overlay.dtbo adrv9361z7035.dtbo
echo "---Decompiling the openwifi dtb---"
dtc -I dtb -O dts -o openwifi.dts openwifi.dtb