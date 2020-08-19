#!/bin/bash
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        create_cron.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Creates crontab file
# VARIABLES:
#         sid       = oracle_sid
#         sid2      = upper case oracle_sid
#         oracleid  = oracle unix id
#         file_name = cron file name
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE       NAME            DESCRIPTION
# ---------- --------------- --------------------------------------------------
# 01.09.2020 R Cutler        Add comments on code logic
# 11.25.2019 R Cutler        Create                                  
###########################################################################
#  initialize parameters
###########################################################################
stage_dir="/tmp/code"
#stage_dir="/app/oradba/automation/scripts"
#
###########################################################################
# Set environment variables
###########################################################################
. ${stage_dir}/set_env_19.sh
#
sid=${orasid}
sid2=`echo ${sid} | tr [:lower:] [:upper:]`
oracleid=${oraid}
orahome=${orahome}
a_flag=${ha_flag}
nlist=${notifylist}
###########################################################################
# if not ha environment enter sid
###########################################################################
if [ -z ${a_flag} ]
then
   a_flag=${sid}
fi
###########################################################################
# Replace files
###########################################################################
cp ${stage_dir}/cronenv_oraclesid.sh /home/${oracleid}/${sid2}/scripts/cronenv_${sid}.sh
cp ${stage_dir}/cron_nonc /home/${oracleid}/${sid2}/scripts/cron_nonc
file_name="/home/${oracleid}/${sid2}/scripts/cron_nonc"
cfile="/home/${oracleid}/${sid2}/scripts/cronenv_${sid}.sh"
###########################################################################
# Modify cron file entries
###########################################################################
/bin/sed -i "s/oracle_sid/${sid}/g" ${file_name}
/bin/sed -i "s/sid/${sid2}/g" ${file_name}
/bin/sed -i "s/unix_id/${oracleid}/g" ${file_name}
/bin/sed -i "s/ha_flag/${a_flag}/g" ${file_name}
/bin/sed -i "s/list/${nlist}/g" ${cfile}
###########################################################################
# Create the crontab
###########################################################################
/usr/bin/crontab ${file_name}
###########################################################################
# end of script

