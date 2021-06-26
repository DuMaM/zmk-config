#!/bin/bash
set -e

DEFAULT_REPO_PATH="../zmk/app"

LEFT=false
RIGHT=false

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -l | --left)
        LEFT=true
        shift # past arg
        ;;
    -r | --right)
        RIGHT=true
        shift # past arg
        ;;
    *)                     # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift              # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

(
    cd $DEFAULT_REPO_PATH
    rm -rf dfu-package.zip build

    if $LEFT; then
        echo "building left"
        west build -p always -b particle_xenon -- -DSHIELD=dactyl_manuform_left -DZMK_CONFIG="$PWD/../../zmk-config/config"
    elif $RIGHT; then
        echo "building right"
        west build -p always -b particle_xenon -- -DSHIELD=dactyl_manuform_right -DZMK_CONFIG="$PWD/../../zmk-config/config"
    else
        echo "Please define proper board site"
        exit 1
    fi

    latestDevice=$(ls /dev/ttyACM* -1tr | tail -n1)
    rm -rf dfu-package.zip
    adafruit-nrfutil dfu genpkg --dev-type 0x0052 --application build/zephyr/*.hex dfu-package.zip
    adafruit-nrfutil dfu serial --package dfu-package.zip -p "$latestDevice" -b 115200
)
