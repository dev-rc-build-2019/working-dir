#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        run_db_build.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script combines creation and patch of database
# VARIABLES:
#         $1 = data center (d, v, f)  - Original not used
#         $2 = environment (t, d, p)  - Original not used
#         $1 = instance name          - Originally 3
#         $2 = character set          - Originally 4
#         $3 = ntid of application dba for account - Originally 5
#         $4 = application dba email  - Originally 6
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- -----------------------------------------------
# 01.09.2020    R Cutler        Additional validation for parameters
# 12.16.2019    R Cutler        Change number of expected parameters from 6 to 4
# 12.04.2019    R Cutler        Code for automation
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Check number of parameters passed in
##########################################
if [ $# -lt 4 ]
then
    echo -e "STATUS:FAILURE\n"
    echo -e "ERRORMESSAGE: Instance name, Character Set, DBA NTID, DBA Email Address required.\n"
    exit 1
fi
##########################################
# Initialize global variables
##########################################
stage_loc="/app/oradba/automation/oracle19"
stage_dir="/tmp/code"
tarfile=code.tar
##########################################
# If directory exists delete and create
# If not create the directory
#   download and untar file in new directory
##########################################
if [ ! -d ${stage_dir} ]; then
  mkdir -p ${stage_dir}
  cp ${stage_loc}/${tarfile} ${stage_dir}/.
  cd ${stage_dir}
  tar -xvf ${tarfile}
else
  rm -rf ${stage_dir}
  mkdir -p ${stage_dir}
  cp ${stage_loc}/${tarfile} ${stage_dir}/.
  cd ${stage_dir}
  tar -xvf ${tarfile}
fi
#
##########################################
# Set environment variable
##########################################
. ${stage_dir}/set_env_19.sh
#
##########################################
#   build the database
#    if successful patch database
#    cleanup staging area and log files
#    if not successful send failure message
##########################################
${stage_dir}/dbca_build_19.sh $1 $2 $3 $4
if [ "$?" = "0" ]; then
  ${stage_dir}/patch_db_only_19.sh
  ${stage_dir}/cleanup.sh
else
  echo -e "STATUS:FAILURE\n"
  echo -e "ERRORMESSAGE:Failure running dbca_build_19.sh\n"
fi
##########################################
#   end of script
