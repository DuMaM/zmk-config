#!/bin/bash

export FLASH_IMG=$1
openocd -f interface/ftdi/jtag-lock-pick_tiny_2.cfg \
        -c "transport select swd" \
        -f target/nrf52.cfg \
        -c "init; reset; halt" \
        -c "nrf5 mass_erase" \
        -c "program $FLASH_IMG verify reset exit"
