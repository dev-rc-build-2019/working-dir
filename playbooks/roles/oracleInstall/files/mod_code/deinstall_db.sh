#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        deinstall_db.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script to deprovision Oracle 12.2 (19c)
# VARIABLES:
#        stage_dir  = script staging path
#        oratabf    = oratab file location
#        orasid     = pull sid from /etc/oratab file
#        orahome    = pull oracle home from /etc/oratab file
#        lsnr       = pull listener name from listener.ora file
#        deins_copy = pull oracle home from /etc/oratab
#        deins_temp = pull oracle home from /etc/oratab
#        sidu       = pull oracle home from /etc/oratab
#        sidl       = pull oracle home from /etc/oratab
#        hostname   = name of database host
#        filename   = error/message log file
#        dba_mail   = distribution list for messaging
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 01.09.2020    R Cutler        Add comments on code logic
# 11.20.2019    R Cutler        Initial code
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Initialize global variables
##########################################
stage_loc="/app/oradba/automation/oracle19"
stage_dir="/tmp/code"
tarfile=code.tar
##########################################
# If directory doesn't exist create it
# If directory exists delete and recreate it
#  download tar ball and untar contents
##########################################
if [ ! -d ${stage_dir} ]; then
  mkdir -p ${stage_dir}
  cp ${stage_loc}/${tarfile} ${stage_dir}/.
  cd ${stage_dir}
  tar -xvf ${tarfile}
else
  rm -rf ${stage_dir}
  mkdir -p ${stage_dir}
  cp ${stage_loc}/*.tar ${stage_dir}/.
  cd ${stage_dir}
  tar -xvf ${tarfile}
fi
##########################################
# Set environment variables
##########################################
. ${stage_dir}/set_env_19.sh
#
oratabf="/etc/oratab"
orasid=`grep -E "19.0" ${oratabf} |head -1 |awk -F ":" '{print $1}'`
orahome=`grep -E "19.0" ${oratabf} |head -1 |awk -F ":" '{print $2}'`
lsnr=`grep ^LISTENER $ORACLE_HOME/network/admin/listener.ora 2>/dev/null | head -24 | awk '{print $1}'`
deins_copy="${stage_dir}/deinstall_copy.rsp"
deins_temp="/tmp/deinstall_temp.rsp"
sidu=`echo ${orasid} | tr [:lower:] [:upper:]`
sidl=`echo ${orasid} | tr [:upper:] [:lower:]`
hostname=`hostname`
export filename="/tmp/deinstall.out"
export DBA_MAIL=${notifylist}
##########################################
#    Module to deprovision environment
##########################################
deinstall_db()
{
###########################################################################
# Modify template file
###########################################################################
cp ${deins_copy} ${deins_temp}
/bin/sed -i "s/<host>/${hostname}/g" ${deins_temp}
/bin/sed -i "s/<sidl>/${sidl}/g" ${deins_temp}
/bin/sed -i "s/<sidu>/${sidu}/g" ${deins_temp}
/bin/sed -i "s/<lsnr>/${lsnr}/g" ${deins_temp}
#
###########################################################################
# Run deinstall executable
# If successful - display message - remove directories and files
# If not successful - display message - send notification
###########################################################################
${stage_dir}/turnoff_dnfs_19.sh
#
${orahome}/deinstall/deinstall -silent -paramfile ${deins_temp} > ${filename}
if [ "$?" = "0" ]; then
  echo -e "STATUS:SUCCESS\n"
  rm -rf /data/dump01/*
  rm -rf /data/audit01/*
  rm -rf /data/oracle01/*
  rm -rf /data/oracle02/*
  rm -rf /data/oracle03/*
  rm -rf /app/oracle/*
  rm -rf /tmp/logs
  rm -rf ${deins_temp}
  crontab -r
else
  echo -e "STATUS:FAILURE\n"
  echo -e "ERRORMESSAGE:Failed on deinstalling - deinstall.sh\n"
  mailx -s "DEINSTALL failed on $hostname - deinstall.sh" oracle $DBA_MAIL < ${filename}
fi
}
##########################################
#    Call the module for execution
##########################################
deinstall_db
##########################################
#  end of script
