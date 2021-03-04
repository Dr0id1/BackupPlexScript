#!/bin/bash

# Backup a Plex database.
# Original Author Scott Smereka
# Edited by Neil C.
# Adapted for personnal use by Maxime P.
# Version 1.1


# Script Tested on:
# Ubuntu 20.04 on 2020-Aug-9 [ OK ] 


# Plex Database Location. The trailing slash is 
# needed and important for rsync.
plexDatabase="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server"


# Create backup location
mkdir /mnt/buplex
mkdir /mnt/buplex/Archive
mkdir /mnt/buplex/Archive/Plex_Backups
mkdir /mnt/buplex/Archive/Plex_Backups/logs

# Location to backup the directory to.
backupDirectory="/mnt/buplex/Archive/Plex_Backups"


# Log file for script's output named with 
# the script's name, date, and time of execution.
scriptName=$(basename ${0})
log="/mnt/buplex/Archive/Plex_Backups/logs/buplex.log"


# Check for root permissions
if [[ $EUID -ne 0 ]]; then
echo -e "${scriptName} requires root privileges.\n"
echo -e "sudo $0 $*\n"
exit 1
fi


# Mount Plex Media Share in R/W mode
sudo mount /mnt/buplex 

# Create Log
echo -e "***********" >> $log 2>&1
echo -e "$(date '+%Y-%b-%d at %k:%M:%S') :: Mounted Share in R/W Mode." | tee -a $log 2>&1


# Stop Plex
echo -e "$(date '+%Y-%b-%d at %k:%M:%S') :: Stopping Plex Media Server." | tee -a $log 2>&1
sudo service plexmediaserver stop | tee -a $log 2>&1


# Backup database
echo -e "$(date '+%Y-%b-%d at %k:%M:%S') :: Starting Backup." | tee -a $log 2>&1
# WORKING Line: sudo tar cfz "$backupDirectory/buplex-$(date '+%Y-%m(%b)-%d at %khr %Mmin').tar.gz"  "$plexDatabase" >> $log 2>&1
# cd into  directory so the magic --exclude below works per:
# https://stackoverflow.com/questions/984204/shell-command-to-tar-directory-excluding-certain-files-folders
cd "$plexDatabase"
sudo tar cz --exclude='./Cache' -f "$backupDirectory/buplex-$(date '+%Y-%m(%b)-%d at %khr %Mmin').tar.gz" . >> $log 2>&1


# Restart Plex
echo -e "$(date '+%Y-%b-%d at %k:%M:%S') :: Starting Plex Media Server." | tee -a $log 2>&1
sudo service plexmediaserver start | tee -a $log 2>&1


# Done
echo -e "$(date '+%Y-%b-%d at %k:%M:%S') :: Backup Complete. Unmounting R/W Share..." | tee -a $log 2>&1
echo -e "***********" >> $log 2>&1
sudo umount /mnt/buplex
