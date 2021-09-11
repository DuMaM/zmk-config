#!/usr/bin/env python3

import pyudev
import pathlib
import subprocess
    
def getDevPath(device: pyudev.Device):
    # I can add more logic here, to run different scripts for different devices.
    devicePath = pathlib.Path(device.sys_path)
    if not (devicePath / 'tty').exists():
        return ""
    
    devicePaths = devicePath.rglob("ttyACM*")
    for ttyACM in devicePaths:
        return '/dev/' + ttyACM.stem
    
    return ""

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
        
            devPath = getDevPath(device)
            cmd = ['picocom', '-b', '115200', devPath]
            print("Executed {}".format(" ".join(cmd)))
            return subprocess.run(cmd)


if __name__ == '__main__':
    main()

