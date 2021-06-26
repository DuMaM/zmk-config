#!/usr/bin/env python3

import pyudev
import pathlib
import subprocess

def devNode(device: pyudev.Device):
    print(device.device_node)
    print(device.device_path)
    
    if not device.parent:
        return
    else:
        devNode(device.parent)
    

def main():
    context = pyudev.Context()
    monitor = pyudev.Monitor.from_netlink(context)
    monitor.filter_by(subsystem='usb', device_type='usb_interface')
    monitor.start()

    while True:
        for device in iter(monitor.poll, None):
            if device.driver != "cdc_acm":
                break
            
            if device.action != "add":
                break
            
            # I can add more logic here, to run different scripts for different devices.
            devicePath = pathlib.Path(device.sys_path)
            if not (devicePath / 'tty').exists():
                break
            
            devicePaths = devicePath.rglob("ttyACM*")
            for ttyACM in devicePaths:
                cmd = ['picocom', '-b', '115200', '/dev/' + ttyACM.stem]
                print("Executed {}".format(" ".join(cmd)))
                return subprocess.run(cmd)

if __name__ == '__main__':
    main()

