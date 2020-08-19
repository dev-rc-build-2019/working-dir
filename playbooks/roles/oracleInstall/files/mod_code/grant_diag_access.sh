#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        grant_diag_access.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Modify permissions diag/rdbms and diag/tnslsnr
# VARIABLES: 
#        oratabf = Oracle oratab file
#        orasid = Oracle SID 
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 01.09.2020    R Cutler        Add comments on code logic
# 11.25.2019    R Cutler        Creation 
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Initialize global variable(s)
##########################################
oratabf="/etc/oratab"
orasid=`grep -E "19.0" ${oratabf} |head -1 |awk -F ":" '{print $1}'`
##########################################
#  Grant read permissions to others group
##########################################
chmod o+r /app/oracle/diag/rdbms/${orasid}
chmod o+r /app/oracle/diag/rdbms/${orasid}/${orasid}
chmod -R o+r /app/oracle/diag/rdbms/${orasid}/*/trace
chmod o+r /app/oracle/diag/tnslsnr/*/*/trace/*log
##########################################
#  end of script
