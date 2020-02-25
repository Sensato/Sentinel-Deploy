#!bin/bash
#For Openvas10/GVM10
#-----------Dependencies installation-----------
apt update
apt -y upgrade
apt -y install bison cmake gcc gcc-mingw-w64 heimdal-dev libgcrypt20-dev libglib2.0-dev libgnutls28-dev libgpgme11-dev libhiredis-dev libksba-dev libmicrohttpd-dev libpcap-dev libpopt-dev libsnmp-dev libsqlite3-dev libssh-gcrypt-dev xmltoman libxml2-dev perl-base pkg-config python3-paramiko python3-setuptools uuid-dev curl redis-server doxygen libical-dev python-polib gnutls-bin apt-transport-https freeradius libradcli-dev libldap-dev clang-format xsltproc 
apt -y install texlive-latex-extra --no-install-recommends
apt -y install texlive-fonts-recommended
#install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt update 
apt -y install yarn

#install nodejs12
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt-get install -y nodejs

#--------------installation-------------------------------
#make temp folder
mkdir /tmp/gvm10
cd /tmp/gvm10

#download repo zip files and unzip them all
wget https://github.com/greenbone/gvm-libs/archive/v10.0.1.tar.gz -O gvm-libs-v10.0.1.tar.gz
wget https://github.com/greenbone/openvas/archive/v6.0.1.tar.gz -O openvas-scanner-v6.0.1.tar.gz 
wget https://github.com/greenbone/gvmd/archive/v8.0.1.tar.gz -O gvm-v8.0.1.tar.gz
wget https://github.com/greenbone/gsa/archive/v8.0.1.tar.gz -O gsa-v8.0.1.tar.gz
wget https://github.com/greenbone/ospd/archive/v1.3.2.tar.gz -O ospd-v1.3.2.tar.gz
wget https://github.com/greenbone/openvas-smb/archive/v1.0.5.tar.gz -O openvas-smp-v1.0.5.tar.gz
for i in *.tar.gz; do tar xzf $i; done

#---------------Greenbone Vulnerability Management 10(Source Edition) installation--------------
cd gvm-libs-10.0.1/
mkdir build
cd build/
cmake ..
make -j`nproc`
make install

cd /tmp/gvm10/openvas-smb-1.0.5
mkdir build
cd build
cmake ..
make -j`nproc`
make install

cd /tmp/gvm10/ospd-1.3.2
sudo python3 setup.py install

cd /tmp/gvm10/openvas-6.0.1/
mkdir build
cd build
cmake ..
make -j`nproc`
sudo make install

#----------------Reconfig redis-server----------------
echo "net.core.somaxconn = 1024"  >> /etc/sysctl.conf
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf

sudo touch /etc/systemd/system/disable_thp.service
sudo tee -a /etc/systemd/system/disable_thp.service > /dev/null <<EOT
[Unit]
Description=Disable Transparent Huge Pages (THP)
[Service]
Type=simple
ExecStart=/bin/sh -c "echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled && echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag"
[Install]
WantedBy=multi-user.target
EOT

#backup the redis configuration file
cp /etc/redis/redis.conf /etc/redis/redis.orig

#uncomment unixsocket setting and change port to 0 in the redis.conf file
#sed: stream editor for filtering and transforming text, -i : in-place
#s|A|B|g means repalce A with B
sed -i 's|# unixsocket /var/run/redis/redis.sock|unixsocket /var/run/redis/redis-server.sock|g' /etc/redis/redis.conf
sed -i 's|# unixsocketperm 700|unixsocketperm 700|g' /etc/redis/redis.conf
sed -i 's|port 6379|port 0|g' /etc/redis/redis.conf

systemctl daemon-reload
systemctl start disable_thp
systemctl enable disable_thp
systemctl restart redis-server

echo "db_address = /var/run/redis/redis-server.sock" >> /usr/local/etc/openvas/openvassd.conf
sudo greenbone-nvt-sync
sudo ldconfig

#------------------------Gvmd and Gsa----------------------------------------

cd /tmp/gvm10/gvmd-8.0.1/
mkdir build
cd build
cmake ..
make -j`nproc`
make install

cd /tmp/gvm10/gsa-8.0.1
mkdir build
cd build
cmake ..
make -j`nproc`
make install

gvm-manage-certs -a

echo "username for openvas10/gvm10:"
read username

echo "password for openvas10/gvm10:"
read password

gvmd --create-user $username --role=Admin --password=$password

sudo openvassd 
sudo gvmd 
sudo gsad

echo "===========this one might takes a while============="
greenbone-scapdata-sync 
greenbone-certdata-sync

#----cronjob for auto-update vulnerabilites news feed(minutes hour * * *)---------
0 1 * * * /usr/sbin/greenbone-nvt-sync > /dev/null
5 0 * * * /usr/sbin/greenbone-scapdata-sync > /dev/null
5 1 * * * /usr/sbin/greenbone-certdata-sync > /dev/null

rline="@reboot sleep 60 && bash /opt/nightingale-nids/bash/openvas10_start.sh"
(crontab -u root -l; echo "$rline" ) | crontab -u root -

Red='\033[0;31m'
Green='\033[0;32m'
White='\033[0;37m'
Yellow='\033[0;33m'

echo "Done."
echo "================================="
echo "================================="
echo "===========Up test==============="
echo -e "Please run: ${Green}sudo systemctl status redis-server.service"
echo -e "${White}Please run: ${Green}ps aux | grep -E 'openvassd|gsad|gvmd' | grep -v grep"
echo -e "${White}Please looking for gsad, openvassd, and gvmd"
echo "Making sure gvmd and oepnvassd are ${Green}Waiting for incoming connection."
echo -e "${White}gvmd should be configuring nvt(the lates vulernablity feeds) in the meanttime."
echo "Check the port which GSA(the web interface, gsad) is listening with the following(below)command:"
echo -e "${Green}sudo netstat -lnp | grep gsad"
echo -e "${White}It will be the number after :::"
echo "===========Functionality test==============="
echo -e "Please go to ${Yellow}https://localhost:9392${White}, the port might vary if it is already been used, use the port number above if it is other than 9392)," 
echo "and it will take you the openvas(gvm) web interface."
echo "Please create a task, pick a reachable target, and run the scan. When the scan is finished, please check if a report is generated and download it as xml. You may try it with any broswer." 
echo "Download the report as the pdf. "
echo -e "Please run ${Green}sudo apt install nmap${White} if the report result suggests that you are missing a nmap scanner."
echo "==========gvm-cli and gvm-python==========="
echo "The installation only works if pip3 has the newer version"
echo -e "Please open a new terminal with ${Yellow}CTRL+ALT+T${White}, ${Green} sudo su${White} to the root user,then run: ${Green}apt install python3-pip${White} to install pip3,"
echo -e "and ${Green}pip3 install --upgrade pip${White} to upgrade pip3"
echo -e "Then, please open another new terminal, run ${Green}sudo su${White} and ${Green}pip3 install --user gvm-tools${White} and ${Green}pip3 install --user psycopg2"
echo -e "${White}============Check if openvassd/gvmd/gsad will run after one minute after a start-up."
echo -e "Please Run${Green} sudo crontab -e ${White}to check if ${Yellow}@reboot sleep 60 && bash /opt/nightingale-nids/bash/openvas10_start.sh${White} is added."
echo -e "After a restart up, please wait for one minute then run ${Green}ps aux | grep -E 'openvassd|gsad|gvmd' | grep -v grep ${White} to make sure openvas is running"
echo "==========Partial functionality test for xml/python==================="
echo -e "Please run ${Yellow}openvas10test.py ${White}with ${Green}sudo python3 openvas10test.py <replace username here> <replace password here>"
echo -e "${White}It will automatically create a target, use the target jsut created for a task, and start the task."
echo "Replace report_id in the script with report id shown on the terminal and please run the python script again to see if there xml can be converted to json properly"
echo -e "${Red}IMPORTANT! Please remove the openvas10test.py after the testing!!"
