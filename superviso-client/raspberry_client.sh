#!/bin/bash

#This can be installed as simple as this curl  -s https://dl.dropboxusercontent.com/u/23991595/rasp-collector/raspberry_client.sh | sh


    SUPERVISO_CLIENT_URL="https://www.dropbox.com/s/5e41ajnoduculdx/superviso_client"

    echo "This script requires superuser access to install software."
    echo "Please ejecute as user root or you will be prompted for your password by sudo."

    # clear any previous sudo permission
    sudo -k

    # run inside sudo
    sudo sh <<SCRIPT

    # download and extract the client tarball
    rm -rf /etc/superviso/
    mkdir -p /etc/superviso/bin/
    cd /etc/superviso/
  
    # Get raspberry client
    wget $SUPERVISO_CLIENT_URL 

    echo " Adding Superviso-client to cron."
  
    #Add to cron
################   cat  <(crontab -l)  <(echo "*/5 * * * * /etc/superviso/bin/superviso_client") | crontab - 
    crontab -l > /tmp/crontab.current
    echo "*/5 * * * * /etc/superviso/bin/superviso_client" >> /tmp/crontab.current
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


