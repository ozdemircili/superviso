#!/bin/bash

#This can be installed as simple as this curl  -s https://dl.dropboxusercontent.com/u/23991595/rasp-collector/raspberry_client.sh | sh

{
    SUPERVISO_CLIENT_URL="http://dl.dropboxusercontent.com/u/23991595/rasp-collector/raspberry_collector.py"
    PYLINUX_CLIENT_URL="http://dl.dropboxusercontent.com/u/23991595/rasp-collector/pylinux.tar.gz"

    echo "This script requires superuser access to install software."
    echo "Please ejecute as user root or you will be prompted for your password by sudo."

    # clear any previous sudo permission
    sudo -k

    # run inside sudo
    sudo sh <<SCRIPT

    # download and extract the client tarball
    rm -rf /etc/superviso/
    mkdir -p /etc/superviso/data
    cd /etc/superviso/
  
    # Get raspberry client
    wget $SUPERVISO_CLIENT_URL 

    echo " Installing pylinux"
   
    wget $PYLINUX_CLIENT_URL
    tar -zxvf pylinux.tar.gz
    cd pylinux
    python setup.py install
     
    echo "Dependencies Installed"
    
    #Cleanup 
    rm -fr  /etc/superviso/pylinux*
   

    #Add to cron
################   cat  <(crontab -l)  <(echo "*/5 * * * * /usr/bin/python /etc/superviso/raspberry_collector.py") | crontab - 
    crontab -l > /tmp/crontab.current
    echo "*/5 * * * * /usr/bin/python /etc/superviso/raspberry_collector.py" >> /tmp/crontab.current
    crontab /tmp/crontab.current
    tput clear
    echo "Added raspberry client to cron"
    

 
    #Add some fancy progress bars
    echo -ne '#####                     (33%)\r'
	sleep 1
    echo -ne '#############             (66%)\r'
	sleep 1
   echo -ne '#######################   (100%)\r'
	echo -ne '\n'
    echo "Congratulations... Installation complete!"


