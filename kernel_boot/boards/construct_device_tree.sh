#!/bin/bash

# Author: Robbe Gaeremynck

BOARD_NAME=$1
DEFAULT_DTS_FOLDER="${2:-./defaults}"
DTSI_FOLDER="${3:-$DEFAULT_DTS_FOLDER/include}"

usage () {
	echo "usage: $0 \$BOARD_NAME optional: custom dts folder optional: custom dtsi folder"
	exit 1
}

# Arguments short
if [ "$#" -lt 1 ]; then
    usage
    exit 1
fi

echo "---Compiling the device tree overlays---"
echo "---Compiling openwifi overlay---"
dtc -@ -I dts -O dtb -o openwifi_overlay.dtbo openwifi_overlay.dtso
echo "---Compiling openwifi $BOARD_NAME overlay---"
dtc -@ -I dts -O dtb -o ./$BOARD_NAME/$BOARD_NAME.dtbo ./overlays/$BOARD_NAME.dtso

# Check if fixed devicetree.dts present (if so, we should only compile overlays)
if [ -f "$BOARD_NAME/devicetree.dts" ]; then
  echo "There is a fixed device tree present for $BOARD_NAME, only compile overlays"
  exit 1
fi



declare -A openwifi_name_to_kernel_dts
openwifi_name_to_kernel_dts=(
  ["adrv9361z7035"]="zynq-adrv9361.dts"
  ["zed_fmcs2"]="zynq-zed.dts"
)
DEFAULT_DTS_FILENAME=${openwifi_name_to_kernel_dts[$BOARD_NAME]}

# Check if DTS exists in DTS folder
echo "$DEFAULT_DTS_FOLDER/$DEFAULT_DTS_FILENAME"
if [ ! -f "$DEFAULT_DTS_FOLDER/$DEFAULT_DTS_FILENAME" ]; then
  if [ "$#" -gt 1 ]; then # If file not found and non-defaults used, call yourself again, but this time with defaults
    sh ./construct_device_tree.sh $BOARD_NAME
    exit 1
  fi
  exit 1
fi

echo "---Generating the default (non-openwifi) device tree for $BOARD_NAME---"
cpp -nostdinc -x assembler-with-cpp -I$DTSI_FOLDER -o ./$BOARD_NAME/default_devicetree.dts $DEFAULT_DTS_FOLDER/$DEFAULT_DTS_FILENAME
dtc -@ -O dtb -o ./$BOARD_NAME/default_devicetree.dtb ./$BOARD_NAME/default_devicetree.dts

echo "---Applying openwifi overlays onto default device tree---"
fdtoverlay -i ./$BOARD_NAME/default_devicetree.dtb -o ./$BOARD_NAME/devicetree.dtb -v openwifi_overlay.dtbo ./$BOARD_NAME/$BOARD_NAME.dtbo
echo "---Decompiling the device tree (sanity check)---"
dtc -I dtb -O dts -o ./$BOARD_NAME/full_devicetree.dts ./$BOARD_NAME/devicetree.dtb