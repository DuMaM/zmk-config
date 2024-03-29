#!/bin/bash
set -e

DEFAULT_REPO_PATH="../zmk/app"

SIDE=""
BOOTLOADER=true
FLASH=false
LOG=false
SETTINGS=false
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -l | --left)
        SIDE="left"
        export SHIELD_NAME="dactyl_manuform_$SIDE"
        shift # past arg
        ;;
    -r | --right)
        SIDE="right"
        export SHIELD_NAME="dactyl_manuform_$SIDE"
        shift # past arg
        ;;
    -n | --noboot)
        BOOTLOADER=false
        shift # past arg
        ;;
    -f | --flash)
        FLASH=true
        shift # past arg
        ;;
    -d | --debug)
        LOG=true
        shift # past arg
        ;;
    -s | --settings)
        export SHIELD_NAME="settings_reset_particle"
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

    if [ -n "$SHIELD_NAME" ]; then
        # clean up

        rm -rf build

        echo "Building $SHIELD_NAME"
        west build -p always -b particle_xenon -- -DSHIELD=$SHIELD_NAME -DZMK_CONFIG="$PWD/../../zmk-config/config"
    fi

    if $BOOTLOADER; then
        FLASH_IMG=$(find build/zephyr -name "$SHIELD_NAME*.hex")
        echo "Gen package for Adafruit bootloader from $FLASH_IMG"

        rm -rf dfu-package.zip
        adafruit-nrfutil dfu genpkg --dev-type 0x0052 --application "$FLASH_IMG" dfu-package.zip
    else
        FLASH_IMG=$(find build/zephyr -name "zmk*.elf")
    fi


    if $FLASH; then
        echo "Flashing $FLASH_IMG"

        if $BOOTLOADER; then
            latestDevice=$(ls /dev/ttyACM* -1tr | tail -n1)
            echo "Flashing device $latestDevice"
            adafruit-nrfutil dfu serial --package dfu-package.zip -p "$latestDevice" -b 115200
        else
            openocd -f interface/ftdi/jtag-lock-pick_tiny_2.cfg \
                    -c "transport select swd" \
                    -f target/nrf52.cfg \
                    -c "init; reset; halt" \
                    -c "nrf5 mass_erase" \
                    -c "program $FLASH_IMG verify reset exit"
        fi
    fi
)

(
    if $LOG; then
        ./log.py
    fi
)