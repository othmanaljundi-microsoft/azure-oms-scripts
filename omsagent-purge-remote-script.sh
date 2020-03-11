#!/bin/bash

	# First Parameter is Workspace ID
	# Second Parameter is Primary Key
	# Error Codes :
		# 2 : Wrong Number of Parameters
		# 3 : Not supported Distrubtion
		
	
if [ "$#" -ne 2 ]; then
    echo "You must enter exactly 2 command line arguments"
	echo "The first parameter is Workspace ID"
	echo "The second parameter is Primary Key"
	exit 2
fi


# get Linux OS-Distrubtion which may equal to rhel/ubuntu/debian/sles

	OS-Distrubtion=`cat /etc/*-release | grep "^ID=" | cut -d"=" -f2 | sed 's/"//g' | tail -1`


# Remove Old OMS Configuration from command line :
 
          sudo /opt/microsoft/omsagent/bin/omsadmin.sh -X
          sudo mkdir /var/lib/waagent/old-oms ; mv /var/lib/waagent/Microsoft.EnterpriseCloud.Monitoring*  /var/lib/waagent/old-oms/
 
                
# Upgrade WAAgent and Restart Related Service :
 
	# RHEL/CentOS : 
	
if ["$OS-Distrubtion" = "rhel"]; then

          sudo yum update -y WALinuxAgent
          sudo service waagent restart 

elif ["$OS-Distrubtion" = "ubuntu"]; then
           
	# Ubuntu :
 
          sudo apt-get upgrade -y walinuxagent
          sudo systemctl restart walinuxagent 

elif ["$OS-Distrubtion" = "debian"]; then
           
	# Debian :
 
          sudo apt-get upgrade -y walinuxagent
          sudo systemctl restart walinuxagent 

elif ["$OS-Distrubtion" = "sles"]; then
           
	# Suse :
 
          sudo zypper up python-azure-agent
          sudo service waagent restart 

else
		echo This OS neither CentOS/RHEL/Ubuntu/sles (please post your feedback/findings on https://github.com/othmanaljundi-microsoft/azure-oms-scripts ) 
		exit 3
fi  

 
# Delete old configuration of oms workspace :
 
           sudo /opt/microsoft/omsagent/bin/omsadmin.sh -X
           sudo [ -d /root/msoms ] || sudo mkdir /root/msoms
           sudo rm -rf /root/msoms/*
           sudo cd /root/msoms
           sudo wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh
           sudo sudo sh onboard_agent.sh --purge
 
 
# Ensure that all Packages are removed : 

	# RHEL/CentOS : 
	
if ["$OS-Distrubtion" = "rhel"]; then

          sudo yum remove -y scx omi omsagent omsconfig auoms 

elif ["$OS-Distrubtion" = "ubuntu"]; then
           
	# Ubuntu :
 
          sudo apt-get remove scx omi omsagent omsconfig auoms

elif ["$OS-Distrubtion" = "debian"]; then
           
	# Debian :
 
          sudo apt-get remove scx omi omsagent omsconfig auoms

elif ["$OS-Distrubtion" = "sles"]; then
           
	# Suse :
 
          sudo zypper rm python-azure-agent

else
		echo This OS neither CentOS/RHEL/Ubuntu/sles (please post your feedback/findings on https://github.com/othmanaljundi-microsoft/azure-oms-scripts ) 
		exit 3
fi  
  
                
 
# Ensure that the following directories should be not there :
 
          sudo [ -d /etc/opt/microsoft ] && sudo mv /etc/opt/microsoft /etc/opt/microsoft.old
          sudo [ -d /var/opt/microsoft ] && sudo mv /var/opt/microsoft /var/opt/microsoft.old
          sudo [ -d /etc/opt/omi ] && sudo mv /etc/opt/omi /etc/opt/omi.old
          sudo [ -d /var/opt/omi ] && sudo mv /var/opt/omi /var/opt/omi.old
 
 
# Ensure that users/Groups are deleted :
 
          sudo id -u omsagent && sudo userdel -r omsagent
          sudo id -u omi && sudo userdel -r omi
          sudo id -u nxautomation && sudo userdel -r nxautomation
          sudo id -g omiusers && sudo groupdel omiusers
          sudo id -g omsagent && sudo groupdel omsagent
          sudo id -g nxautomation && sudo groupdel nxautomation
          sudo id -g omi && sudo groupdel omi
                
# Check if there is any process that still running :

          sudo ps -ef | grep -i "omi\|oms\|nxautom" | awk '$8!="grep" {print $0}' | awk '{print $2}' | sed 's/^/kill -9 /g' >> /root/msoms/kill-oms-processes-script.sh
          sudo chmod +x /root/msoms/kill-oms-processes-script.sh
          sudo sh /root/msoms/kill-oms-processes-script.sh
 
# Redo the Purge Process again :
 
          sudo cd /root/msoms
          sudo sh onboard_agent.sh --purge
 
 
 
# Installation from command Line :
                                                
          sudo [ -d /root/latest-oms ] || sudo mkdir /root/latest-oms
          sudo cd /root/latest-oms/
          sudo wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && sudo sh onboard_agent.sh -w $1 -s $2 -d opinsights.azure.com
 
 
 
 
# Check the status of OMS Related Services :

if ["$OS-Distrubtion" = "rhel"]; then

          sudo /opt/microsoft/omsagent/bin/omsadmin.sh -l  ; sudo scxadmin -status all ; service waagent status

elif ["$OS-Distrubtion" = "ubuntu"]; then
           
	# Ubuntu :
 
          ssudo /opt/microsoft/omsagent/bin/omsadmin.sh -l  ; sudo scxadmin -status all ; systemctl status walinuxagent

elif ["$OS-Distrubtion" = "debian"]; then
           
	# Debian :
 
          sudo /opt/microsoft/omsagent/bin/omsadmin.sh -l  ; sudo scxadmin -status all ; systemctl status walinuxagent

elif ["$OS-Distrubtion" = "sles"]; then
           
	# Suse :
 
          sudo /opt/microsoft/omsagent/bin/omsadmin.sh -l  ; sudo scxadmin -status all ; service waagent status

else
		echo This OS neither CentOS/RHEL/Ubuntu/sles (please post your feedback/findings on https://github.com/othmanaljundi-microsoft/azure-oms-scripts ) 
		exit 3
fi  


