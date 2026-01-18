#!/bin/bash

reportfile="$HOME"/srv/security_log/"sysreport.$(date +%y-%m-%d_%H:%M).txt"

# Define color codes
red='\033[0;31m'
green='\033[0;32m'
nocolor='\033[0m'

# wrap the script and use OR operator to run through two independent source options to fit different systems
# get intel on failed logins from journalctl or auth.log, extract last 10

{
echo "Show last 10  failed logins: "
sudo journalctl _COMM=login -g "FAILED" | tail -n 10 || sudo grep "Failed password" /var/log/auth.log | tail -n 10 
if [ -z "$failed" ]; then
echo -e  "${green}No failed logins detected!${nocolor}"
else 
echo -e "${red}Last 10 failed logins:${nocolor}"
echo "$failed"
fi

echo ""

# get the users from /ect/passwd, extract last 5, print the first column of the output
echo "Last 5 created users on the system: "
tail -n 5 /etc/passwd | awk -F: '{print $1}' 

echo ""

# get intel on sudo usage from  journalctl or auth.log, limit the search to 24h/today
echo  "Users who have used sudo in the last 24 hr: "
sudo journalctl _COMM=sudo  --since "24 hours ago"  | awk '{print $13}' | sort -u || sudo grep  "sudo.*$(date '+%b %e')" /var/log/auth.log | awk '{print $13}' | sort -u

echo ""

# detect ssh login attempts from journalctl, limit the search to 100
echo "Last 100 SSH logins:"
sudo journalctl -u ssh --no-pager | grep "Accepted" | tail -n 100 | awk '{print $(NF-3), $(NF-5)}'

echo ""
# get information on available disk space and issue warning
echo "Current disk space. Above 80% space usage will be issued an alert"
df -h | awk -v red="$red" -v green="$green" -v nc="$nocolor" 'NR>1 {usage=$5; if (usage>80) print red $0 " WARNING! Disk space over 80%"; else print green $0 nc}' 
} | tee -a "$reportfile"
