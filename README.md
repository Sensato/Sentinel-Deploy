# Sentinel Appliance Deployment
Classified, and you should not know what this is.

## Pre-Requisites
* git
* [servicectl and serviced](https://github.com/smaknsk/servicectl)
	- Follow README on there, then edit both with `nano` 

## Installation with Cubic
* Clone this repository: `git clone [url].git` and `cd Sentinel-Deploy`
* Move the service file to systemd: `mv *.service /etc/systemd/system`
* Move the shell script to bin: `mv *.sh /usr/bin`
* Give the service read/write/etc permissions: `chmod 644 /etc/systemd/system/sentinel_deploy.service`
* Follow the servicectl/serviced README and install that.
* `cd` to /usr/local/bin and edit both `servicectl` and `serviced` with `nano`
	- Edit the first line of both to say `#!/bin/bash`
	- Look for `SYSTEMD_UNITS_PATH` in `servicectl` and edit after `=` to say `/etc/systemd/system`
* Finally, run this command to enable the service: `servicectl enable sentinel_deploy`

