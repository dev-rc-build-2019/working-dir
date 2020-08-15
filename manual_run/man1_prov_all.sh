#!/bin/bash
#
#****************************
# Name:  man1_prov_all.sh
# Author:  R. Cutler
# Description:  script to run all provisioning scripts
#               *** Must be run with root access
# Variables:
#     stage_loc = script base location
#     stage_dir = script staging path
#     DEBUG = debug directory
#     application/instance name = $1
#     character set   = $2
#     application dba ntid = $3
#     application dba email = $4
#     oracle owner = oracle account where binaries are installed
#*****************************
# DATE           Name            Description
# -------------  --------------- -----------------------------
# 02.10.2020     R. Cutler       Created
#################################
# Check number of parameter passed in
#################################
if [ $# -lt 4]
then
   echo -e "STATUS: FAILURE\n"
   echo -e "ERRORMESSAGE1: Instance name, Character Set, DBA NTID, DBA Email Address required.\n"
   exit 1
fi
#################################
# Initialize global variables
#################################
stage_loc="/app/oradba/automation/oracle19"
stage_dir="/tmp/code"
DEBUG="/tmp/prov.debug"
appname=$1
charset=$2
appdbntidp=$3
appdbemail=$4
oracle_owner="<account>"
run_bin="${stage_loc}/run_binary_ins.sh"
run_build="${stage_loc}/run_db_build.sh"
runroot="${stage_loc}/run_root.sh"
addyes="${stage_loc}/chg_oratag.sh"
dataloc="/data"
binloc="/app/oracle"
dirlocs="${binloc} ${dataloc}/oracle01 ${dataloc}/oracle02 ${dataloc}/oracle03 ${dataloc}/audit01 ${dataloc}/dump01"
invexist=`grep "${orahome}" "${binloc}/oraInventory/ContentsXML/inventory.xml" | wc -l`
#################################
# if directories do not exit
#  send message and exit
#################################
set -- ${dirlocs}
DIRS=$@
for inp in "$@"
do
   if ! [ !d ${inp} ]; then
      echo -e "STATUS: FAILURE\n"
      echo -e "ERRORMESSAGE1:  ${inp} directory doesn't exist.  Check directory status - rerun\n"
      exit 1
   fi
done
#################################
# 1. run_binary_ins.sh - <oracle_owner>
# 2. run_root.sh - no additional parameters
#################################
if [ ${invexist} -eq 0 ]; then
   echo === `date` start binary install 2>&1 | tee -a $DEBUG
   ${run_bin} 2>&1 | tee -a $DEBUG
   echo === `date` finish binary install 2>&1 | tee -a $DEBUG
fi
echo === `date` start run_root.sh 2>&1 | tee -a $DEBUG
${runroot} 2>&1 | tee -a $DEBUG
echo === `date` finish run_root.sh 2>&1 | tee -a $DEBUG
#################################
#  end of script



































