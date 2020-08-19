#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        postDBprov_19.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script to complete database build 
# VARIABLES:
#             sid         = lower case Oracle SID
#             sidu        = upper case Oracle SID 
#             ntid        = application dba's ntid
#             passw       = random password for application dba account
#             mtype       = memory managment type (m - memory_target or s - sga_target)
#             lname       = current listener name in the listener.ora
#             llsnr       = description string for the listener
#             EMAIL_LIST  = notification email list 
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE       NAME            DESCRIPTION
# ---------- --------------- --------------------------------------------------
# 04.09.2020 R Cutler        Add utl_mail and grant purge recyclebin to app dba
# 12.05.2019 R Cutler        Add ntid field and logic
# 12.04.2019 R Cutler        Modifications to accomodate automation
#
###########################################################################
# initialize global parameters
###########################################################################
#stage_loc="/app/oradba/automation/scripts"
stage_dir="/tmp/code"
###########################################################################
# Set environment variables
###########################################################################
. ${stage_dir}/set_env_19.sh
#
sid=$1
mtype=$2
ntid=$3
passw="$4"
sidu=`echo ${sid} | tr [:lower:] [:upper:]`
lname=`grep ^LISTENER ${orahome}/network/admin/listener.ora | head -24 | awk '{print $1}'`
llsnr=`${orahome}/bin/lsnrctl status ${lname} | grep -v grep | grep 'Connecting to ' | awk '{print $3}'`
#
###########################################################################
# Email list
###########################################################################
EMAIL_LIST=${notifylist}
##########################################################################
# Log into sqlplus
# Set memory_target (m) if RAM is 16G or less and SGA < 8GB 
#  run script to make changes to spfile (parameter file)
###########################################################################
if [ $mtype = "m" ]
then
${orahome}/bin/sqlplus -S /nolog << EOF
connect / as sysdba
set head off
spool /tmp/code/chg_mem.sql
select 'alter system set memory_max_target='||trunc(value)||' scope=spfile;' from v\$parameter where name = 'sga_target';
select 'alter system set memory_target='||trunc(value)||' scope=spfile;' from v\$parameter where name = 'sga_target';
select 'alter system set sga_target=0 scope=spfile;' from dual;
select 'alter system set use_large_pages=FALSE scope=spfile;' from dual;
spool off
@${stage_dir}/chg_mem.sql
exit;
EOF
fi
###########################################################################
# Run script(s) to harden environment
#  Run script to create dba role and account
###########################################################################
${orahome}/bin/sqlplus -S /nolog << EOF
connect / as sysdba
@${stage_dir}/Password_Complexity_Routine_19.sql
@${stage_dir}/revoke_privs_19.sql
@${stage_dir}/audit_system.sql
@${stage_dir}/create_appdba_dedicated_role.sql
@${stage_dir}/create_fsdba_role.sql
alter user sys profile VERIFY_PW_SERVICE;
@/app/oracle/product/19.0.0/dbhome_1/rdbms/admin/utlmail.sql
@/app/oracle/product/19.0.0/dbhome_1/rdbms/admin/prvtmail.plb
set head off
set feedback off
set lines 110
spool /tmp/code/createuser.sql
select 'create user ${ntid} identified by "${passw}" default tablespace users password expire;' from dual;
select 'alter user ${ntid} quota 5m on users;' from dual;
select 'alter user ${ntid} profile VERIFY_PW_NG_PRIVILEGED;' from dual;
select 'grant appdba to ${ntid};' from dual;
select 'grant purge dba_recyclebin to ${ntid};' from dual;
spool off
@${stage_dir}/createuser.sql
revoke execute on utl_mail from public;
exit;
EOF
###########################################################################
# Run commands/scripts for DAVS requirements - security
#   fix local_listener parameter
###########################################################################
${orahome}/bin/sqlplus -S /nolog << EOF
connect / as sysdba
set head off
set feedback off
spool /tmp/code/change_profile.sql
select unique 'alter profile '||profile||' limit password_reuse_max 20;' from dba_profiles where profile not in ('DEFAULT');
spool off
alter system set db_securefile=always scope=both;
set linesize 200
spool /tmp/code/set_lsnr.sql
select 'alter system set local_listener='||'''${llsnr}'''||' scope=both;' from dual;
spool off
@${stage_dir}/set_lsnr.sql
exit;
EOF
###########################################################################
# Restart the database
###########################################################################
${orahome}/bin/sqlplus -S /nolog << EOF
connect / as sysdba
shutdown immediate;
startup;
exit;
EOF
###########################################################################
# Run scripts to check vulnerabilities - CIS requirement
###########################################################################
${orahome}/bin/sqlplus -S /nolog << EOF
connect / as sysdba
@${stage_dir}/change_profile.sql
@${stage_dir}/Oracle12c_Provisioning_Quality_Checks.sql
exit;
EOF
###########################################################################
# harden Oracle Net environment
###########################################################################
cd ${orahome}/network/admin
chmod 600 *
chmod 640 sqlnet.* listener.*  *.lst
chmod 644 tnsnames.*
cp sqlnet.ora sqlnet.ora.bu
cp listener.ora listener.ora.bu
###########################################################################
# Move control files to correct location - override dbca configuration
# 1. Create directories
# 2. Alter spfile and shutdown database
# 3. Copy/Move files
# 4. Start database
###########################################################################
mkdir -p /data/oracle01/${sid}/ctl
mkdir -p /data/oracle02/${sid}/ctl
mkdir -p /data/oracle03/${sid}/ctl
#
${orahome}/bin/sqlplus -S /nolog << EOD
connect / as sysdba
set linesize 200
set head off
spool /tmp/code/move_ctl.sql
select 'alter system set control_files="/data/oracle02/${sid}/ctl/control01.ctl","/data/oracle03/${sid}/ctl/control02.ctl","/data/oracle01/${sid}/ctl/control03.ctl" scope = spfile;'  from dual;
spool off
@${stage_dir}/move_ctl.sql
shutdown immediate;
exit;
EOD
#
mv /data/oracle01/${sid}/system/${sidu}/control01.ctl /data/oracle02/${sid}/ctl/control01.ctl
mv /data/oracle01/${sid}/system/${sidu}/control02.ctl /data/oracle03/${sid}/ctl/control02.ctl
mv /data/oracle01/${sid}/system/${sidu}/control03.ctl /data/oracle01/${sid}/ctl/control03.ctl
#
${orahome}/bin/sqlplus -S /nolog << EOD
connect / as sysdba
startup;
@${stage_dir}/scan_user.sql
exit;
EOD
#################################################
# Alter the TEMP tablespace maxsize to 4G
#  Turn on direct NFS using system fstab
#################################################
${stage_dir}/Ora12c_tempfile_maxsize_19.sh ${sid}
${stage_dir}/turnon_dnfs_19.sh
###########################################################################
# Prepare the system for unified auditing
# stop listener
###########################################################################
${orahome}/bin/lsnrctl stop ${lname}
###########################################################################
# shutdown the database
###########################################################################
${orahome}/bin/sqlplus -S /nolog << EOF
connect / as sysdba
shutdown immediate;
exit;
EOF
###########################################################################
# Turn off unused options - not part of turning on unified auditing
###########################################################################
cd $ORACLE_HOME/bin
chopt disable oaa
chopt disable olap
chopt disable rat
###########################################################################
# Turn on unified auditing - BEGIN
###########################################################################
cd $ORACLE_HOME/rdbms/lib
make -f ins_rdbms.mk uniaud_on ioracle ORACLE_HOME=$ORACLE_HOME
###########################################################################
# start the database
###########################################################################
${orahome}/bin/sqlplus -S /nolog << EOF
connect / as sysdba
startup;
exit;
EOF
###########################################################################
# start listener
###########################################################################
${orahome}/bin/lsnrctl start ${lname}
#
#####  END OF UNIFIED AUDITING SECTION
###########################################################################
#  Email results of hardening and Quality Check
###########################################################################
mailx -s "`hostname` / ${sidu} - Provisioning Quality Check on `date`" ${EMAIL_LIST} < ${HOME}/Oracle12c_Provisioning_Quality_Check.txt
###########################################################################
# Move files
###########################################################################
mv /app/oracle/audit/${sid}/*bin /data/audit01/${sid}/.
##########
#  end of script
