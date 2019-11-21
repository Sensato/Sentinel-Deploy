#!/bin/bash
echo "================================="
echo "Device Initial Configuration v2.1"
echo "================================="
echo ""
# Select Environment and set value to variable
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

# Select ORG and set value to variable
# WARNING: No validation of entered ORG. Removed defined array to support scalability
echo ""
echo "Enter desired ORG:"
		read orgInput
		ORG="$orgInput"
		echo "Organization is $ORG"

# Select MSSP and set value to variable
# WARNING: No validation of entered MSSP. Removed defined array to support scalability
echo ""
echo "Enter desired MSSP [Managed Security Service Provider]:"
		read msspInput
		MSSP="$msspInput"
		echo "Managed Security Service Provider is $MSSP"

echo "Enter github username:"
read userInput
USER="$userInput"
echo "Github username is $USER"

echo "Enter github token:"
read tokenInput
TOKEN="$tokenInput"
echo "Github token is $TOKEN"

echo "Starting build..."

sudo apt install software-properties-common -y
sudo apt-add-repository universe
sudo apt-add-repository multiverse

sudo apt update -y

sudo apt install curl python python-pip -y
pip install azure-cosmos

cd ~
git clone http://$USER:$TOKEN@github.com/Sensato/packer-nids.git
cd packer-nids
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

STR="Debug Message: Building Sentinel on environment $ENV, organization $ORG, msspid $MSSP."
echo $STR
sudo mkdir -p ~/.debug
sudo python build_sensor.py env=$ENV orgid=$ORG msspid=$MSSP buildos=linux

# Run the following command instead of the previous command to write build output to a file at ~/.debug
# sudo python build_sensor.py env=$ENV orgid=$ORG msspid=$MSSP buildos=linux > ~/.debug/packer-nids.debug-$(date +"%s").log 2>&1
