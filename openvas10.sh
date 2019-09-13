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
make
make install

cd /tmp/gvm10/openvas-smb-1.0.5
mkdir build
cd build
cmake ..
make
make install

cd /tmp/gvm10/ospd-1.3.2
sudo python3 setup.py install

cd /tmp/gvm10/openvas-6.0.1/
mkdir build
cd build
cmake ..
make
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
make
make install

cd /tmp/gvm10/gsa-8.0.1
mkdir build
cd build
cmake ..
make
make install

gvm-manage-certs -a

echo "username for openvas10/gvm10 :"
read username

echo "password for openvas10/gvm10 :"
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


echo "Done."
echo "===========Up test==============="
echo "Please run: sudo systemctl status redis-server.service"
echo "Please run: ps aux | grep -E 'openvassd|gsad|gvmd' | grep -v grep"
echo "Check the port for GSA(the web interface) with the following command:"
echo "sudo netstat -lnp | grep gsad"
echo "===========Functionality test==============="
echo "Please go to https://localhost:443(the port might vary if it is already been used) and it will take you the openvas(gvm)'s web interface"
echo "Please create a task, pick a reachable target, and run the scan. When the scan is finished, download the report as xml(open it with any broswer) and download it as the pdf."

echo "==========gvm-cli(might not need it) and gvm-python==========="
echo "The installation only works if pip3 has the newer version"
echo "Please run: sudo apt install python3-pip"
echo "and 'pip3 install --upgrade pip' in a new terminal"
echo "Then, please run pip3 install --user gvm-tool in any terminal except the one you used to upgrade pip3"

echo "=========Unfinished===================="
rline="@reboot sleep 60 && bash /opt/bash/openvas10_start.sh"
(crontab -u root -l; echo "$rline" ) | crontab -u root -
echo "Raymond/I still need to add the bash file to the repo"