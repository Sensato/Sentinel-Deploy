#!/bin/bash

# BDA APPLIANCE DEPLOYMENT SCRIPT
echo "Select environment: (prod/dev)"
read envInput
	if [ $envInput == "prod" ] || [ $envInput == "dev" ];
	then	
		ENV="$envInput"
		echo "Environment is $ENV"
	else
		echo "Not a valid environment. Exiting..."
		exit 0
	fi


echo "Select organization: (acme/beebe/centrastate/ctoc/hunterdon/maimonides/sensato/westchester)"
read orgInput
	if [ $orgInput == "acme" ] || [ $orgInput == "beebe" ] || [ $orgInput == "centrastate" ] || [ $orgInput == "ctoc" ] || [ $orgInput == "hunterdon" ] || [ $orgInput == "maimonides" ] || [ $orgInput == "sensato" ] || [ $orgInput == "westchester" ];
	then	
		ORG="$orgInput"
		echo "Organization is $ORG"
	else
		echo "Not a valid organization. Exiting..."
		exit 0
	fi



echo "Select managed security service provider: acme/beebe/centrastate/ctoc/hunterdon/maimonides/sensato/westchester"
read msspInput
	if [ $orgInput == "acme" ] || [ $orgInput == "beebe" ] || [ $orgInput == "centrastate" ] || [ $orgInput == "ctoc" ] || [ $orgInput == "hunterdon" ] || [ $orgInput == "maimonides" ] || [ $orgInput == "sensato" ] || [ $orgInput == "westchester" ];
	then	
		MSSP="$msspInput"
		echo "Managed security service provider is $MSSP"
	else
		echo "Not a valid managed security service provider. Exiting..."
		exit 0
	fi



echo "Enter github username:"
read userInput
USER="$userInput"
echo "Github username is $USER"


echo "Enter github token:"
read tokenInput
TOKEN="$tokenInput"
echo "Github token is $TOKEN"


echo "Starting build..."

# Variables
# This is where a Sensato employee will change these varibles per organization
# ENV="dev"
# ORG="ctoc"
# MSSP="ctoc"

# User access token generated by Brett Warrick (aka Renevant)
# TOKEN="c02f32574b7bbb6d3ff626cde0328aebedb6ca70"

sudo apt install software-properties-common -y
sudo apt-add-repository universe
sudo apt-add-repository multiverse

sudo apt update -y

sudo apt install curl python python-pip -y
pip install azure-cosmos

cd ~
git clone http://$USER:$TOKEN@github.com/Sensato/packer-bda.git
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
sudo python build_bda.py env=$ENV orgid=$ORG msspid=$MSSP buildos=linux

# Run the following command instead of the previous command to write build output to a file at ~/.debug
# sudo python build_bda.py env=$ENV orgid=$ORG msspid=$MSSP buildos=linux > ~/.debug/packer-bda.debug-$(date +"%s").log 2>&1

# Self Destruct
# rm -rf ~/packer-bda
# rm -rf ~/Sentinel-Deploy
# sudo echo "exit 0" > /etc/rc.local # specific to BDA deployment, rc.local doesn't overwrite otherwise
# sudo reboot
