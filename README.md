# Sentinel Appliance Deployment
Classified, and you should not know what this is.

## Pre-Requisites
* git
* python

## Installation
* Clone this repository: `git clone [url].git` and `cd Sentinel-Deploy`
* Move the service file to systemd: `mv *.service /etc/systemd/system`
* Move the shell script to bin: `mv *.sh /usr/bin`
* Give the service read/write/etc permissions: `chmod 644 /etc/systemd/system/sentinel_deploy.service`
* Enable the service at boot: `systemctl enable sentinel_deploy`

## Distribution
* Simply create a backup image of the current installation.
* `dd if=/dev/sda of=~/[org]-sentinel.iso`
