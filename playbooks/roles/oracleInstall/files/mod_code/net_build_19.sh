#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        net_build_19.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script to modify listener.ora and tnsnames.ora files
# VARIABLES:
#         sid       = oracle_sid
#         sidu      = upper case oracle_sid
#         oracleid  = oracle unix id
#         srvname   = server name
#         prtnum    = listener port name 
#         lsnrbase  = application name
#         lsnr      = suffix to be added to the listener name 
#         lsnrname  = Upper case listener name 
#         orabase   = Oracle Base directory    
#         orahome   = Oracle Home directory    
#         lsnrfile_name = listener.ora work file
#         tnsfile_name  = tnsnames.ora  work file
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE       NAME            DESCRIPTION
# ---------- --------------- --------------------------------------------------
# 01.09.2020    R Cutler        Add comments on code logic
# 10/09/2019 Renee Cutler    Inital for automation
###########################################################################
#  Initialize global parameter(s)
###########################################################################
stage_dir="/tmp/code"
###########################################################################
#  Set environment variable(s)
###########################################################################
. ${stage_dir}/set_env_19.sh
#
sid=${1}
sidu=`echo ${sid} | tr [:lower:] [:upper:]`
oracleid=${oraid}
srvname=${srvname}
prtnum=${port}
lsnrbase=`echo ${sid} | cut -c 2-7`
lsnr=listener_${lsnrbase}
lsnrname=`echo ${lsnr} | tr [:lower:] [:upper:]`
orabase=${orabase}
orahome=${orahome}
work_dir="/home/${oracleid}/${sidu}/scripts"
lsnrfile_name="/home/${oracleid}/${sidu}/scripts/listener.ora"  
tnsfile_name="/home/${oracleid}/${sidu}/scripts/tnsnames.ora"
sqlfile_name="/home/${oracleid}/${sidu}/scripts/sqlnet.ora"
#
###########################################################################
# lsnr_build() module            
###########################################################################
lsnr_build()
{
###########################################################################
# Copy files to working directory
###########################################################################
cp ${stage_dir}/listener.ora.copy ${lsnrfile_name}
cp ${stage_dir}/tnsnames.ora.copy ${tnsfile_name}
cp ${stage_dir}/sqlnet.ora.copy ${sqlfile_name}
#
###########################################################################
# Modify listener.ora
###########################################################################
/bin/sed -i "s/<sid>/${sid}/g" ${lsnrfile_name}
/bin/sed -i "s/<lsnr>/${lsnrname}/g" ${lsnrfile_name}
/bin/sed -i "s/<prtnum>/${prtnum}/g" ${lsnrfile_name}
/bin/sed -i "s/<server_name>/${srvname}/g" ${lsnrfile_name}
/bin/echo "ADR_BASE_${lsnrname}=${orabase}" >> ${lsnrfile_name}
#/bin/cat ${lsnrfile_name}
###########################################################################
# Modify tnsnames.ora
###########################################################################
/bin/sed -i "s/<sid>/${sid}/g" ${tnsfile_name}
/bin/sed -i "s/<sidu>/${sidu}/g" ${tnsfile_name}
/bin/sed -i "s/<lsnr>/${lsnrname}/g" ${tnsfile_name}
/bin/sed -i "s/<server_name>/${srvname}/g" ${tnsfile_name}
/bin/sed -i "s/<prtnum>/${prtnum}/g" ${tnsfile_name}
#/bin/cat ${tnsfile_name}
###########################################################################
# Copy listener and tnsnames files to server location
###########################################################################
/bin/cp ${tnsfile_name}  ${orahome}/network/admin/.
/bin/cp ${lsnrfile_name} ${orahome}/network/admin/.
/bin/cp ${sqlfile_name}  ${orahome}/network/admin/.
#
###########################################################################
# start net listener 
###########################################################################
${orahome}/bin/lsnrctl start ${lsnrname}
}
###########################################################################
# call module to modify and copy the files to TNS_ADMIN directory
###########################################################################
lsnr_build
###########################################################################
# end of script

