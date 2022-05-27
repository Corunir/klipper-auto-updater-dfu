#!/bin/bash

#####################################################################################
# Klipper home directory. This is where your klipper installation is 
# Default is /home/pi/klipper
#####################################################################################
klipper_home_dir=/home/pi/klipper

#####################################################################################
# Menuconfig location
# Full path to the config file generated by menuconfig. Default is /home/pi/klipper/.config
#####################################################################################
config_path=/home/pi/klipper/config.mcu

#####################################################################################
# MCU serial
# This is the value from your printer.cfg without leading /dev/serial/by-id
# For example if your serial value is: 
#
# serial: /dev/serial/by-id/usb-Klipper_stm32f446xx_23002E00105053424E363620-if00
#
# you only use: 
#
# usb-Klipper_stm32f446xx_23002E00105053424E363620-if00
#
#####################################################################################
mcu_serial=usb-Klipper_stm32f446xx_23002E00105053424E363620-if00

if [ -z $klipper_home_dir ];
	then
		echo "Using default working directory /home/pi/klipper";
		pushd /home/pi/klipper;
	else
		echo "Using working directory "$klipper_home_dir;
		pushd $klipper_home_dir;
fi;

if [ -z $config_path ];
	then
		echo "Using default config file path /home/pi/klipper/.config";
		tmp_config_path=/home/pi/klipper/.config;
	else
		echo "Using config file "$config_path;
		tmp_config_path=$config_path;
fi;

if test -f "$tmp_config_path";
	then
		echo "Found config file "$tmp_config_path
	else
		echo "Config file not found, exiting...";
		return 1;
fi;

git pull

sudo service klipper stop

make clean KCONFIG_CONFIG=$config_path

make KCONFIG_CONFIG=$config_path

TTY=$(ls -l /dev/serial/by-id | grep $mcu_serial | grep -oP "ttyACM.*")

if [ -z $TTY ];
	then 
		echo "Could not find DFU device, check if your serial is correct by typing ls -l /dev/serial/by-id";
		return 1;
	else
		echo "Found mcu board on /dev/"$TTY;
fi;

make flash FLASH_DEVICE=/dev/$TTY
sudo service klipper start

popd