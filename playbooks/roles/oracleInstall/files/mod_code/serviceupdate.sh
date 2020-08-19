#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        serviceupdate.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script to send notification and update attributes
# VARIABLES:
#         $1 = character set
#         $2 = email address notification
#         $3 = oracle account
#         $4 = generate random password
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 07.08.2020    R Cutler        Add lines for ITP updates/adds 
# 03.09.2020    R Cutler        Add separate line for SID/Service Name
# 12.05.2019    R Cutler        Created 
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Initialize global variables
##########################################
stage_dir="/tmp/code"
##########################################
. $stage_dir/set_env_19.sh
#
filename="${stage_dir}/dataowner.txt"
notifyfile="${stage_dir}/notify.txt"
oratabf="/etc/oratab"
orasid=`grep -E "19.0" ${oratabf} |head -1 |awk -F ":" '{print $1}'`
hname=`hostname -f`
lport="1531"
dbver="19.0.0"
charset="$1"
mailuser="$2"
acctid="$3"
passw="$4"
sname="Oracle 19c VMWare Linux"
supportdb="${notifylist}"
ngdbsupport="${ngdbnotify}"
###############
# build module
###############
updateattr()
{
###############
# define file systems
###############
fsystem1="/app/oracle"
fsystem2="/app/oraoem"
fsystem3="/data/oracle01"
fsystem4="/data/oracle02"
fsystem5="/data/oracle03"
fsystem6="/data/audit01"
fsystem7="/data/dump01"
###############
# make sure the file systems are available
###############
touch ${fsystem1}
touch ${fsystem2}
touch ${fsystem3}
touch ${fsystem4}
touch ${fsystem5}
touch ${fsystem6}
touch ${fsystem7}
###############
# get file sizes
###############
fssize1=`df -h | grep $fsystem1 | awk '{print $2+0}'`
fssize2=`df -h | grep $fsystem2 | awk '{print $2+0}'`
fssize3=`df -h | grep $fsystem3 | awk '{print $2+0}'`
fssize4=`df -h | grep $fsystem4 | awk '{print $2+0}'`
fssize5=`df -h | grep $fsystem5 | awk '{print $2+0}'`
fssize6=`df -h | grep $fsystem6 | awk '{print $2+0}'`
fssize7=`df -h | grep $fsystem7 | awk '{print $2+0}'`
###############
# message to capture attr updates
###############
#echo -e "STATUS:SUCCESS\n"
echo -e "ASBUILT:DAT-ORA - Connect Host|$hname\n"
echo -e "ASBUILT:DAT-ORA - Database Version|$dbver\n"
echo -e "ASBUILT:DAT-ORA-INSTANCE 1 - /app/oracle Size(GB)|$fssize1\n"
echo -e "ASBUILT:DAT-ORA-INSTANCE 1 - /app/oraoem Size(GB)|$fssize2\n"
echo -e "ASBUILT:DAT-ORA-INSTANCE 1 - /data/oracle01 Size(GB)|$fssize3\n"
echo -e "ASBUILT:DAT-ORA-INSTANCE 1 - /data/oracle02 Size(GB)|$fssize4\n"
echo -e "ASBUILT:DAT-ORA-INSTANCE 1 - /data/oracle03 Size(GB)|$fssize5\n"
echo -e "ASBUILT:DAT-ORA-INSTANCE 1 - /data/audit01 Size(GB)|$fssize6\n"
echo -e "ASBUILT:DAT-ORA-INSTANCE 1 - /data/dump01 Size(GB)|$fssize7\n"
echo -e "ASBUILT:DAT-ORA-INSTANCE 1 - Character Set|$charset\n"
echo -e "ASBUILT:DAT-ORA-INSTANCE 1 - Database Name|$orasid\n"
echo -e "ASBUILT:DAT-ORA-INSTANCE 1 - Listener Port -1|$lport\n"
echo -e "ASBUILT:DAT-ORA-INSTANCE 1 - Service name|$sname\n"
}
###############
# send notification to user
#   set file location
#   append values to file
#   send notifications to Support DBA DL and Primary DBA
###############
sendnotify()
{
touch $filename
echo -e "Subject: ORACLE 19c VML\n" > $filename
echo -e "Your environment has been provisioned successfully.\n" >> $filename
echo -e "   Summary of Order:\n" >> $filename
echo -e "DB Address: $hname\n" >> $filename
echo -e "DB Port: $lport\n" >> $filename
echo -e "SID/Service Name: $orasid\n" >> $filename
echo -e "JDBC Connection String: jdbc:oracle:thin://$hname:$lport:$orasid\n" >> $filename
echo -e "**Please ensure that you add this new server/instance to your associated ITP record\n" >> $filename
echo -e "    located here: https://itp.ssc.lmco.com/app/portfolio/configmgmt/<commonid>\n" >> $filename
mailx -s "${sname}" $supportdb < $filename
mailx -s "${sname}" $ngdbsupport < $filename
echo -e "Master account: $acctid\n" >> $filename
echo -e "   Password will be sent in a separate email.\n" >> $filename
mailx -s "Oracle 19c VML" $mailuser < $filename
####
touch $notifyfile
echo -e "Subject: ORACLE 19c VML\n" > $notifyfile
echo -e " Password: ${passw}\n" >> $notifyfile
mailx -s "$(echo -e "Oracle 19c VML\nX-Priority: 1")" $mailuser < $notifyfile
####
rm -rf /tmp/dbca*log
mv /tmp/prov* /tmp/CVU*/.
chmod 000 /tmp/CVU*/prov*
}
###############
# Call modules
# 1.  Send data to update attributes
# 2.  Send notification 
###############
updateattr
sendnotify
###############
# end of script
