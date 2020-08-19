#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        cleanup.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script to remove files and directories created during build
# VARIABLES: 
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 01.09.2020    R Cutler        Add comments on code logic
# 12.11.2019    R Cutler        Created                              
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Initialize global variables
##########################################
stage_dir="/tmp/code"
##########################################
# Remove log files and staging area
##########################################
rm -rf /tmp/track_prog.oracle
rm -rf /tmp/patch_binary.log
rm -rf /tmp/patch.log
rm -rf /tmp/dbs.lst
rm -rf /tmp/output.txt
rm -rf /tmp/sqlplus.log
rm -rf ${stage_dir}
################
#   end of script
