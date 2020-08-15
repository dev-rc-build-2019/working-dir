#!/bin/bash
#
#*********************
# Name: pre_system_check.sh
# Author:  R. Cutler
# Description:  script to check host prior to database build
#
# Date         Rev #   Author   Change/Modifications
# -----------  ------  -------  ---------------------------
# 09.13.2018   1.0     RJC      Initial version 
########################
#  Initialize global variables
########################
stage_dir='/tmp'
########################
# Set environment variable
########################
. /<path>/set_env_19.sh
#
export FILENAME=/tmp/precheck.log
export HOSTNAME=`hostname`
export DBA_MAIL=${notifylist}
########################
# Space calculations
#  Different memtot and swaptot depends on RHEL version
########################
megabyte=1048576
rcommem=2097152
swaprammem=16777216
memtot=`grep MemTotal /proc/meminfo | awk -F ':' '{print $2}' | cut -d" " -f8`
memtot2=`grep MemTotal /proc/meminfo | awk -F ':' '{print $2}' | cut -d" " -f9`
swaptot=`grep SwapTotal /proc/meminfo | awk -F ':' '{print $2}' | cut -d" " -f7`
swaptots=`grep SwapTotal /proc/meminfo | awk -F ':' '{print $2}' | cut -d" " -f8`
########################
# Condition to handle field diffs - depending on the value used the appropriate variable
#  For anything less than 10GB use alternate value
########################
if [ -z ${memtot}]
then
   memver=${memtot2}
else
   memver=${memtot}
fi
if [ -z ${swaptot}]
then
   swapver=${swaptot2}
else
   swapver=${swaptot}
fi
########################
# Calculate total for display
########################
totmem=$(((${memver}/${megabyte}+1)))
totswap=$(((${swapver}/${megabyte}+1)))
totswapram=$(((${swaprammem}/${megabyte})))
########################
# Begin processing
#   NFS mounts mut be activated
########################
df -h /app/oracle/.
df -h /app/oraoem/.
df -h /data/oracle01/.
########################
echo "        Platform Requirements"
echo "======================================"
echo "   Processor "
uname -m
########################
echo "  "
echo "  OS Version"
cat /etc/redhat-release
#
echo "  "
echo "  Kernel version"
uname -r
#
echo "  "
echo "  "
echo "            RAM and Swap"
echo "======================================"
########################
# Determine Memory Total
########################
echo "   Memory Total: minimum - 1GB / Recommended: 2GB or more"
########################
# Compare total memory to recommended size
########################
if [ ${memver} -lt ${recommem } ]
then
   echo "*Meets minimum requirements of 1GB: " ${totmem} " Recommendation of 2GB or more"
else
   echo "Exceeds minimum requirements of 1GB - Memtotal: " ${totmem} 
fi 
echo "  "
########################
########################
.....
########################
########################
########################
########################
########################

########################
########################
