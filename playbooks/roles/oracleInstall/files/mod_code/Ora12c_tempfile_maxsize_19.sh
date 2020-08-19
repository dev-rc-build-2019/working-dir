#!/bin/ksh
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        Ora12c_tempfile_maxsize.sh 
# AUTHOR:      Original R. Barton / Modified R. Cutler
# DESCRIPTION: Script to change the max size on the TEMP tablespace to 4G
# VARIABLES:
#         sid       = oracle_sid
#         sid2      = upper case oracle_sid
#         oracleid  = oracle unix id
#         instno    = first instance
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE       NAME            DESCRIPTION
# ---------- --------------- --------------------------------------------------
# 01.09.2020 R Cutler        Add comments on code logic
# 10.28.2019 R Cutler        Modified to accept variables - Oracle 12.2.0.3   
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
###########################################################################
#  initialize parameters
###########################################################################
stage_dir="/tmp/code"
#
###########################################################################
#  Set environment variables
###########################################################################
. ${stage_dir}/set_env_19.sh
#
sid=${1}
sid2=`echo ${sid} | tr [:lower:] [:upper:]`
oracleid=${oraid}
instno=0
##########################################
# Log into sqlplus - alter temp file size
##########################################
${orahome}/bin/sqlplus -S /nolog << EOF
connect / as sysdba
set echo on
spool /home/${oracleid}/${sid2}/sysout/ALTER_temp_maxsize.log
ALTER DATABASE TEMPFILE '/data/oracle02/${sid}/temp/temp01.dbf' AUTOEXTEND ON MAXSIZE 4G;
spool off;
exit;
EOF
##########################################
# end of script
