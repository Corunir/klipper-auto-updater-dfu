#!/bin/bash

###################################################
#default values
##################################################
klipper_home_dir=/home/pi/klipper
config_path=/home/pi/klipper/config.mcu
mcu_serial=

validate_file(){
    case $1 in
      -d)
	[ -d $3 ] && echo "Found $2 at $3" || { echo "$2 not found at $3, exiting..."; exit 1; }
	;;
      -f)
	[ -f $3 ] && echo "Found $2 at $3" || { echo "$2 not found at $3, exiting..."; exit 1; }
	;;
      -s)
	[ -z $3 ] && { echo "Providing a serial number is mandatory either through mcu_serial config param or through -ms|--mcu-serial arugment"; exit 1; }
	TTY=$(ls -l /dev/serial/by-id | grep $3 | grep -oP "ttyACM.*")
	[ -z $TTY ] && { echo "MCU with serial $3 cannot be found, exiting..."; exit 1; } || echo "MCU with serial $3 found"
    esac;
}

POSITIONAL_ARGS=()

parse_args(){
while [[ $# -gt 0 ]]; do
  case $1 in
    -khd|--klipper-home-dir)
      klipper_home_dir="$2"
      shift # past argument
      shift # past value
      ;;
    -mco|--menu-config-output)
      config_path="$2"
      shift # past argument
      shift # past value
      ;;
    -ms|--mcu-serial)
      mcu_serial="$2"
      shift # past argument
      shift #past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done
}

update_klipper_and_flash(){

  pushd $klipper_home_dir

  git pull

  sudo service klipper stop

  make clean KCONFIG_CONFIG=$config_path

  make KCONFIG_CONFIG=$config_path
  make flash FLASH_DEVICE=/dev/$TTY
  sudo service klipper start

  popd
}

parse_args $*
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

validate_file -d "Klipper home directory" ${klipper_home_dir}
validate_file -f "Menuconfig output file" ${config_path}
validate_file -s "MCU" ${mcu_serial}

echo "KLIPPER HOME DIRECTORY  = ${klipper_home_dir}"
echo "MENUCONFIG OUTPUT FILE  = ${config_path}"
echo "MCU SERIAL              = ${mcu_serial}"

update_klipper_and_flash
