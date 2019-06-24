#!/bin/bash

# Variables
ENV="dev"
ORG="hunterdon"
MSSP="ctoc"

sudo apt-get install software-properties-common
sudo apt-add-repository universe
sudo apt-add-repository multiverse

sudo apt-get update

sudo apt-get install git curl python python-pip
pip install azure-cosmos

cd ~
git clone http://e19af9ef1bd6aa60122f00bd25b0766879a4d4eb@github.com/Sensato/packer-nids.git
cd packer-nids
git checkout appliance

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az extension add --name azure-cli-iot-ext

STR="Debug Message:\nBuilding Sentinel on environment $ENV, organization $ORG, msspid $MSSP."
python build_sensor.py env=$ENV orgid=$ORG msspid=$MSSP buildos=linux

sudo systemctl start sentinel_deploy.service
sudo systemctl enable sentinel_deploy.service
