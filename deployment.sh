#!/bin/bash

# Variables
ENV="dev"
ORG="hunterdon"
MSSP="ctoc"

TOKEN="2667c45e1b18ea74766daccd7bfa9bf4e0914c41"

sudo apt install software-properties-common
sudo apt-add-repository universe
sudo apt-add-repository multiverse

sudo apt update

sudo apt install curl
sudo apt install python 
sudo apt install python-pip

pip install azure-cosmos

cd ~
git clone http://csharpe101:$TOKEN@github.com/Sensato/packer-nids.git
cd packer-nids
git checkout appliance

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az extension add --name azure-cli-iot-ext

STR="Debug Message: Building Sentinel on environment $ENV, organization $ORG, msspid $MSSP."
echo $STR
python build_sensor.py env=$ENV orgid=$ORG msspid=$MSSP buildos=linux
