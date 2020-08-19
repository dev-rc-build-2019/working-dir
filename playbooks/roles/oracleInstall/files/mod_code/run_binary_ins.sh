#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        run_binary_ins.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script combines install and patch of database binaries
# VARIABLES:
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 08.05.2020    R Cutler        Add opatch update code    
# 01.09.2020    R Cutler        Add comments on code logic
# 01.09.2020    R Cutler        Add comments on code logic
# 12.04.2019    R Cutler        Code for automation
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Initialize global variables
##########################################
stage_loc="/app/oradba/automation/oracle19"
stage_dir="/tmp/code"
upd_opatch="/app/vendor/oracle/OPatch/p6880880_190000_Linux-x86-64.zip"
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
##########################################
#  Set environment variables
##########################################
. ${stage_dir}/set_env_19.sh
##########################################
#   Install binaries 
#    if successful patch binaries
#    if not successful send failure message
##########################################
${stage_dir}/install_binaries_19.sh
if [ "$?" = "0" ]; then
  cd $orahome
  mv OPatch OPatch.orig
  unzip ${upd_opatch}
  ${stage_dir}/patch_binary_only_19.sh
else
  echo -e "STATUS:FAILURE\n"
  echo -e "ERRORMESSAGE:Failure running install_binaries_19.sh\n"
fi
##########################################
#   end of script
