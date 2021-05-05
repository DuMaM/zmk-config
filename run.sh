#!/bin/bash
set -e

(
    cd "./../zmk/app" || return

    while [[ $# -ge 0 ]]
    do
    key="$1"
    case $key in
        -l|--left)
        echo "building left"
        west build -p always -b particle_xenon -- -DSHIELD=dactyl_manuform_left -DZMK_CONFIG="$PWD/../../zmk-config/config"
        shift
        ;;

        -r|--right)
        echo "building right"
        west build -p always -b particle_xenon -- -DSHIELD=dactyl_manuform_right -DZMK_CONFIG="$PWD/../../zmk-config/config"
        shift
        ;;

        *)
        # unknown option
        echo "Please define proper board site"
        exit 1
        ;;
    esac
    done

    ### install over usb
    rm -rf dfu-package.zip
    adafruit-nrfutil dfu genpkg --dev-type 0x0052 --application build/zephyr/dactyl_manuform*.hex dfu-package.zip
    adafruit-nrfutil dfu serial --package dfu-package.zip -p /dev/ttyACM* -b 115200
)