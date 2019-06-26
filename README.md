# Sentinel Appliance Deployment
Classified, and you should not know what this is.

## Pre-Requisites
* git
* a clean Ubuntu 18.04 64-bit installation

## Installation
* Clone this repository: `git clone [url].git` and `cd Sentinel-Deploy`
* Move the shell script to bin: `mv *.sh /usr/bin`
* Give the script read/write/etc permissions: `chmod 777 /usr/bin/deployment.sh`
* Edit `/etc/rc.local` to say this:
```
#!/bin/bash
/usr/bin/deployment.sh || exit 1
exit 0
```
* Give rc.local permissions: `sudo chown root /etc/rc.local` and `sudo chmod 777 /etc/rc.local`

## Distribution
* Simply create a backup image of the current installation.
* `dd if=/dev/sda | gzip > ~/[org]-sentinel.img.gz`
	- Naturally, this will take a very long time to create the system image.
