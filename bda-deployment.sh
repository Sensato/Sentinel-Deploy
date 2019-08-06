#!/bin/bash

# BDA APPLIANCE DEPLOYMENT SCRIPT

# Variables
# This is where a Sensato employee will change these varibles per organization
ENV="dev"
ORG="ctoc"
MSSP="ctoc"

# User access token generated by Chloe Sharpe
TOKEN="2667c45e1b18ea74766daccd7bfa9bf4e0914c41"

sudo apt install software-properties-common -y
sudo apt-add-repository universe
sudo apt-add-repository multiverse

sudo apt update -y

sudo apt install curl python python-pip -y
pip install azure-cosmos

cd ~
git clone http://csharpe101:$TOKEN@github.com/Sensato/packer-bda.git
cd packer-bda
git checkout appliance

# Install Azure CLI
sudo apt install apt-transport-https lsb-release gnupg -y
curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt update -y
sudo apt install azure-cli -y

az extension add --name azure-cli-iot-ext

STR="Debug Message: Building BDA on environment $ENV, organization $ORG, msspid $MSSP."
echo $STR
sudo mkdir -p ~/.debug
sudo python build_bda.py env=$ENV orgid=$ORG msspid=$MSSP buildos=linux > ~/.debug/packer-bda.debug-$(date +"%s").log 2>&1

# Self Destruct
# rm -rf ~/packer-bda
# sudo echo "exit 0" > /etc/rc.local # specific to BDA deployment, rc.local doesn't overwrite otherwise
# sudo reboot
