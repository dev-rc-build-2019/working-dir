#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        add_second_dba.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script to add second dba contact  
# VARIABLES:
#             charset     = charater set 
#             ntid        = application dba's ntid
#             mailuser    = application dba's email address
#             passw       = random password for application dba account
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE       NAME            DESCRIPTION
# ---------- --------------- --------------------------------------------------
# 03.12.2020 R Cutler        Created 
#
###########################################################################
# initialize parameters
###########################################################################
stage_dir="/tmp"
###########################################################################
charset=`echo $1 | tr [:lower:] [:upper:]`
ntid=$2
mailuser="$3"
orahome="/app/oracle/product/19.0.0/dbhome_1"
filename="${stage_dir}/dataowner.txt"
notifyfile="${stage_dir}/notify.txt"
oratabf="/etc/oratab"
orasid=`grep -E "19.0" ${oratabf} |head -1 |awk -F ":" '{print $1}'`
hname=`hostname -f`
lport="1531"
dbver="19.0.0"
passw=`< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c12`
sname="Oracle 19c VMWare Linux"
###########################################################################
# Email list
###########################################################################
# Run script(s) to harden environment
#  Run script to create dba role and account
###########################################################################
${orahome}/bin/sqlplus -S /nolog << EOF
connect / as sysdba
set head off
set feedback off
set lines 110
spool /tmp/createuser.sql
select 'create user ${ntid} identified by "${passw}" default tablespace users password expire;' from dual;
select 'alter user ${ntid} quota 5m on users;' from dual;
select 'alter user ${ntid} profile VERIFY_PW_NG_PRIVILEGED;' from dual;
select 'grant appdba to ${ntid};' from dual;
select 'grant purge dba_recyclebin to ${ntid};' from dual;
spool off
@${stage_dir}/createuser.sql
exit;
EOF
###############
# build module
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
echo -e "Master account: $ntid\n" >> $filename
echo -e "   Password will be sent in a separate email.\n" >> $filename
mailx -s "Oracle 19c VML" $mailuser < $filename
####
touch $notifyfile
echo -e "Subject: ORACLE 19c VML\n" > $notifyfile
echo -e " Password: ${passw}\n" >> $notifyfile
mailx -s "$(echo -e "Oracle 19c VML\nX-Priority: 1")" $mailuser < $notifyfile
#####
# Remove files
#####
rm -rf $notifyfile
rm -rf ${stage_dir}/createuser.sql
rm -rf ${filename}
rm -rf ${notifyfile}
####
####
}
###############
# Call modules
# 1.  Send data to update attributes
# 2.  Send notification 
###############
sendnotify
###############
# end of script
