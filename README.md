# Sensato Appliance Deployment
Classified, and you should not know what this is.

## Pre-Requisites
* git (install by entering `sudo apt-get install git` in the terminal)
* a clean **Ubuntu 16.04 Server** 64-bit installation

## Installation
* Clone this repository: `git clone https://github.com/Sensato/Sentinel-Deploy.git` and `cd Sentinel-Deploy`

* Give the script read/write/etc permissions: `chmod 777 [device]-deployment.sh`
* Make the script executable: `chmod +x [device]-deployment.sh`
  * [device] being "sentinel" or "bda", case-sensitive.

* Run the script: `sudo ./[device]-deployment.sh`

* Follow all the prompts on the screen, then the build will start.
