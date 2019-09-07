#!/usr/bin/env bash


cd /opt
wget -U ossec https://bintray.com/artifact/download/ossec/ossec-hids/ossec-hids-2.8.3.tar.gz
tar -zxvf ossec-hids-*.tar.gz
cd /home/sensat0/
git clone https://github.com/dennysabu/OSSECAgent.git
cd OSSECAgent
cp preloaded-vars.conf /opt/ossec-*/etc
cd /opt/ossec*/
./install.sh

