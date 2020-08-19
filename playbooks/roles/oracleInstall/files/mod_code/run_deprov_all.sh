#!/bin/bash
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# NAME:        run_deprov_all.sh
# AUTHOR:      R Cutler
# DESCRIPTION: Script to run all deprovisioning scripts 
#              *** Must be run with root access
# VARIABLES: 
#        stage_loc = script base location
#        DEBUG = debug directory 
#        oracle owner = oracle account where binaries are installed
#
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# DATE          NAME            DESCRIPTION
# ----------    --------------- --------------------------------------------------
# 02.12.2020    R Cutler        logic to deinstall environment
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##########################################
# Initialize global variables
##########################################
stage_loc="/app/oradba/automation/oracle19"
DEBUG="/tmp/deprov.debug"
oracle_owner="dcs2or01"
run_deprovdb="${stage_loc}/deinstall_db.sh"
run_deprovsys="${stage_loc}/deinstall_orasys.sh"
##########################################
#1.deinstall_db.sh - <oracle_owner>
#2.deinstall_orasys.sh – no additional parameters 
##########################################
echo === `date` start deprovision database 2>&1 | tee -a $DEBUG
su - $oracle_owner -c "${run_deprovdb}" 2>&1 | tee -a $DEBUG
echo === `date` finish deprovision database 2>&1 | tee -a $DEBUG
#
echo === `date` start remove root owned files 2>&1 | tee -a $DEBUG
${run_deprovsys}  2>&1 | tee -a $DEBUG
echo === `date` finish remove root owned files 2>&1 | tee -a $DEBUG
echo === `date` done 2>&1 | tee -a $DEBUG
##########################################
#   end of script
