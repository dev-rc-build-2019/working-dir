#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        run_root.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script to run oracle orainstRoot.sh and root.sh 
#              *** Must be run with root access
# VARIABLES: 
#        stage_dir = script staging path
#        orabase = oracle base path
#        orahome = oracle home path
#        oraloc  = oracle oraInventory path
#        dba_mail = distribution list for messaging
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 01.09.2020    R Cutler        Add comments on code logic
# 10.09.2019    R Cutler        Code for automation                  
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Initialize global variables
##########################################
#stage_dir="/app/oradba/automation/scripts"
stage_dir="/tmp/code"
##########################################
# Set environment variables
##########################################
. ${stage_dir}/set_env_19.sh
#
orabase=${orabase}
orahome=${orahome}
oraloc=${orabase}/oraInventory
export DBA_MAIL=${notifylist}
##########################################
#  Run scripts to set root permissions and ownership                 
##########################################
if [ -s ${oraloc}/orainstRoot.sh ]; then
  ${oraloc}/orainstRoot.sh
fi
#
if [ -s ${orahome}/root.sh ]; then
  ${orahome}/root.sh
fi
##########################################
# Clean up directory and files 
##########################################
${stage_dir}/cleanup.sh
##########################################
echo -e "STATUS:SUCCESS\n"
##########################################
#   end of script
