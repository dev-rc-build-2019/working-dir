#!/bin/bash
#
#***************
# Name: patch_binary_only_19.sh
# Author:  R. Cutler
# Description:  12cR2 and higher
#               Patch binaries only using Oracle combo patch
#***************
# DATE        NAME           DESCRIPTION
# ----------  -------------- ------------------------------------
# 11.07.2019  R. Cutler      Code for automation
#****************
########################
# Initialize global variables
########################
stage_dir="/tmp/code"
########################
# Set environment variables
########################
. ${stage_dir}/set_env_19.sh
#
export OPATCH_DIR="<path>/19000"
export OPATCH_DIR="<path>/New_OPatch"
export HOSTNAME=`hostname`
export DBA_MAIL=${notifylist}
#########################
# send an email patching process is beginning
#########################
echo "patching of server $HOSTNAME began at `date`" > /tmp/start_time_binary.txt
mailx -s "Patching binaries only $HOSTNAME has begun " oracle@$HOSTNAME $DBA_MAIL < /tmp/start_time_binary.txt
chmod 777 /tmp/start_time.txt
#########################
# switch to patch directory
#########################
cd $PATCH_DIR
#########################
# checking combo patch levels
#  move into position to apply the first of 2 patches
#########################
cd `ls -1rdt */ | tail -1`
cd `ls -1rdt */ | tail -1`
#########################
# apply the first of 2 patches
#########################
$ORACLE_HOME/OPatch/opatch apply -silent
#########################
# move to the base directory of the second patch
#########################
cd ..
#########################
# move to the base directory of the second patch
#   apply the second of 2 patches
#########################
cd `ls -1rdt */ | head -2`
$ORACLE_HOME/OPatch/opatch apply -silent
##########################
# back to the combo patch top directory
##########################
cd ../../
##########################
# verify patches have been applied to binaries
##########################
echo " " >> /tmp/patch_binary.log
echo "Database patch: " `$ORACLE_HOME/OPatch/opatch lsinv | grep {{ db_patch }}` >> /tmp/patch_binary.log
echo "OJVM patch: " `$ORACLE_HOME/OPatch/opatch lsinv | grep {{ ojvm_patch }}` >> /tmp/patch_binary.log
###########################
# look for errors in the log
# send log information to designated DBA
# remove interim log - change permissions to rwx on main log
###########################
ERRCNT=`grep -E "ORA-|error" /tmp/patch_binary.log | wc -l`
if [ ! "${ERRCNT}" = "0" ] 
then
   RESULT="with errors"
   echo -e "STATUS: FAILURE\n"
else
   RESULT="without errors"
   echo -e "STATUS: SUCCESS\n"
fi
###########################
# cleanup/remove interim logs
#  change permissions on patch_binary.log
###########################
rm /tmp/start_time_binary.txt
chmod 777 /tmp/patch_binary.log
###########################
# Send notification
###########################
mailx -s "Patching binaries only $HOSTNAME completed $RESULT" oracle@$HOSTNAME $DBA_MAIL < /tmp/patch_binary.log
###########################
# end of script