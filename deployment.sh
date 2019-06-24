#!/bin/bash

# Variables
ENV="dev"
ORG="hunterdon"
MSSP="ctoc"

TOKEN="??"

sudo apt-get install software-properties-common
sudo apt-add-repository universe
sudo apt-add-repository multiverse

sudo apt-get update

sudo apt-get install git curl python 

curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
sudo python /tmp/get-pip.py
pip install --user pipenv
echo "PATH=$HOME/.local/bin:$PATH" >> ~/.profile
source ~/.profile

pip install azure-cosmos

cd ~
git clone http://$TOKEN:x-oauth-basic@github.com/Sensato/packer-nids.git
cd packer-nids
git checkout appliance

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az extension add --name azure-cli-iot-ext

STR="Debug Message: Building Sentinel on environment $ENV, organization $ORG, msspid $MSSP."
echo $STR
python build_sensor.py env=$ENV orgid=$ORG msspid=$MSSP buildos=linux
